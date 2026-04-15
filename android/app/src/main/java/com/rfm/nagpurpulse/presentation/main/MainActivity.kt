package com.rfm.nagpurpulse.presentation.main

import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import com.rfm.nagpurpulse.R
import com.rfm.nagpurpulse.databinding.ActivityMainBinding
import com.rfm.nagpurpulse.presentation.components.MiniPlayer
import com.rfm.nagpurpulse.presentation.components.NagpurPulseBottomNav
import com.rfm.nagpurpulse.presentation.player.PlayerBottomSheet
import com.rfm.nagpurpulse.presentation.theme.HimalayanCharcoal
import com.rfm.nagpurpulse.presentation.theme.NagpurPulseTheme

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val viewModel: MainViewModel by viewModels()
    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController

        setupComposeBottomArea()
    }

    override fun onStart() {
        super.onStart()
        viewModel.connectMediaController()
    }

    override fun onStop() {
        viewModel.disconnectMediaController()
        super.onStop()
    }

    private fun setupComposeBottomArea() {
        binding.composeBottomArea.setContent {
            NagpurPulseTheme {
                val currentStation by viewModel.currentStation.collectAsState()
                val isPlaying by viewModel.isPlaying.collectAsState()
                val isBuffering by viewModel.isBuffering.collectAsState()
                var selectedNavItem by remember { mutableIntStateOf(1) }

                Column(modifier = Modifier.background(HimalayanCharcoal)) {
                    NagpurPulseBottomNav(
                        selectedItem = selectedNavItem,
                        onItemSelected = { index -> 
                            selectedNavItem = index
                            when (index) {
                                0 -> navController.navigate(R.id.discoveryFragment)
                                1 -> navController.navigate(R.id.signalFragment)
                                2 -> navController.navigate(R.id.gearFragment)
                                3 -> navController.navigate(R.id.homeFragment)
                            }
                        }
                    )
                }
            }
        }
    }
}
