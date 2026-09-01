# Smart Lead Scoring — Flutter Client

A lightweight Flutter client for the Smart Lead Scoring API.

## Run

From this directory:

```bash
flutter pub get
flutter run
```

The Android emulator uses `10.0.2.2` to reach a local API running on the host machine. For iOS simulator or a physical device, change the API URL in `lib/main.dart` to the appropriate host address.

## User flow

1. Enter CRM activity.
2. Submit the lead.
3. The Flutter client calls `POST /predict`.
4. The score, probability and priority are displayed.
