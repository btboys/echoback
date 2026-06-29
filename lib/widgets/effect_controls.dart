import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EffectControls extends StatelessWidget {
  final int pitchShift;
  final double reverbMix;
  final double volumeGain;
  final ValueChanged<int> onPitchChanged;
  final ValueChanged<double> onReverbChanged;
  final ValueChanged<double> onVolumeChanged;

  const EffectControls({
    super.key,
    required this.pitchShift,
    required this.reverbMix,
    required this.volumeGain,
    required this.onPitchChanged,
    required this.onReverbChanged,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.effects,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSlider(
              context,
              label: l.pitch,
              value: pitchShift.toDouble(),
              min: -12,
              max: 12,
              divisions: 24,
              displayValue: l.semitones(pitchShift),
              onChanged: (v) => onPitchChanged(v.round()),
            ),
            _buildSlider(
              context,
              label: l.reverb,
              value: reverbMix,
              min: 0,
              max: 1,
              divisions: 100,
              displayValue: '${(reverbMix * 100).round()}%',
              onChanged: onReverbChanged,
            ),
            _buildSlider(
              context,
              label: l.volume,
              value: volumeGain,
              min: 0,
              max: 1,
              divisions: 100,
              displayValue: '${(volumeGain * 100).round()}%',
              onChanged: onVolumeChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

}
