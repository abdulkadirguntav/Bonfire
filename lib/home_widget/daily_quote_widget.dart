import 'package:home_widget/home_widget.dart';

const String widgetName = 'BonfireDailyQuote';
const String quoteKey = 'quote_text';

Future<void> saveDailyQuoteToWidget(String quote) async {
  try {
    await HomeWidget.saveWidgetData<String>(quoteKey, quote);
    await HomeWidget.updateWidget(
      name: widgetName,
      androidName: 'BonfireDailyQuoteWidget',
      iOSName: 'BonfireDailyQuoteWidget',
    );
  } catch (_) {
    // Silently ignore if native widget communication is unavailable
  }
}

Future<String?> getDailyQuoteFromWidget() async {
  try {
    return await HomeWidget.getWidgetData<String>(quoteKey, defaultValue: '');
  } catch (_) {
    return '';
  }
}
