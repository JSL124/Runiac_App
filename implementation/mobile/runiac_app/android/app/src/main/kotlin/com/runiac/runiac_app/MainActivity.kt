package com.runiac.runiac_app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingNotificationPermissionResult: MethodChannel.Result? = null
    private var pendingActivityRecognitionPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIFICATION_PERMISSION_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                REQUEST_POST_NOTIFICATIONS_PERMISSION_METHOD ->
                    requestPostNotificationsPermission(result)
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PHONE_MOTION_CADENCE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            val cadenceStream = RuniacPhoneMotionCadenceStream(this)
            when (call.method) {
                PHONE_MOTION_CADENCE_IS_AVAILABLE_METHOD ->
                    result.success(cadenceStream.isAvailable())
                PHONE_MOTION_CADENCE_REQUEST_PERMISSION_METHOD ->
                    requestActivityRecognitionPermission(result)
                else -> result.notImplemented()
            }
        }
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PHONE_MOTION_CADENCE_EVENTS_CHANNEL,
        ).setStreamHandler(RuniacPhoneMotionCadenceStream(this))
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RUN_FOREGROUND_SERVICE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                START_RUN_FOREGROUND_SERVICE_METHOD -> {
                    val title = call.argument<String>("title") ?: DEFAULT_RUN_TITLE
                    val body = call.argument<String>("body") ?: DEFAULT_RUN_BODY
                    startRunForegroundService(title, body)
                    result.success(null)
                }
                UPDATE_RUN_NOTIFICATION_METHOD -> {
                    val title = call.argument<String>("title") ?: DEFAULT_RUN_TITLE
                    val body = call.argument<String>("body") ?: DEFAULT_RUN_BODY
                    updateRunForegroundService(title, body)
                    result.success(null)
                }
                STOP_RUN_FOREGROUND_SERVICE_METHOD -> {
                    stopRunForegroundService()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestPostNotificationsPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(NOTIFICATION_PERMISSION_NOT_REQUIRED)
            return
        }

        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(NOTIFICATION_PERMISSION_GRANTED)
            return
        }

        if (pendingNotificationPermissionResult != null) {
            result.success(NOTIFICATION_PERMISSION_DENIED)
            return
        }

        pendingNotificationPermissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_POST_NOTIFICATIONS_PERMISSION_CODE,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_POST_NOTIFICATIONS_PERMISSION_CODE) {
            if (requestCode == REQUEST_ACTIVITY_RECOGNITION_PERMISSION_CODE) {
                completeActivityRecognitionPermissionRequest(grantResults)
            }
            return
        }

        val result = pendingNotificationPermissionResult ?: return
        pendingNotificationPermissionResult = null
        val permissionGranted =
            grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
        result.success(
            if (permissionGranted) {
                NOTIFICATION_PERMISSION_GRANTED
            } else {
                NOTIFICATION_PERMISSION_DENIED
            },
        )
    }

    private fun requestActivityRecognitionPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.success(ACTIVITY_RECOGNITION_GRANTED)
            return
        }

        if (checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(ACTIVITY_RECOGNITION_GRANTED)
            return
        }

        if (pendingActivityRecognitionPermissionResult != null) {
            result.success(ACTIVITY_RECOGNITION_DENIED)
            return
        }

        pendingActivityRecognitionPermissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
            REQUEST_ACTIVITY_RECOGNITION_PERMISSION_CODE,
        )
    }

    private fun completeActivityRecognitionPermissionRequest(grantResults: IntArray) {
        val result = pendingActivityRecognitionPermissionResult ?: return
        pendingActivityRecognitionPermissionResult = null
        val permissionGranted =
            grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
        result.success(
            if (permissionGranted) {
                ACTIVITY_RECOGNITION_GRANTED
            } else {
                ACTIVITY_RECOGNITION_DENIED
            },
        )
    }

    private fun startRunForegroundService(title: String, body: String) {
        val intent = Intent(this, RuniacRunTrackingService::class.java).apply {
            action = RuniacRunTrackingService.ACTION_START
            putExtra(RuniacRunTrackingService.EXTRA_TITLE, title)
            putExtra(RuniacRunTrackingService.EXTRA_BODY, body)
        }
        ContextCompat.startForegroundService(this, intent)
    }

    private fun updateRunForegroundService(title: String, body: String) {
        val intent = Intent(this, RuniacRunTrackingService::class.java).apply {
            action = RuniacRunTrackingService.ACTION_UPDATE
            putExtra(RuniacRunTrackingService.EXTRA_TITLE, title)
            putExtra(RuniacRunTrackingService.EXTRA_BODY, body)
        }
        startService(intent)
    }

    private fun stopRunForegroundService() {
        val intent = Intent(this, RuniacRunTrackingService::class.java).apply {
            action = RuniacRunTrackingService.ACTION_STOP
        }
        startService(intent)
    }

    companion object {
        private const val NOTIFICATION_PERMISSION_CHANNEL =
            "runiac/notification_permissions"
        private const val PHONE_MOTION_CADENCE_CHANNEL =
            "runiac/phone_motion_cadence"
        private const val PHONE_MOTION_CADENCE_EVENTS_CHANNEL =
            "runiac/phone_motion_cadence_events"
        private const val RUN_FOREGROUND_SERVICE_CHANNEL =
            "runiac/run_foreground_service"
        private const val REQUEST_POST_NOTIFICATIONS_PERMISSION_METHOD =
            "requestPostNotificationsPermission"
        private const val START_RUN_FOREGROUND_SERVICE_METHOD = "start"
        private const val UPDATE_RUN_NOTIFICATION_METHOD = "update"
        private const val STOP_RUN_FOREGROUND_SERVICE_METHOD = "stop"
        private const val PHONE_MOTION_CADENCE_IS_AVAILABLE_METHOD =
            "isAvailable"
        private const val PHONE_MOTION_CADENCE_REQUEST_PERMISSION_METHOD =
            "requestPermission"
        private const val REQUEST_POST_NOTIFICATIONS_PERMISSION_CODE = 7401
        private const val REQUEST_ACTIVITY_RECOGNITION_PERMISSION_CODE = 7402
        private const val NOTIFICATION_PERMISSION_GRANTED = "granted"
        private const val NOTIFICATION_PERMISSION_DENIED = "denied"
        private const val NOTIFICATION_PERMISSION_NOT_REQUIRED = "notRequired"
        private const val ACTIVITY_RECOGNITION_GRANTED = "granted"
        private const val ACTIVITY_RECOGNITION_DENIED = "denied"
        private const val DEFAULT_RUN_TITLE = "Runiac is tracking your run"
        private const val DEFAULT_RUN_BODY = "Keep moving in an open area"
    }
}
