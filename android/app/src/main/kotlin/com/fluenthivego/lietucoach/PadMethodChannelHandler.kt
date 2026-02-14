package com.fluenthivego.lietucoach

import android.app.Activity
import com.google.android.play.core.assetpacks.AssetPackManager
import com.google.android.play.core.assetpacks.AssetPackManagerFactory
import com.google.android.play.core.assetpacks.AssetPackState
import com.google.android.play.core.assetpacks.model.AssetPackStatus
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executor
import java.util.concurrent.Executors

/**
 * Safe wrapper for MethodChannel.Result to ensure it is only called once.
 */
class SafeResult(private val result: MethodChannel.Result) : MethodChannel.Result {
    private var called = false

    override fun success(res: Any?) {
        if (!called) {
            called = true
            result.success(res)
        }
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        if (!called) {
            called = true
            result.error(errorCode, errorMessage, errorDetails)
        }
    }

    override fun notImplemented() {
        if (!called) {
            called = true
            result.notImplemented()
        }
    }
}

class PadMethodChannelHandler(
    private val activity: Activity,
    private val methodChannel: MethodChannel,
    private val eventChannel: EventChannel
) : MethodChannel.MethodCallHandler {

    private val assetPackManager: AssetPackManager by lazy {
        AssetPackManagerFactory.getInstance(activity.applicationContext)
    }

    private val executor: Executor = Executors.newSingleThreadExecutor()
    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                registerPackListener()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    private fun registerPackListener() {
        try {
            assetPackManager.registerListener { state ->
                val status = when (state.status()) {
                    AssetPackStatus.PENDING -> "pending"
                    AssetPackStatus.DOWNLOADING -> "downloading"
                    AssetPackStatus.TRANSFERRING -> "downloading"
                    AssetPackStatus.COMPLETED -> "installed"
                    AssetPackStatus.FAILED -> "failed"
                    AssetPackStatus.CANCELED -> "failed"
                    AssetPackStatus.WAITING_FOR_WIFI -> "downloading"
                    AssetPackStatus.NOT_INSTALLED -> "not_installed"
                    else -> "unknown"
                }

                val progressMap = mapOf(
                    "packName" to state.name(),
                    "status" to status,
                    "bytesDownloaded" to state.bytesDownloaded(),
                    "totalBytes" to state.totalBytesToDownload()
                )
                
                activity.runOnUiThread {
                    eventSink?.success(progressMap)
                }
            }
        } catch (e: Exception) {
            // Silently fail or log for listener registration
        }
    }

    override fun onMethodCall(call: MethodCall, rawResult: MethodChannel.Result) {
        val result = SafeResult(rawResult)
        
        try {
            when (call.method) {
                "getPackStatus" -> {
                    val packName = call.argument<String>("packName")
                    if (packName == null) {
                        result.error("INVALID_ARGUMENT", "Pack name is required", null)
                        return
                    }
                    
                    val packLocation = assetPackManager.getPackLocation(packName)
                    if (packLocation != null) {
                        result.success("installed")
                    } else {
                        result.success("not_installed")
                    }
                }

                "requestDownload" -> {
                    val packName = call.argument<String>("packName")
                    if (packName == null) {
                        result.error("INVALID_ARGUMENT", "Pack name is required", null)
                        return
                    }

                    assetPackManager.fetch(listOf(packName))
                        .addOnSuccessListener {
                            // Only notify success if not already done
                            result.success(null)
                        }
                        .addOnFailureListener { e ->
                            result.error("DOWNLOAD_FAILED", e.message, null)
                        }
                }

                "getPackPath" -> {
                    val packName = call.argument<String>("packName")
                    if (packName == null) {
                        result.error("INVALID_ARGUMENT", "Pack name is required", null)
                        return
                    }

                    val packLocation = assetPackManager.getPackLocation(packName)
                    if (packLocation == null) {
                        result.success(null) 
                    } else {
                        result.success(packLocation.assetsPath())
                    }
                }
                
                "getPackSize" -> {
                      result.success(null)
                }

                "cancelDownload" -> {
                    val packName = call.argument<String>("packName")
                    if (packName != null) {
                        assetPackManager.cancel(listOf(packName))
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Pack name required", null)
                    }
                }

                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("NATIVE_EXCEPTION", e.message, e.toString())
        }
    }
}
