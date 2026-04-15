package com.rfm.nagpurpulse.presentation.util

import android.content.Context
import android.util.TypedValue
import com.rfm.nagpurpulse.domain.model.Station

fun Int.dpToPx(context: Context): Int =
    TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, this.toFloat(), context.resources.displayMetrics).toInt()

/** Returns a Glide-loadable source: local drawable res ID if available, otherwise the remote URL. */
fun Station.imageSource(context: Context): Any {
    if (localImageName.isNotEmpty()) {
        val resId = context.resources.getIdentifier(localImageName, "drawable", context.packageName)
        if (resId != 0) return resId
    }
    return faviconUrl
}
