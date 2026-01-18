package com.javiersanchez.wombo_combo

import androidx.multidex.MultiDex
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController

class MainActivity: FlutterActivity() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
    
    override fun onResume() {
        super.onResume()
        
        // Configuración adicional para edge-to-edge en Android 15+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            
            // Ocultar barras del sistema cuando no estén en uso
            val controller = window.insetsController
            if (controller != null) {
                controller.hide(WindowInsets.Type.systemBars())
                controller.systemBarsBehavior = 
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            // Para versiones anteriores
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            )
        }
    }
}