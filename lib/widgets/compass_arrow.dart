import 'dart:math';

import 'package:flutter/material.dart';

// -- Design tokens -------------------------------------------------------------

const _kDarkBrown1 = Color(0xFF180A00);
const _kDarkBrown2 = Color(0xFF3A1E05);
const _kGoldBright = Color(0xFFEDC85A);
const _kGoldMid = Color(0xFFC09020);
const _kGoldDark = Color(0xFF7A5005);
const _kGoldDeep = Color(0xFF3E2500);
const _kNeedleRed = Color(0xFFB71C1C);
const _kNeedleWhite = Color(0xFFEEEEEE);
const _kAlignGreen = Color(0xFF2E7D32);
const _kAmberColor = Color(0xFFF57F17);

// -- CompassArrow --------------------------------------------------------------

/// Premium gold/cream Qibla compass widget.
/// All Qibla-direction logic lives in the parent screen; this widget is
/// purely presentational and stateless.
class CompassArrow extends StatelessWidget {
  const CompassArrow({
    super.key,
    required this.qiblaBearing,
    this.deviceHeading,
    this.qiblaDiff,
    this.size = 270.0,
    this.isAligned = false,
    this.guidanceText,
    this.showCalibrationHint = false,
    this.locationLabel,
  });

  final double qiblaBearing;
  final double? deviceHeading;

  /// Signed shortest-arc diff from current heading to Qibla, in [-180, 180].
  /// Positive = turn right; negative = turn left.
  final double? qiblaDiff;

  final double size;
  final bool isAligned;
  final String? guidanceText;
  final bool showCalibrationHint;

  /// Optional city/country label shown below the bearing (e.g. "Istanbul, Turkiye").
  final String? locationLabel;

  // -- Helpers ------------------------------------------------------------------

  bool get _hasHeading => deviceHeading != null;
  bool get _isAlmost =>
      !isAligned && qiblaDiff != null && qiblaDiff!.abs() <= 10;

  Color get _kaabaColor => isAligned
      ? _kAlignGreen
      : _isAlmost
      ? _kAmberColor
      : _kGoldDark;

  Color get _guidanceColor => isAligned
      ? _kAlignGreen
      : _isAlmost
      ? _kAmberColor
      : Colors.white70;

  Color get _cardBorderColor => isAligned
      ? _kAlignGreen.withValues(alpha: 0.6)
      : _isAlmost
      ? _kAmberColor.withValues(alpha: 0.4)
      : _kGoldDark.withValues(alpha: 0.3);

  @override
  Widget build(BuildContext context) {
    // Dial rotates opposite to heading -> N stays at true north on screen.
    final dialAngle = _hasHeading ? -deviceHeading! * pi / 180 : 0.0;

    // Needle & Kaaba both point toward Qibla (= qiblaDiff from the top).
    final qiblaAngle = (_hasHeading && qiblaDiff != null)
        ? qiblaDiff! * pi / 180
        : 0.0;

    // Kaaba orbits the outer rim.
    final kaabaR = size / 2 - 14;
    final kaabaOffset = Offset(
      kaabaR * sin(qiblaAngle),
      -kaabaR * cos(qiblaAngle),
    );

    final String guidance =
        guidanceText ??
        (_hasHeading
            ? 'Point toward the Kaaba icon'
            : 'Calibrating compass...');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDarkBrown2, _kDarkBrown1, _kDarkBrown2],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _kGoldMid.withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section header
            Text(
              'QIBLA COMPASS',
              style: TextStyle(
                color: _kGoldBright.withValues(alpha: 0.55),
                fontSize: 10,
                letterSpacing: 3.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // The compass circle
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Outermost gold ring
                  _OuterRing(size: size),

                  // 2. Dark separator
                  Container(
                    width: size - 10,
                    height: size - 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kGoldDeep,
                    ),
                  ),

                  // 3. Inner gold ring
                  Container(
                    width: size - 14,
                    height: size - 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          _kGoldDark,
                          _kGoldBright,
                          _kGoldMid,
                          _kGoldBright,
                          _kGoldDark,
                        ],
                        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),

                  // 4. Cream compass face
                  Container(
                    width: size - 26,
                    height: size - 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.2, -0.25),
                        radius: 0.88,
                        colors: const [
                          Color(0xFFFFF8E5),
                          Color(0xFFF5E8C0),
                          Color(0xFFEDD498),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // 5. Rotating dial: globe grid + degree scale + labels
                  ClipOval(
                    child: SizedBox(
                      width: size - 26,
                      height: size - 26,
                      child: Transform.rotate(
                        angle: dialAngle,
                        child: CustomPaint(
                          painter: _DialPainter(),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),

                  // 6. Kaaba marker on rim (moves as phone rotates)
                  Transform.translate(
                    offset: kaabaOffset,
                    child: _KaabaMarker(color: _kaabaColor),
                  ),

                  // 7. Qibla needle (points toward Qibla)
                  Transform.rotate(
                    angle: qiblaAngle,
                    child: CustomPaint(
                      size: Size(size * 0.10, size * 0.60),
                      painter: _NeedlePainter(isAligned: isAligned),
                    ),
                  ),

                  // 8. Gold center pivot
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFF5E060), Color(0xFF9A6D10)],
                        stops: [0.25, 1.0],
                      ),
                      border: Border.all(
                        color: const Color(0xFF3E2000),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Qibla bearing number
            Text(
              '${qiblaBearing.round()}\u00b0',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w200,
                letterSpacing: 4,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Qibla Bearing',
              style: TextStyle(
                color: _kGoldBright.withValues(alpha: 0.60),
                fontSize: 12,
                letterSpacing: 2.5,
              ),
            ),
            if (locationLabel != null && locationLabel!.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                locationLabel!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Guidance card
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isAligned
                    ? _kAlignGreen.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _cardBorderColor),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  guidance,
                  key: ValueKey(guidance),
                  style: TextStyle(
                    color: _guidanceColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Calibration hint
            if (showCalibrationHint) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 13,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Low accuracy \u2014 move phone in a figure-8',
                    style: TextStyle(
                      color: Colors.orange.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -- _OuterRing ----------------------------------------------------------------

class _OuterRing extends StatelessWidget {
  const _OuterRing({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFF3E2200),
            Color(0xFFCFA020),
            Color(0xFFF0D860),
            Color(0xFFCFA020),
            Color(0xFF6A4004),
            Color(0xFFEDC85A),
            Color(0xFF3E2200),
          ],
          stops: [0.0, 0.15, 0.28, 0.48, 0.65, 0.82, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.72),
            blurRadius: 22,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: _kGoldBright.withValues(alpha: 0.15),
            blurRadius: 18,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

// -- _KaabaMarker --------------------------------------------------------------

class _KaabaMarker extends StatelessWidget {
  const _KaabaMarker({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF160800).withValues(alpha: 0.90),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 7,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(14, 14),
          painter: _KaabaPainter(color: color),
        ),
      ),
    );
  }
}

class _KaabaPainter extends CustomPainter {
  const _KaabaPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.84, h * 0.65),
      fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.30)
        ..lineTo(w / 2, 0)
        ..lineTo(w, h * 0.30)
        ..close(),
      fill,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.08, h * 0.42, w * 0.84, h * 0.10),
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _KaabaPainter old) => old.color != color;
}

// -- _NeedlePainter ------------------------------------------------------------

class _NeedlePainter extends CustomPainter {
  const _NeedlePainter({this.isAligned = false});
  final bool isAligned;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final hw = size.width * 0.44;

    // Red / green upper lobe (points toward Qibla)
    final Color topColor = isAligned ? const Color(0xFF388E3C) : _kNeedleRed;
    final redPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - hw, cy - size.height * 0.04)
      ..lineTo(cx, cy)
      ..lineTo(cx + hw, cy - size.height * 0.04)
      ..close();
    canvas.drawShadow(redPath, Colors.black, 4.0, true);
    canvas.drawPath(
      redPath,
      Paint()
        ..color = topColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, 0)
        ..lineTo(cx - hw * 0.22, cy - size.height * 0.04)
        ..lineTo(cx, cy)
        ..close(),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.fill,
    );

    // White lower lobe (opposite direction)
    final whitePath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - hw, cy + size.height * 0.04)
      ..lineTo(cx, size.height)
      ..lineTo(cx + hw, cy + size.height * 0.04)
      ..close();
    canvas.drawShadow(whitePath, Colors.black, 4.0, true);
    canvas.drawPath(
      whitePath,
      Paint()
        ..color = _kNeedleWhite
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy)
        ..lineTo(cx - hw * 0.22, cy + size.height * 0.04)
        ..lineTo(cx, size.height)
        ..close(),
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.28)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter old) =>
      old.isAligned != isAligned;
}

// -- _DialPainter --------------------------------------------------------------

/// Paints the static compass face content (globe grid + degree scale).
/// Never re-paints; only the outer [Transform.rotate] changes each frame.
class _DialPainter extends CustomPainter {
  const _DialPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    _drawGlobeGrid(canvas, center, radius);
    _drawScale(canvas, center, radius);
  }

  void _drawGlobeGrid(Canvas canvas, Offset c, double r) {
    final p = Paint()
      ..color = const Color(0xFFB8920A).withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;

    for (final frac in [-0.60, -0.30, 0.0, 0.30, 0.60]) {
      final dy = frac * r;
      final hw = sqrt(max(0.0, r * r - dy * dy));
      if (hw > 4) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy + dy),
            width: hw * 2,
            height: hw * 0.28,
          ),
          p,
        );
      }
    }

    for (int i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * pi / 6);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.20, height: r * 1.88),
        p,
      );
      canvas.restore();
    }
  }

  void _drawScale(Canvas canvas, Offset c, double r) {
    final outerR = r - 3;

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = deg * pi / 180;
      final sinA = sin(rad);
      final cosA = cos(rad);

      final bool is30 = deg % 30 == 0;
      final bool is10 = deg % 10 == 0;

      final double len = is30
          ? r * 0.09
          : is10
          ? r * 0.054
          : r * 0.030;
      final double strokeW = is30
          ? 1.5
          : is10
          ? 0.85
          : 0.50;
      final Color color = is30
          ? const Color(0xFF6B4A06)
          : is10
          ? const Color(0xFF9A7016).withValues(alpha: 0.65)
          : const Color(0xFFBB9030).withValues(alpha: 0.42);

      canvas.drawLine(
        Offset(c.dx + outerR * sinA, c.dy - outerR * cosA),
        Offset(c.dx + (outerR - len) * sinA, c.dy - (outerR - len) * cosA),
        Paint()
          ..color = color
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      if (is30) _drawLabel(canvas, c, r, deg, rad, sinA, cosA);
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset c,
    double r,
    int deg,
    double rad,
    double sinA,
    double cosA,
  ) {
    const cardinals = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    final isCardinal = cardinals.containsKey(deg);
    final text = isCardinal ? cardinals[deg]! : '$deg';
    final isNorth = deg == 0;

    final fs = isCardinal ? r * 0.118 : r * 0.088;
    final color = isNorth ? const Color(0xFFB71C1C) : const Color(0xFF5A3A06);
    final fw = isCardinal ? FontWeight.bold : FontWeight.w500;

    final labelR = r * 0.775;
    final pos = Offset(c.dx + labelR * sinA, c.dy - labelR * cosA);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fs,
          fontWeight: fw,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(rad);
    canvas.translate(-tp.width / 2, -tp.height / 2);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => false;
}
