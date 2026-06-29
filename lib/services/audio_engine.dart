import 'dart:async';
import 'audio_engine_platform.dart';

class AudioEngine {
  final AudioEnginePlatform _platform;

  AudioEngine() : _platform = AudioEnginePlatform();

  Stream<List<double>>? _waveformStream;

  Future<bool> startMonitoring() => _platform.startMonitoring();
  Future<bool> stopMonitoring() => _platform.stopMonitoring();
  Future<bool> setPitchShift(int semitones) => _platform.setPitchShift(semitones);
  Future<bool> setReverb(double wetDryMix) => _platform.setReverb(wetDryMix);
  Future<bool> setVolume(double gain) => _platform.setVolume(gain);
  Future<bool> startSaveToFile(String path) => _platform.startSaveToFile(path);
  Future<bool> stopSaveToFile() => _platform.stopSaveToFile();

  Stream<List<double>> get waveformStream {
    _waveformStream ??= _platform.waveformEventChannel
        .receiveBroadcastStream()
        .map((event) => (event as List).cast<double>());
    return _waveformStream!;
  }
}
