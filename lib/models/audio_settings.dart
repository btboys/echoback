class AudioSettings {
  double volume;
  int pitchShiftSemitones;
  double reverbMix;
  bool isMonitoring;

  AudioSettings({
    this.volume = 0.8,
    this.pitchShiftSemitones = 0,
    this.reverbMix = 0.0,
    this.isMonitoring = false,
  });

  AudioSettings copyWith({
    double? volume,
    int? pitchShiftSemitones,
    double? reverbMix,
    bool? isMonitoring,
  }) =>
      AudioSettings(
        volume: volume ?? this.volume,
        pitchShiftSemitones: pitchShiftSemitones ?? this.pitchShiftSemitones,
        reverbMix: reverbMix ?? this.reverbMix,
        isMonitoring: isMonitoring ?? this.isMonitoring,
      );
}
