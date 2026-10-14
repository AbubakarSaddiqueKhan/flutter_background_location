# Flutter Background Location

Keeps location tracking running after the user leaves the app, which is the core problem behind field-force, delivery and inspection apps.

## How it works

- **Foreground service:** [`flutter_background_service`](https://pub.dev/packages/flutter_background_service) runs a long-lived service that starts automatically and keeps a persistent notification on Android, so the OS doesn't kill tracking.
- **Location stream:** [`geolocator`](https://pub.dev/packages/geolocator) streams positions with `bestForNavigation` accuracy and a 1-metre distance filter.
- **Live feedback:** [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) shows the latest coordinates as a notification on each update.
- **Service control:** the service handles `setAsForeground`, `setAsBackground` and `stopService` events, so the app can switch modes or stop tracking.

## Tech

Flutter · Dart · Android foreground services · Geolocator · Local notifications

## Run it

```bash
flutter pub get
flutter run
```

Grant location permission ("Allow all the time" on Android for background updates) and notification permission when prompted.

## Next steps

- Batch and upload positions to a backend (Workmanager and Firestore upload hooks are stubbed in `main.dart`)
- Reuse a single notification instance and cancel the position stream when the service stops

---

Built by [Abubakar](https://www.linkedin.com/in/abubakar-aziz-flutter), Senior Flutter Engineer. Production apps with this kind of tracking: [Field Force-AI](https://play.google.com/store/apps/details?id=com.fieldforce.ai), [Pharmasol](https://play.google.com/store/apps/details?id=com.fieldforce.ai.pharmasol).
