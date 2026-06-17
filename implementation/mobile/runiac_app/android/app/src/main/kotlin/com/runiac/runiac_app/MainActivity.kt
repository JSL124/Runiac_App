package com.runiac.runiac_app

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingNotificationPermissionResult: MethodChannel.Result? = null

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

    companion object {
        private const val NOTIFICATION_PERMISSION_CHANNEL =
            "runiac/notification_permissions"
        private const val REQUEST_POST_NOTIFICATIONS_PERMISSION_METHOD =
            "requestPostNotificationsPermission"
        private const val REQUEST_POST_NOTIFICATIONS_PERMISSION_CODE = 7401
        private const val NOTIFICATION_PERMISSION_GRANTED = "granted"
        private const val NOTIFICATION_PERMISSION_DENIED = "denied"
        private const val NOTIFICATION_PERMISSION_NOT_REQUIRED = "notRequired"
    }
}
