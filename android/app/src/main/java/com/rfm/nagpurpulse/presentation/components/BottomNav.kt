package com.rfm.nagpurpulse.presentation.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Assignment
import androidx.compose.material.icons.filled.Podcasts
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rfm.nagpurpulse.presentation.theme.HimalayanCharcoal
import com.rfm.nagpurpulse.presentation.theme.HimalayanDesertSand
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey

@Composable
fun NagpurPulseBottomNav(
    selectedItem: Int,
    onItemSelected: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(80.dp)
            .background(HimalayanCharcoal),
        verticalAlignment = Alignment.CenterVertically
    ) {
        val items = listOf(
            NavigationItem("GAUGES", Icons.Default.Speed),
            NavigationItem("SIGNAL", Icons.Default.Podcasts),
            NavigationItem("ENGINE", Icons.Default.Tune),
            NavigationItem("LOGS", Icons.Default.Assignment)
        )

        items.forEachIndexed { index, item ->
            val isSelected = selectedItem == index
            
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .background(if (isSelected) HimalayanDesertSand else Color.Transparent)
                    .clickable { onItemSelected(index) },
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        imageVector = item.icon,
                        contentDescription = item.label,
                        tint = if (isSelected) HimalayanCharcoal else HimalayanGrey,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = item.label,
                        style = MaterialTheme.typography.labelSmall,
                        color = if (isSelected) HimalayanCharcoal else HimalayanGrey,
                        fontSize = 11.sp
                    )
                }
            }
        }
    }
}

data class NavigationItem(val label: String, val icon: ImageVector)
