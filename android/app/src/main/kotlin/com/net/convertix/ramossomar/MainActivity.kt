package com.net.convertix.ramossomar

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        desativarEdgeToEdge()
    }

    override fun onPostResume() {
        super.onPostResume()
        desativarEdgeToEdge()
    }

    private fun desativarEdgeToEdge() {
        // Sem edge-to-edge, statusBarColor / navigationBarColor do Flutter passam a valer.
        WindowCompat.setDecorFitsSystemWindows(window, true)
    }
}
