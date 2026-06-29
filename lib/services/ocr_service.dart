// =============================================================================
// services/ocr_service.dart
// On-device text recognition with detailed console logging
// =============================================================================

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static const _nativeChannel = MethodChannel('com.example.scanlog/ocr');
  TextRecognizer? _mlKitRecognizer;

  Future<String> recognizeText(String imagePath) async {
    debugLog('📷 [OCR] Starting text recognition');
    debugLog('📷 [OCR] Image path: $imagePath');
    debugLog('📷 [OCR] Platform: ${Platform.operatingSystem}');

    final stopwatch = Stopwatch()..start();

    try {
      final text = Platform.isMacOS
          ? await _recognizeNative(imagePath)
          : await _recognizeMlKit(imagePath);

      stopwatch.stop();

      // Validate content isn't just metadata/logs
      _validateContent(text);

      debugLog('✅ [OCR] Recognition complete in ${stopwatch.elapsedMilliseconds}ms');
      debugLog('✅ [OCR] Characters recognized: ${text.length}');
      debugLog('✅ [OCR] Words recognized: ${text.trim().split(RegExp(r'\s+')).length}');

      // Clean preview — first 200 chars, single line
      final preview = text.replaceAll('\n', ' ').trim();
      final short   = preview.length > 200
          ? '${preview.substring(0, 200)}…'
          : preview;
      debugLog('✅ [OCR] Text preview: "$short"');

      return text;
    } catch (e) {
      stopwatch.stop();
      debugLog('❌ [OCR] Failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  // ── Content validator ─────────────────────────────────────────────────────
  void _validateContent(String text) {
    final logPatterns = [
      RegExp(r'\[ScanLog\]'),
      RegExp(r'\[OCR\]'),
      RegExp(r'\[Storage\]'),
      RegExp(r'\[Scan\]'),
      RegExp(r'flutter:'),
    ];

    int matchCount = 0;
    for (final pattern in logPatterns) {
      matchCount += pattern.allMatches(text).length;
    }

    if (matchCount > 3) {
      debugLog('⚠️  [OCR] WARNING: Scanned image appears to be a screenshot '
          'of terminal/log output ($matchCount log patterns detected). '
          'Try scanning an actual document instead.');
    } else {
      debugLog('✅ [OCR] Content validation passed — looks like real document text');
    }
  }

  Future<String> _recognizeNative(String imagePath) async {
    debugLog('🍎 [OCR] Using Apple Vision framework (macOS native)');
    try {
      final text = await _nativeChannel.invokeMethod<String>(
        'recognizeText',
        {'imagePath': imagePath},
      );
      if (text == null || text.trim().isEmpty) {
        throw const OcrException('No text found in this image.');
      }
      return text.trim();
    } on PlatformException catch (e) {
      throw OcrException('Vision error: ${e.message}');
    } on MissingPluginException {
      throw const OcrException(
          'Native OCR channel not found. Rebuild after updating AppDelegate.swift.');
    }
  }

  Future<String> _recognizeMlKit(String imagePath) async {
    debugLog('🤖 [OCR] Using Google ML Kit (iOS real device)');
    _mlKitRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await _mlKitRecognizer!
          .processImage(InputImage.fromFile(File(imagePath)));
      if (result.text.trim().isEmpty) {
        throw const OcrException('No text found in this image.');
      }
      return result.text.trim();
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException('ML Kit error: $e');
    }
  }

  void dispose() {
    debugLog('🔒 [OCR] Disposing recognizer');
    _mlKitRecognizer?.close();
    _mlKitRecognizer = null;
  }
}

class OcrException implements Exception {
  final String message;
  const OcrException(this.message);

  @override
  String toString() => message;
}

void debugLog(String message) {
  // ignore: avoid_print
  print('[ScanLog] $message');
}
