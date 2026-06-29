import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/audio_engine.dart';

class AudioProvider extends ChangeNotifier {
  final AudioEngine _engine = AudioEngine();

  bool _isMonitoring = false;
  bool _isRecording = false;
  double _currentVolume = 0.0;
  int _pitchShift = 0;
  double _reverbMix = 0.0;
  double _volumeGain = 0.8;
  List<double> _waveformData = List.filled(50, 0.0);
  StreamSubscription? _waveformSub;

  bool get isMonitoring => _isMonitoring;
  bool get isRecording => _isRecording;
  double get currentVolume => _currentVolume;
  int get pitchShift => _pitchShift;
  double get reverbMix => _reverbMix;
  double get volumeGain => _volumeGain;
  List<double> get waveformData => _waveformData;

  Future<bool> toggleMonitoring() async {
    if (_isMonitoring) {
      await _engine.stopMonitoring();
      _isMonitoring = false;
      await _waveformSub?.cancel();
      _waveformSub = null;
      notifyListeners();
      return true;
    } else {
      final success = await _engine.startMonitoring();
      if (success) {
        _isMonitoring = true;
        _waveformSub = _engine.waveformStream.listen((data) {
          _waveformData = data;
          if (data.isNotEmpty) {
            final peak = data.reduce((a, b) => a > b ? a : b);
            _currentVolume = (_currentVolume * 0.3 + peak * 8.0 * 0.7)
                .clamp(0.0, 1.0);
          }
          notifyListeners();
        });
      }
      notifyListeners();
      return success;
    }
  }

  Future<void> setPitchShift(int semitones) async {
    _pitchShift = semitones.clamp(-12, 12);
    await _engine.setPitchShift(_pitchShift);
    notifyListeners();
  }

  Future<void> setReverb(double mix) async {
    _reverbMix = mix.clamp(0.0, 1.0);
    await _engine.setReverb(_reverbMix);
    notifyListeners();
  }

  Future<void> setVolume(double gain) async {
    _volumeGain = gain.clamp(0.0, 1.0);
    await _engine.setVolume(_volumeGain);
    notifyListeners();
  }

  Future<void> startSaveToFile(String path) async {
    await _engine.startSaveToFile(path);
  }

  Future<void> stopSaveToFile() async {
    await _engine.stopSaveToFile();
  }

  void setCurrentVolume(double volume) {
    _currentVolume = volume;
    notifyListeners();
  }

  void setRecording(bool recording) {
    _isRecording = recording;
    notifyListeners();
  }

  bool get hasEffectsEnabled => _pitchShift != 0 || _reverbMix > 0;

  @override
  void dispose() {
    _waveformSub?.cancel();
    _engine.stopMonitoring();
    super.dispose();
  }
}
