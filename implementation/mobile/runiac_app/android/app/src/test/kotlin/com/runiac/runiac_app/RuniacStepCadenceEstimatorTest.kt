package com.runiac.runiac_app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class RuniacStepCadenceEstimatorTest {
    @Test
    fun acceptsSlowWalkingCadenceAtNinetyFiveSpm() {
        val estimator = RuniacStepCadenceEstimator()

        val cadence = cadenceAfterSixSteps(estimator, cadenceSpm = 95)

        assertEquals(95, cadence)
    }

    @Test
    fun rejectsCadenceBelowSupportedWalkingFloor() {
        val estimator = RuniacStepCadenceEstimator()

        val cadence = cadenceAfterSixSteps(estimator, cadenceSpm = 80)

        assertNull(cadence)
    }

    private fun cadenceAfterSixSteps(
        estimator: RuniacStepCadenceEstimator,
        cadenceSpm: Int,
    ): Int? {
        val intervalNanos = 60_000_000_000L / cadenceSpm
        var cadence: Int? = null
        for (index in 0 until 6) {
            cadence = estimator.cadenceFromStep(index * intervalNanos)
        }
        return cadence
    }
}
