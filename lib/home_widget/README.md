# Native Home Screen Widget

This folder sets up the `home_widget` package so the app's daily quote appears on the user's phone home screen, even when the app is closed.

### Requirements for full functionality:
- Android: Add `AppWidgetProvider` in `android/app/src/main/kotlin/` (see `home_widget` package docs)
- iOS: Add `WidgetBundle` with `IntentConfiguration` (see `home_widget` package docs)

### What it does now:
- `main()` calls `HomeWidget.init()` and saves today's quote to the native widget storage.
- The quote is read from `core/constants/daily_quotes.dart` (same source as the in-app widget).
- `saveDailyQuoteToWidget()` pushes the quote to the native widget layer.
