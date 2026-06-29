import 'dart:math' as math;
import 'package:flutter/material.dart';

class VolumeIndicator extends StatelessWidget {
  final double volume;
  final bool isActive;

  const VolumeIndicator({
    super.key,
    required this.volume,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? RadialGradient(
                    colors: [
                      Color.lerp(
                        Colors.greenAccent,
                        Colors.redAccent,
                        volume,
                      )!,
                      Colors.grey[900]!,
                    ],
                    stops: [math.max(0.1, volume * 0.8), 1.0],
                  )
                : null,
            color: isActive ? null : Colors.grey[800],
            border: Border.all(
              color: isActive
                  ? Color.lerp(
                      Colors.greenAccent,
                      Colors.redAccent,
                      volume,
                    )!.withValues(alpha: 0.6)
                  : Colors.grey[700]!,
              width: 3,
            ),
          ),
          child: Center(
            child: Icon(
              isActive ? Icons.mic : Icons.mic_none,
              size: 48,
              color: isActive ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (isActive)
          Text(
            '${(volume * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: Color.lerp(Colors.greenAccent, Colors.redAccent, volume),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
