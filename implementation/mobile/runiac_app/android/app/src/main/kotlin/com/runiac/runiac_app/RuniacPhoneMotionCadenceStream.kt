package com.runiac.runiac_app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import kotlin.math.roundToInt

class RuniacPhoneMotionCadenceStream(
    private val context: Context,
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepTimestamps = ArrayDeque<Long>()
    private var eventSink: EventChannel.EventSink? = null

    fun isAvailable(): Boolean {
        return hasPermission() &&
            sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR) != null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        if (!isAvailable()) {
            events?.endOfStream()
            return
        }
        val stepDetector = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (stepDetector == null) {
            events?.endOfStream()
            return
        }
        stepTimestamps.clear()
        sensorManager.registerListener(
            this,
            stepDetector,
            SensorManager.SENSOR_DELAY_NORMAL,
        )
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        stepTimestamps.clear()
        eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type != Sensor.TYPE_STEP_DETECTOR) {
            return
        }
        val cadence = cadenceFromStep(event.timestamp) ?: return
        eventSink?.success(
            mapOf(
                "recordedAtMillis" to System.currentTimeMillis(),
                "stepsPerMinute" to cadence,
                "confidence" to "estimated",
            ),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun hasPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return true
        }
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACTIVITY_RECOGNITION,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun cadenceFromStep(timestampNanos: Long): Int? {
        stepTimestamps.addLast(timestampNanos)
        val windowStart = timestampNanos - CADENCE_WINDOW_NANOS
        while (stepTimestamps.isNotEmpty() && stepTimestamps.first() < windowStart) {
            stepTimestamps.removeFirst()
        }
        if (stepTimestamps.size < MINIMUM_WINDOW_STEPS) {
            return null
        }
        val firstTimestamp = stepTimestamps.first()
        val elapsedMinutes = (timestampNanos - firstTimestamp).toDouble() /
            NANOS_PER_MINUTE
        if (elapsedMinutes <= 0) {
            return null
        }
        val cadence = ((stepTimestamps.size - 1) / elapsedMinutes).roundToInt()
        if (cadence < MINIMUM_CADENCE_SPM || cadence > MAXIMUM_CADENCE_SPM) {
            return null
        }
        return cadence
    }

    companion object {
        private const val CADENCE_WINDOW_NANOS = 15_000_000_000L
        private const val NANOS_PER_MINUTE = 60_000_000_000.0
        private const val MINIMUM_WINDOW_STEPS = 6
        private const val MINIMUM_CADENCE_SPM = 120
        private const val MAXIMUM_CADENCE_SPM = 220
    }
}
