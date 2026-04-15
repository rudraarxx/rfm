package com.rfm.nagpurpulse.presentation.player

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.fragment.app.activityViewModels
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.rfm.nagpurpulse.presentation.main.MainViewModel
import com.rfm.nagpurpulse.presentation.theme.NagpurPulseTheme

class PlayerBottomSheet : BottomSheetDialogFragment() {

    private val viewModel: MainViewModel by activityViewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return ComposeView(requireContext()).apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
            setContent {
                NagpurPulseTheme {
                    PlayerContent(
                        viewModel = viewModel,
                        onClose = { dismiss() }
                    )
                }
            }
        }
    }

    companion object {
        const val TAG = "PlayerBottomSheet"
    }
}
