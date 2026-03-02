package com.presuya.app

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.presuya.app/whatsapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareToWhatsApp") {
                val filePath = call.argument<String>("filePath")
                val text = call.argument<String>("text") ?: ""
                
                if (filePath != null) {
                    try {
                        val file = File(filePath)
                        val uri = FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file
                        )
                        
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "application/pdf"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            putExtra(Intent.EXTRA_TEXT, text)
                            setPackage("com.whatsapp")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.error("WHATSAPP_NOT_INSTALLED", "WhatsApp no está instalado", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message ?: "Error desconocido", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Ruta de archivo no válida", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
