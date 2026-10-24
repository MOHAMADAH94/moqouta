package com.islamicapps.prayer_times_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NextPrayerWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, MoqoutaWidgets.smallViews(context))
        }
        MoqoutaWidgets.schedule(context)
    }

    override fun onDisabled(context: Context) {
        MoqoutaWidgets.schedule(context)
    }
}

class TimesWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, MoqoutaWidgets.wideViews(context))
        }
        MoqoutaWidgets.schedule(context)
    }

    override fun onDisabled(context: Context) {
        MoqoutaWidgets.schedule(context)
    }
}

class WidgetTickReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        MoqoutaWidgets.updateAll(context)
        MoqoutaWidgets.schedule(context)
    }
}
