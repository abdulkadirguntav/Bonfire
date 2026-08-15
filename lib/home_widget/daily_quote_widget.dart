import 'package:home_widget/home_widget.dart';

const String widgetName = 'BonfireDailyQuote';
const String quoteKey = 'quote_text';

Future<void> saveDailyQuoteToWidget(String quote) async {
  await HomeWidget.saveWidgetData<String>(quoteKey, quote);
  await HomeWidget.updateWidget(
    name: widgetName,
    androidName: 'BonfireDailyQuote',
    iOSName: 'BonfireDailyQuote',
  );
}

Future<String?> getDailyQuoteFromWidget() async {
  return HomeWidget.getWidgetData<String>(quoteKey, defaultValue: '');
}
