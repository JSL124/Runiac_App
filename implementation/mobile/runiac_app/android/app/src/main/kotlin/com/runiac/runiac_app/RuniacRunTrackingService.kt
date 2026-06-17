package com.runiac.runiac_app

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

class RuniacRunTrackingService : Service() {
    private var latestTitle = DEFAULT_TITLE
    private var latestBody = DEFAULT_BODY

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                latestTitle = intent.getStringExtra(EXTRA_TITLE) ?: DEFAULT_TITLE
                latestBody = intent.getStringExtra(EXTRA_BODY) ?: DEFAULT_BODY
                startForegroundTracking()
            }
            ACTION_UPDATE -> {
                latestTitle = intent.getStringExtra(EXTRA_TITLE) ?: latestTitle
                latestBody = intent.getStringExtra(EXTRA_BODY) ?: latestBody
                updateNotification()
            }
            ACTION_STOP -> {
                stopForegroundTracking()
            }
        }
        return START_NOT_STICKY
    }

    private fun startForegroundTracking() {
        if (!hasLocationPermission()) {
            stopSelf()
            return
        }

        ensureChannel()
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            buildNotification(),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            } else {
                0
            },
        )
    }

    private fun updateNotification() {
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, buildNotification())
    }

    private fun stopForegroundTracking() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle(latestTitle)
            .setContentText(latestBody)
            .setStyle(NotificationCompat.BigTextStyle().bigText(latestBody))
            .setContentIntent(buildContentIntent())
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun buildContentIntent(): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(EXTRA_RUN_OPEN_INTENT, RUN_OPEN_INTENT_NOTIFICATION)
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE
            } else {
                0
            }
        return PendingIntent.getActivity(this, REQUEST_CODE_OPEN_RUN, intent, flags)
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = CHANNEL_DESCRIPTION
            lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        }
        notificationManager.createNotificationChannel(channel)
    }

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            ) == PackageManager.PERMISSION_GRANTED
    }

    companion object {
        const val ACTION_START = "com.runiac.runiac_app.run_tracking.START"
        const val ACTION_UPDATE = "com.runiac.runiac_app.run_tracking.UPDATE"
        const val ACTION_STOP = "com.runiac.runiac_app.run_tracking.STOP"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_RUN_OPEN_INTENT = "runiac_run_open_intent"
        const val RUN_OPEN_INTENT_NOTIFICATION = "notification"

        private const val CHANNEL_ID = "runiac_run_tracking"
        private const val CHANNEL_NAME = "Runiac Run Tracking"
        private const val CHANNEL_DESCRIPTION =
            "Shows active run tracking while Runiac records your route."
        private const val NOTIFICATION_ID = 41024
        private const val REQUEST_CODE_OPEN_RUN = 41025
        private const val DEFAULT_TITLE = "Runiac is tracking your run"
        private const val DEFAULT_BODY = "Keep moving in an open area"
    }
}
