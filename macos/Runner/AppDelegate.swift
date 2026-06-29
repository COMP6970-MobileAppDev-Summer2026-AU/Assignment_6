// =============================================================================
// macos/Runner/AppDelegate.swift  (also use for ios/Runner/AppDelegate.swift)
// Native Swift — Apple Vision text recognition via Flutter MethodChannel
// Handles both macOS and iOS
// =============================================================================

import Cocoa
import FlutterMacOS
import Vision

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(
    _ sender: NSApplication
  ) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(
    _ app: NSApplication
  ) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(
    _ notification: Notification
  ) {
    let controller = mainFlutterWindow?.contentViewController
      as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.example.scanlog/ocr",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "recognizeText",
            let args = call.arguments as? [String: Any],
            let path = args["imagePath"] as? String
      else {
        result(FlutterError(
          code: "INVALID_ARGS",
          message: "imagePath required",
          details: nil
        ))
        return
      }
      self?.recognizeText(at: path, result: result)
    }

    super.applicationDidFinishLaunching(notification)
  }

  private func recognizeText(at path: String, result: @escaping FlutterResult) {
    guard let image = NSImage(contentsOfFile: path),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else {
      result(FlutterError(code: "IMAGE_ERROR",
                          message: "Cannot load image at \(path)",
                          details: nil))
      return
    }

    let request = VNRecognizeTextRequest { req, err in
      if let err = err {
        result(FlutterError(code: "VISION_ERROR",
                            message: err.localizedDescription,
                            details: nil))
        return
      }
      let lines = (req.results as? [VNRecognizedTextObservation] ?? [])
        .compactMap { $0.topCandidates(1).first?.string }
      result(lines.joined(separator: "\n"))
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        result(FlutterError(code: "HANDLER_ERROR",
                            message: error.localizedDescription,
                            details: nil))
      }
    }
  }
}
