package com.rfm.nagpurpulse.presentation.util

import android.animation.ValueAnimator
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import com.rfm.nagpurpulse.databinding.ViewVisualizerBinding
import kotlin.random.Random

/**
 * Animates the 4 bars in a ViewVisualizerBinding independently,
 * each with a slightly different duration for a natural waveform look.
 */
object VisualizerAnimator {

    // Keyed by the root view so we can cancel when a ViewHolder is recycled
    private val running = mutableMapOf<View, List<ValueAnimator>>()

    fun start(binding: ViewVisualizerBinding) {
        val ctx = binding.root.context
        stop(binding) // cancel previous run on same root

        val bars = listOf(binding.bar1, binding.bar2, binding.bar3, binding.bar4)
        // min/max heights in dp — staggered so bars never move in unison
        val minDp = listOf(4, 5, 4, 5)
        val maxDp = listOf(14, 22, 18, 20)
        val baseDurations = listOf(380L, 520L, 430L, 470L)

        val animators = bars.mapIndexed { i, bar ->
            val minPx = minDp[i].dpToPx(ctx)
            val maxPx = maxDp[i].dpToPx(ctx)
            ValueAnimator.ofInt(minPx, maxPx).apply {
                duration = baseDurations[i] + Random.nextLong(80)
                repeatCount = ValueAnimator.INFINITE
                repeatMode = ValueAnimator.REVERSE
                interpolator = AccelerateDecelerateInterpolator()
                startDelay = (i * 60L) + Random.nextLong(40)
                addUpdateListener { anim ->
                    val lp = bar.layoutParams
                    lp.height = anim.animatedValue as Int
                    bar.layoutParams = lp
                }
                start()
            }
        }

        running[binding.root] = animators
    }

    fun stop(binding: ViewVisualizerBinding) {
        stopByRoot(binding.root)
        // Reset bars to their default static heights
        val ctx = binding.root.context
        val defaults = listOf(8, 14, 10, 16)
        listOf(binding.bar1, binding.bar2, binding.bar3, binding.bar4)
            .forEachIndexed { i, bar ->
                val lp = bar.layoutParams
                lp.height = defaults[i].dpToPx(ctx)
                bar.layoutParams = lp
            }
    }

    fun stopByRoot(root: View) {
        running.remove(root)?.forEach { it.cancel() }
    }
}
