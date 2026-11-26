# Guitar Songbook

## Project layout

- `frontend/flutter_app/` — Flutter application
- `backend/` — Python API and song-search service

## Frontend

Run Flutter commands from the app directory:

```powershell
cd frontend/flutter_app
flutter pub get
flutter analyze
flutter test
flutter run
```

## Backend

The Python service is in `backend/`. Its dependencies are listed in
`backend/requirements.txt`, and `backend/.env.example` documents environment
configuration.
