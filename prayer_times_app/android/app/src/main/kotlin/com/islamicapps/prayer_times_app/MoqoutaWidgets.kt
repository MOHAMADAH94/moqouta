package com.islamicapps.prayer_times_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

object MoqoutaWidgets {
    private const val PREFS = "moqouta_widget"
    private const val TICK_REQUEST = 41

    fun save(context: Context, args: Map<String, Any?>) {
        val editor = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
        editor.putString("city", args["city"] as? String ?: "دمشق")
        editor.putString("hijri", args["hijri"] as? String ?: "")
        editor.putString("gregorian", args["gregorian"] as? String ?: "")
        editor.putString("rows", args["rows"] as? String ?: "")
        editor.putString("tomorrowName", args["tomorrowName"] as? String ?: "الفجر")
        editor.putString("tomorrowDisplay", args["tomorrowDisplay"] as? String ?: "")
        editor.putLong("tomorrowAt", (args["tomorrowAt"] as? Number)?.toLong() ?: 0L)
        editor.apply()
    }

    fun updateAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val small = ComponentName(context, NextPrayerWidget::class.java)
        val wide = ComponentName(context, TimesWidget::class.java)
        for (id in manager.getAppWidgetIds(small)) {
            manager.updateAppWidget(id, smallViews(context))
        }
        for (id in manager.getAppWidgetIds(wide)) {
            manager.updateAppWidget(id, wideViews(context))
        }
    }

    fun schedule(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val hasWidgets = manager.getAppWidgetIds(ComponentName(context, NextPrayerWidget::class.java)).isNotEmpty() ||
            manager.getAppWidgetIds(ComponentName(context, TimesWidget::class.java)).isNotEmpty()
        val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pending = tickIntent(context)
        if (!hasWidgets) {
            alarm.cancel(pending)
            return
        }
        val trigger = System.currentTimeMillis() + 60_000L
        alarm.setAndAllowWhileIdle(AlarmManager.RTC, trigger, pending)
    }

    fun tickIntent(context: Context): PendingIntent {
        val intent = Intent(context, WidgetTickReceiver::class.java)
        return PendingIntent.getBroadcast(
            context,
            TICK_REQUEST,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private data class Row(val name: String, val display: String, val at: Long, val salah: Boolean)

    private fun rows(context: Context): List<Row> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val packed = prefs.getString("rows", "").orEmpty()
        if (packed.isEmpty()) return emptyList()
        val parsed = packed.split(';').mapNotNull { piece ->
            val parts = piece.split('|')
            if (parts.size < 4) return@mapNotNull null
            Row(parts[0], parts[1], parts[2].toLongOrNull() ?: return@mapNotNull null, parts[3] == "1")
        }.toMutableList()
        val tomorrowAt = prefs.getLong("tomorrowAt", 0L)
        if (tomorrowAt > 0L) {
            parsed += Row(
                prefs.getString("tomorrowName", "الفجر") ?: "الفجر",
                prefs.getString("tomorrowDisplay", "") ?: "",
                tomorrowAt,
                true,
            )
        }
        return parsed
    }

    private fun nextRow(rows: List<Row>): Row? {
        val now = System.currentTimeMillis()
        return rows.firstOrNull { it.salah && it.at > now } ?: rows.lastOrNull { it.salah }
    }

    private fun countdown(at: Long): String {
        val remain = ((at - System.currentTimeMillis()) / 1000L).coerceAtLeast(0L)
        val hours = remain / 3600
        val minutes = (remain % 3600) / 60
        val seconds = remain % 60
        return "%02d:%02d:%02d".format(hours, minutes, seconds)
    }

    private fun openIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    fun smallViews(context: Context): RemoteViews {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.widget_small)
        val city = prefs.getString("city", "موقوتا") ?: "موقوتا"
        val rows = rows(context)
        val next = nextRow(rows)
        views.setTextViewText(R.id.widget_city, city)
        views.setTextViewText(R.id.widget_hijri, prefs.getString("hijri", "") ?: "")
        if (next == null) {
            views.setTextViewText(R.id.widget_next_name, "موقوتا")
            views.setTextViewText(R.id.widget_next_time, "افتح التطبيق")
            views.setTextViewText(R.id.widget_countdown, "--:--:--")
        } else {
            views.setTextViewText(R.id.widget_next_name, next.name)
            views.setTextViewText(R.id.widget_next_time, next.display)
            views.setTextViewText(R.id.widget_countdown, countdown(next.at))
        }
        views.setOnClickPendingIntent(R.id.widget_small_root, openIntent(context))
        return views
    }

    fun wideViews(context: Context): RemoteViews {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.widget_wide)
        val city = prefs.getString("city", "دمشق") ?: "دمشق"
        val today = rows(context).take(6)
        val next = nextRow(rows(context))
        views.setTextViewText(
            R.id.widget_wide_title,
            if (next == null) city else "$city  ·  ${next.name}  ${countdown(next.at)}",
        )
        val nameIds = intArrayOf(R.id.w_name_0, R.id.w_name_1, R.id.w_name_2, R.id.w_name_3, R.id.w_name_4, R.id.w_name_5)
        val timeIds = intArrayOf(R.id.w_time_0, R.id.w_time_1, R.id.w_time_2, R.id.w_time_3, R.id.w_time_4, R.id.w_time_5)
        for (i in 0 until 6) {
            val row = today.getOrNull(i)
            views.setTextViewText(nameIds[i], row?.name ?: "")
            views.setTextViewText(timeIds[i], row?.display ?: "")
        }
        views.setOnClickPendingIntent(R.id.widget_wide_root, openIntent(context))
        return views
    }
}
