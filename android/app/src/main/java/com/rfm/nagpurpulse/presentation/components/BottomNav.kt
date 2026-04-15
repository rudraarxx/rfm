package com.rfm.nagpurpulse.presentation.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material.icons.filled.Place
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rfm.nagpurpulse.presentation.theme.DeepNavy
import com.rfm.nagpurpulse.presentation.theme.HimalayanWhite
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
            .height(72.dp)
            .background(DeepNavy),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceAround
    ) {
        val items = listOf(
            NavigationItem("RECORDS", Icons.Default.MusicNote),
            NavigationItem("SIGNAL", Icons.Default.Home),
            NavigationItem("FEEDS", Icons.Default.FavoriteBorder),
            NavigationItem("GEAR", Icons.Default.Place)
        )

        items.forEachIndexed { index, item ->
            val isSelected = selectedItem == index
            
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clickable { onItemSelected(index) },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = item.icon,
                    contentDescription = item.label,
                    tint = if (isSelected) Color(0xFF916BFF) else HimalayanGrey,
                    modifier = Modifier.size(28.dp)
                )
            }
        }
    }
}


data class NavigationItem(val label: String, val icon: ImageVector)
