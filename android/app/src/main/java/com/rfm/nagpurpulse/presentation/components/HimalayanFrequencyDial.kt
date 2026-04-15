package com.rfm.nagpurpulse.presentation.components

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rfm.nagpurpulse.presentation.theme.HimalayanAmber
import com.rfm.nagpurpulse.presentation.theme.HimalayanDesertSand
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey
import com.rfm.nagpurpulse.presentation.theme.HimalayanRed
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun HimalayanFrequencyDial(
    frequency: String,
    mhz: String,
    isPlaying: Boolean,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "Pulse")
    val amberAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "AmberPulse"
    )

    Box(
        modifier = modifier
            .size(300.dp)
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {
        // Outer Rings & Gauges
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2, size.height / 2)
            val radius = size.minDimension / 2
            
            // Outer dashed ring
            drawCircle(
                color = HimalayanGrey.copy(alpha = 0.3f),
                radius = radius,
                style = Stroke(
                    width = 2.dp.toPx(),
                    pathEffect = PathEffect.dashPathEffect(floatArrayOf(4f, 8f), 0f)
                )
            )

            // Top Alignment Line
            drawLine(
                color = HimalayanGrey.copy(alpha = 0.5f),
                start = Offset(center.x, center.y - radius - 8.dp.toPx()),
                end = Offset(center.x, center.y - radius - 40.dp.toPx()),
                strokeWidth = 2.dp.toPx()
            )

            // Outer ticks
            val tickCount = 60
            for (i in 0 until tickCount) {
                val angle = (i * (360f / tickCount)) * (Math.PI / 180f).toFloat()
                val innerR = radius - 8.dp.toPx()
                val outerR = radius
                
                drawLine(
                    color = if (i % 5 == 0) HimalayanDesertSand else HimalayanGrey,
                    start = Offset(center.x + innerR * cos(angle), center.y + innerR * sin(angle)),
                    end = Offset(center.x + outerR * cos(angle), center.y + outerR * sin(angle)),
                    strokeWidth = if (i % 5 == 0) 2.dp.toPx() else 1.dp.toPx()
                )
            }

            // The "Needle" (Red indicator)
            // Fixed for now, could be dynamic
            val needleAngle = -45f * (Math.PI / 180f).toFloat()
            drawLine(
                color = HimalayanRed,
                start = center,
                end = Offset(center.x + radius * cos(needleAngle), center.y + radius * sin(needleAngle)),
                strokeWidth = 2.dp.toPx(),
                cap = StrokeCap.Round
            )
        }

        // Center Content
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "FREQUENCY",
                style = MaterialTheme.typography.labelSmall,
                color = HimalayanGrey
            )
            
            Text(
                text = frequency,
                style = MaterialTheme.typography.displayLarge.copy(fontSize = 72.sp),
                color = MaterialTheme.colorScheme.onBackground
            )
            
            Text(
                text = mhz,
                style = MaterialTheme.typography.labelLarge,
                color = HimalayanDesertSand
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .clip(CircleShape)
                        .background(HimalayanAmber.copy(alpha = if (isPlaying) amberAlpha else 0.3f))
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "LIVE BROADCAST",
                    style = MaterialTheme.typography.labelSmall,
                    color = HimalayanGrey
                )
            }
        }
    }
}
