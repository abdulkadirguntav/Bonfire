package com.example.bonfire

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class BonfireDailyQuoteWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val quote = widgetData.getString("quote_text", "Dünya senin acılarını umursamıyor. Kalk ve yürü.")

            val views = RemoteViews(context.packageName, R.layout.bonfire_daily_quote_widget).apply {
                setTextViewText(R.id.quote_text, quote)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
