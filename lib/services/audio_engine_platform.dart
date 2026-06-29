import 'package:flutter/services.dart';

class AudioEnginePlatform {
  static const _channel = MethodChannel('cn.gson.echoback/audio_engine');

  Future<bool> startMonitoring({
    int sampleRate = 44100,
    int bufferSize = 1024,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('startMonitoring', {
        'sampleRate': sampleRate,
        'bufferSize': bufferSize,
      });
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> stopMonitoring() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopMonitoring');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> setPitchShift(int semitones) async {
    try {
      final result = await _channel.invokeMethod<bool>('setPitchShift', {
        'semitones': semitones.clamp(-12, 12),
      });
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> setReverb(double wetDryMix) async {
    try {
      final result = await _channel.invokeMethod<bool>('setReverb', {
        'wetDryMix': wetDryMix.clamp(0.0, 1.0),
      });
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> setVolume(double gain) async {
    try {
      final result = await _channel.invokeMethod<bool>('setVolume', {
        'gain': gain.clamp(0.0, 1.0),
      });
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> startSaveToFile(String path) async {
    try {
      final result = await _channel.invokeMethod<bool>('startSaveToFile', {
        'path': path,
      });
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> stopSaveToFile() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopSaveToFile');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<List<double>?> getWaveformData() async {
    try {
      final result = await _channel.invokeMethod<List>('getWaveformData');
      return result?.cast<double>();
    } on MissingPluginException {
      return null;
    }
  }

  EventChannel get waveformEventChannel =>
      const EventChannel('cn.gson.echoback/audio_engine/waveform');
}
