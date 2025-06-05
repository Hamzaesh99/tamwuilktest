package com.example.tamwuilktest

import android.app.Application
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // تهيئة Facebook SDK
        FacebookSdk.sdkInitialize(applicationContext)
        AppEventsLogger.activateApp(this)
    }
}