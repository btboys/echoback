package cn.gson.echoback.echoback

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.abs

class EarMonitorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var eventSink: EventChannel.EventSink? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var audioThread: Thread? = null
    private var isMonitoring = false
    private var reverbMix = 0f
    private var volumeGain = 0.8f
    private var wavFile: File? = null
    private var wavStream: FileOutputStream? = null
    private var totalSamplesWritten = 0

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "cn.gson.echoback/audio_engine")
        channel.setMethodCallHandler(this)

        val eventChannel = EventChannel(binding.binaryMessenger, "cn.gson.echoback/audio_engine/waveform")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopAudio()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startMonitoring" -> startMonitoring(result)
            "stopMonitoring" -> stopMonitoring(result)
            "setReverb" -> {
                reverbMix = call.argument<Number>("wetDryMix")?.toFloat() ?: 0f
                result.success(true)
            }
            "setVolume" -> {
                volumeGain = call.argument<Number>("gain")?.toFloat() ?: 0.8f
                result.success(true)
            }
            "startSaveToFile" -> {
                val path = call.argument<String>("path") ?: ""
                startWavFile(path)
                result.success(true)
            }
            "stopSaveToFile" -> {
                stopWavFile()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun startMonitoring(result: MethodChannel.Result) {
        if (!hasMicrophonePermission()) {
            result.error("PERMISSION_DENIED", "Microphone permission not granted", null)
            return
        }
        if (isMonitoring) {
            result.success(true)
            return
        }
        isMonitoring = true
        audioThread = Thread { runAudioLoop() }
        audioThread?.start()
        result.success(true)
    }

    private fun stopMonitoring(result: MethodChannel.Result) {
        stopAudio()
        result.success(true)
    }

    private fun stopAudio() {
        isMonitoring = false
        stopWavFile()
        audioThread?.interrupt()
        audioThread = null
    }

    private fun startWavFile(path: String) {
        try {
            wavFile = File(path)
            wavFile?.parentFile?.mkdirs()
            wavStream = FileOutputStream(wavFile)
            totalSamplesWritten = 0
            
            val header = ByteBuffer.allocate(44).apply {
                order(ByteOrder.LITTLE_ENDIAN)
                put('R'.code.toByte()); put('I'.code.toByte()); put('F'.code.toByte()); put('F'.code.toByte())
                putInt(0) // file size placeholder
                put('W'.code.toByte()); put('A'.code.toByte()); put('V'.code.toByte()); put('E'.code.toByte())
                put('f'.code.toByte()); put('m'.code.toByte()); put('t'.code.toByte()); put(' '.code.toByte())
                putInt(16) // fmt chunk size
                putShort(1) // PCM
                putShort(1) // mono
                putInt(44100) // sample rate
                putInt(44100 * 2) // byte rate
                putShort(2) // block align
                putShort(16) // bits per sample
                put('d'.code.toByte()); put('a'.code.toByte()); put('t'.code.toByte()); put('a'.code.toByte())
                putInt(0) // data size placeholder
            }
            wavStream?.write(header.array())
        } catch (_: Exception) {
        }
    }

    private fun stopWavFile() {
        try {
            wavStream?.flush()
            wavStream?.close()
            wavFile?.let { file ->
                if (file.length() > 44) {
                    val dataSize = file.length().toInt() - 44
                    RandomAccessFile(file, "rw").use { raf ->
                        val header = ByteBuffer.allocate(44).apply {
                            order(ByteOrder.LITTLE_ENDIAN)
                            put('R'.code.toByte()); put('I'.code.toByte()); put('F'.code.toByte()); put('F'.code.toByte())
                            putInt(dataSize + 36) // file size - 8
                            put('W'.code.toByte()); put('A'.code.toByte()); put('V'.code.toByte()); put('E'.code.toByte())
                            put('f'.code.toByte()); put('m'.code.toByte()); put('t'.code.toByte()); put(' '.code.toByte())
                            putInt(16)
                            putShort(1) // PCM
                            putShort(1) // mono
                            putInt(44100) // sample rate
                            putInt(44100 * 2) // byte rate
                            putShort(2) // block align
                            putShort(16) // bits per sample
                            put('d'.code.toByte()); put('a'.code.toByte()); put('t'.code.toByte()); put('a'.code.toByte())
                            putInt(dataSize) // data chunk size
                        }
                        raf.seek(0)
                        raf.write(header.array())
                    }
                }
            }
        } catch (_: Exception) {
        }
        wavStream = null
        wavFile = null
    }

    private fun runAudioLoop() {
        val sampleRate = 44100
        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_FLOAT
        ).coerceAtLeast(4096)

        val record = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate, AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_FLOAT, bufferSize
        )

        val trackBufferSize = AudioTrack.getMinBufferSize(
            sampleRate, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_FLOAT
        ).coerceAtLeast(4096)

        val track = AudioTrack.Builder()
            .setAudioAttributes(AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build())
            .setAudioFormat(AudioFormat.Builder()
                .setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                .setSampleRate(sampleRate)
                .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                .build())
            .setBufferSizeInBytes(trackBufferSize)
            .setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY)
            .build()

        record.startRecording()
        track.play()

        val buffer = FloatArray(bufferSize)
        val delayLineSize = (sampleRate * 0.03).toInt()
        val delayLine = FloatArray(delayLineSize)
        var delayIndex = 0

        val writeBuf = ShortArray(bufferSize)

        while (isMonitoring) {
            val read = record.read(buffer, 0, bufferSize, AudioRecord.READ_BLOCKING)
            if (read > 0) {
                val wetGain = reverbMix * 0.5f
                val dryGain = 1.0f - wetGain

                for (i in 0 until read) {
                    var s = buffer[i] * volumeGain
                    val delayed = delayLine[delayIndex]
                    buffer[i] = s * dryGain + delayed * wetGain
                    delayLine[delayIndex] = s
                    delayIndex = (delayIndex + 1) % delayLineSize
                }

                track.write(buffer, 0, read, AudioTrack.WRITE_BLOCKING)
                emitWaveform(buffer, read)

                wavStream?.let {
                    try {
                        for (i in 0 until read) {
                            val clamped = buffer[i].coerceIn(-1f, 1f)
                            writeBuf[i] = (clamped * 32767f).toInt().toShort()
                        }
                        val bb = ByteBuffer.allocate(read * 2)
                        bb.order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().put(writeBuf, 0, read)
                        it.write(bb.array())
                        totalSamplesWritten += read
                    } catch (_: Exception) {}
                }
            }
        }

        record.stop()
        record.release()
        track.stop()
        track.release()
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    private fun emitWaveform(buffer: FloatArray, size: Int) {
        val binSize = maxOf(1, size / 50)
        val levels = mutableListOf<Double>()
        for (i in 0 until 50) {
            val start = i * binSize
            val end = minOf(start + binSize, size)
            var sum = 0f
            for (j in start until end) {
                sum += abs(buffer[j])
            }
            levels.add((sum / (end - start)).toDouble())
        }
        mainHandler.post { eventSink?.success(levels) }
    }

    private fun hasMicrophonePermission(): Boolean {
        val activity = activityBinding?.activity ?: return false
        return ActivityCompat.checkSelfPermission(
            activity, Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }
}
