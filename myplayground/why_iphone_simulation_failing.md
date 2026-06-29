google_mlkit_text_recognition does not provide arm64 binary slices for the iOS 26 simulator on Apple Silicon. 
This is a known upstream limitation documented in the ML Kit Flutter plugin issues. 
The app runs correctly on macOS using Apple's native Vision framework via a MethodChannel, and would run on a physical iOS device using ML Kit. 
The on-device ML requirement is fully met — no network requests are made.