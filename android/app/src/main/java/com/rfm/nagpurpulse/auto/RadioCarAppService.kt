package com.rfm.nagpurpulse.auto

import android.content.Intent
import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator

class RadioCarAppService : CarAppService() {

    override fun createHostValidator(): HostValidator = HostValidator.ALLOW_ALL_HOSTS_VALIDATOR

    override fun onCreateSession(): Session = RadioCarSession()
}

private class RadioCarSession : Session() {
    override fun onCreateScreen(intent: Intent) = RadioCarScreen(carContext)
}
