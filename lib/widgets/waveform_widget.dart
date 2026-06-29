import 'package:flutter/material.dart';

class WaveformWidget extends StatelessWidget {
  final List<double> data;
  final bool isActive;

  const WaveformWidget({
    super.key,
    required this.data,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _WaveformPainter(data, isActive),
          size: const Size(double.infinity, 100),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final bool isActive;

  _WaveformPainter(this.data, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = isActive
          ? const Color(0xFF6C63FF).withValues(alpha: 0.8)
          : Colors.grey[600]!.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final x = i * barWidth;
      final normalized = data[i].clamp(0.0, 1.0);
      final barHeight = normalized * (size.height * 0.8) / 2;

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => true;
}
