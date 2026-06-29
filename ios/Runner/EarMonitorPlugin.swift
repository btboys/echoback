import Flutter
import AVFoundation

public class EarMonitorPlugin: NSObject, FlutterPlugin {
    private var audioEngine: AVAudioEngine?
    private var pitchEffect: AVAudioUnitTimePitch?
    private var reverbEffect: AVAudioUnitReverb?
    private var eventSink: FlutterEventSink?
    private var isMonitoring = false
    private let waveformQueue = DispatchQueue(label: "waveform.queue")

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "cn.gson.echoback/audio_engine",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "cn.gson.echoback/audio_engine/waveform",
            binaryMessenger: registrar.messenger()
        )
        let instance = EarMonitorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMonitoring":
            startMonitoring(call, result: result)
        case "stopMonitoring":
            stopMonitoring(result: result)
        case "setPitchShift":
            setPitchShift(call, result: result)
        case "setReverb":
            setReverb(call, result: result)
        case "setVolume":
            setVolume(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startMonitoring(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard !isMonitoring else {
            result(true)
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.allowBluetooth, .defaultToSpeaker]
            )
            try AVAudioSession.sharedInstance().setActive(true)

            let engine = AVAudioEngine()
            let pitch = AVAudioUnitTimePitch()
            let reverb = AVAudioUnitReverb()

            engine.attach(pitch)
            engine.attach(reverb)

            let input = engine.inputNode
            let output = engine.outputNode
            let format = input.outputFormat(forBus: 0)

            engine.connect(input, to: pitch, format: format)
            engine.connect(pitch, to: reverb, format: format)
            engine.connect(reverb, to: output, format: format)

            pitch.globalGain = 0.0
            reverb.wetDryMix = 0.0

            try engine.start()
            self.audioEngine = engine
            self.pitchEffect = pitch
            self.reverbEffect = reverb
            self.isMonitoring = true

            startWaveformUpdates()
            result(true)
        } catch {
            result(FlutterError(code: "AUDIO_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    private func stopMonitoring(result: @escaping FlutterResult) {
        audioEngine?.stop()
        audioEngine = nil
        pitchEffect = nil
        reverbEffect = nil
        isMonitoring = false
        result(true)
    }

    private func setPitchShift(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
           let semitones = args["semitones"] as? Float {
            pitchEffect?.pitch = semitones * 100.0
        }
        result(true)
    }

    private func setReverb(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
           let mix = args["wetDryMix"] as? Float {
            reverbEffect?.wetDryMix = mix * 100.0
        }
        result(true)
    }

    private func setVolume(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
           let gain = args["gain"] as? Float {
            pitchEffect?.globalGain = (gain - 0.5) * 24
        }
        result(true)
    }

    private func startWaveformUpdates() {
        guard let engine = audioEngine else { return }
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self = self else { return }
            let channelData = buffer.floatChannelData?[0]
            let frameLength = Int(buffer.frameLength)
            guard let data = channelData, frameLength > 0 else { return }

            let binSize = max(1, frameLength / 50)
            var levels = [Double]()
            for i in 0..<50 {
                let start = i * binSize
                let end = min(start + binSize, frameLength)
                var sum: Float = 0
                for j in start..<end {
                    sum += abs(data[j])
                }
                levels.append(Double(sum / Float(end - start)))
            }
            self.eventSink?(levels)
        }
    }
}

extension EarMonitorPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
