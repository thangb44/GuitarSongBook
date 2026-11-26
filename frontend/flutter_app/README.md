# Guitar Songbook frontend

This directory contains the Flutter application.

Run Flutter commands from this directory. Start the FastAPI backend separately
before searching.

```powershell
flutter pub get
flutter analyze
flutter test
```

The app uses `http://127.0.0.1:8000` by default on web and desktop, and
`http://10.0.2.2:8000` on the Android emulator. The Android emulator can reach
the host machine through `10.0.2.2`.

For Flutter web, use a port allowed by the backend's CORS settings:

```powershell
flutter run -d chrome --web-hostname 127.0.0.1 --web-port 5000
```

For a physical Android device, use the computer's LAN address. The same
`API_BASE_URL` override can point to a production HTTPS endpoint:

```powershell
flutter run -d android --dart-define=API_BASE_URL=http://192.168.1.10:8000
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

For physical-device testing, run the backend bound to `0.0.0.0` and allow
connections through the computer's firewall.
