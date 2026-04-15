package com.rfm.nagpurpulse.presentation.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.presentation.theme.HimalayanCharcoal
import com.rfm.nagpurpulse.presentation.theme.HimalayanDesertSand
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey
import com.rfm.nagpurpulse.presentation.theme.HimalayanWhite

@Composable
fun MiniPlayer(
    station: Station?,
    isPlaying: Boolean,
    isBuffering: Boolean,
    onPlayPauseClick: () -> Unit,
    onNextClick: () -> Unit,
    onPreviousClick: () -> Unit = {},
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    if (station == null) return

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(HimalayanCharcoal)
            .padding(vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Technical Readouts Row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 32.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Bottom
        ) {
            TechnicalReadout(label = "SIGNAL STRENGTH", value = "|||||")
            TechnicalReadout(label = "VOLUME GAIN", value = "62", unit = "DB")
            TechnicalReadout(label = "MODE", value = "STEREO")
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Large Tactile Controls
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Previous Button
            ControlSquare(
                icon = Icons.Default.SkipPrevious,
                onClick = onPreviousClick,
                isPrimary = false
            )

            // Main Play/Pause Button (Large Tan)
            Box(
                modifier = Modifier
                    .size(width = 100.dp, height = 80.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(HimalayanDesertSand)
                    .clickable(onClick = onPlayPauseClick),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = if (isPlaying) "Pause" else "Play",
                    tint = HimalayanCharcoal,
                    modifier = Modifier.size(32.dp)
                )
            }

            // Next Button
            ControlSquare(
                icon = Icons.Default.SkipNext,
                onClick = onNextClick,
                isPrimary = false
            )
        }
    }
}

@Composable
fun TechnicalReadout(label: String, value: String, unit: String? = null) {
    Column {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = HimalayanGrey,
            fontSize = 10.sp
        )
        Row(verticalAlignment = Alignment.Bottom) {
            Text(
                text = value,
                style = MaterialTheme.typography.labelLarge,
                color = HimalayanWhite,
                fontSize = 18.sp
            )
            if (unit != null) {
                Spacer(modifier = Modifier.width(2.dp))
                Text(
                    text = unit,
                    style = MaterialTheme.typography.labelSmall,
                    color = HimalayanGrey,
                    fontSize = 10.sp
                )
            }
        }
    }
}

@Composable
fun ControlSquare(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit,
    isPrimary: Boolean = false
) {
    Box(
        modifier = Modifier
            .size(width = 80.dp, height = 60.dp)
            .clip(RoundedCornerShape(2.dp))
            .background(if (isPrimary) HimalayanDesertSand else Color(0xFF2C2C2C))
            .border(1.dp, if (isPrimary) Color.Transparent else HimalayanGrey.copy(alpha = 0.3f), RoundedCornerShape(2.dp))
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = if (isPrimary) HimalayanCharcoal else HimalayanWhite,
            modifier = Modifier.size(24.dp)
        )
    }
}
