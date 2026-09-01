# Smart Lead Scoring — Flutter Client

A clean Flutter client for the Smart Lead Scoring API.

## UX flow

1. Open the Lead Scoring screen.
2. Use **Try demo** to load a realistic sample lead, or enter your own values.
3. Press **Score this lead**.
4. The client calls `POST /predict`.
5. The result shows a 0–100 score, conversion probability and sales priority.
6. Use **Score another lead** or the refresh action to repeat the flow.

The UI includes validation, loading feedback, responsive layout, empty state and API error feedback.

## Run

The repository intentionally keeps the Flutter application source lightweight. If platform folders have not been generated in your checkout, initialise them once:

```bash
cd flutter_app
flutter create --platforms=android,ios,web .
flutter pub get
flutter run
```

For Flutter Web, run the API first and use the default `http://localhost:8000` API URL.

For an Android emulator, use:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For an iOS simulator, `http://localhost:8000` is normally suitable. For a physical device, use the host machine's LAN IP.

## API URL

The client reads `API_BASE_URL` through `--dart-define`. This avoids hard-coding a single environment into the application.

## Test

```bash
flutter analyze
flutter test
```
