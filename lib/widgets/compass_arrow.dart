import 'dart:math';

import 'package:flutter/material.dart';

class CompassArrow extends StatelessWidget {
  const CompassArrow({
    super.key,
    required this.qiblaBearing,
    this.deviceHeading,
    this.size = 260,
  });

  final double qiblaBearing;
  final double? deviceHeading;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final arrowRotation = deviceHeading != null
        ? (qiblaBearing - deviceHeading!) * pi / 180
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
              ..._directionLabels(theme),
              Transform.rotate(
                angle: arrowRotation,
                child: CustomPaint(
                  size: Size(size * 0.7, size * 0.7),
                  painter: _QiblaArrowPainter(
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
              Icon(
                Icons.my_location,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${qiblaBearing.round()}°',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          deviceHeading == null
              ? 'Calibrating compass...'
              : 'Point your device toward the arrow',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _directionLabels(ThemeData theme) {
    const labels = {
      'N': Alignment.topCenter,
      'E': Alignment.centerRight,
      'S': Alignment.bottomCenter,
      'W': Alignment.centerLeft,
    };

    return labels.entries.map((entry) {
      return Align(
        alignment: entry.value,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            entry.key,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _QiblaArrowPainter extends CustomPainter {
  _QiblaArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(center.dx - 16, size.height * 0.55)
      ..lineTo(center.dx, size.height * 0.42)
      ..lineTo(center.dx + 16, size.height * 0.55)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _QiblaArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
