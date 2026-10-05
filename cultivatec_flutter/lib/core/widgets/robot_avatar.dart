import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/data/models/robot_config.dart';
import 'package:cultivatec_flutter/screens/robot/robot_skin_editor_screen.dart';

/// Map color IDs to hex values (matching React app).
const Map<String, Color> robotColors = {
  'blue': Color(0xFF3B82F6),
  'cyan': Color(0xFF06B6D4),
  'indigo': Color(0xFF6366F1),
  'green': Color(0xFF22C55E),
  'red': Color(0xFFEF4444),
  'orange': Color(0xFFF97316),
  'pink': Color(0xFFEC4899),
  'purple': Color(0xFF8B5CF6),
  'yellow': Color(0xFFEAB308),
  'teal': Color(0xFF14B8A6),
  'gray': Color(0xFF6B7280),
  'gold': Color(0xFFD4A017),
  'lime': Color(0xFF84CC16),
  'sky': Color(0xFF38BDF8),
  'crimson': Color(0xFFDC2626),
  'mint': Color(0xFF34D399),
};

/// Default skin shown when a profile has no skin equipped, so the real image
/// skins (not the assembled parts robot) are what users see across the app.
const String kDefaultSkinId = 'skin_1';

/// Helper to resolve skin image path from a skin ID. Falls back to the default
/// skin so an image skin is always shown (the painted robot is only a last
/// resort if the asset itself fails to load).
String? _skinImagePath(String? skinId) {
  final id = (skinId == null || skinId.isEmpty) ? kDefaultSkinId : skinId;
  final match = robotSkins.where((s) => s.id == id).firstOrNull;
  return match?.imagePath;
}

/// Full-size robot avatar — shows skin image if equipped, else CustomPaint.
class RobotAvatarWidget extends StatelessWidget {
  final RobotConfig config;
  final double size;
  final bool animate;

  const RobotAvatarWidget({
    super.key,
    required this.config,
    this.size = 120,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final skinPath = _skinImagePath(config.skinImage);
    if (skinPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          skinPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackPaint(),
        ),
      );
    }
    return _fallbackPaint();
  }

  Widget _fallbackPaint() {
    final color = robotColors[config.color] ?? robotColors['blue']!;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RobotPainter(config: config, color: color),
      ),
    );
  }
}

/// Mini robot for headers/lists — shows skin image when equipped.
class RobotMiniWidget extends StatelessWidget {
  final RobotConfig? config;
  final double size;

  const RobotMiniWidget({super.key, this.config, this.size = 36});

  @override
  Widget build(BuildContext context) {
    if (config == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 3),
          color: const Color(0xFFF1F5F9),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        ),
        child: Center(
          child: Icon(Icons.smart_toy, size: size * 0.5, color: const Color(0xFF94A3B8)),
        ),
      );
    }

    final skinPath = _skinImagePath(config!.skinImage);
    final accentColor = robotColors[config!.color] ?? const Color(0xFF3B82F6);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 3),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 3 - 2),
        child: skinPath != null
            ? Image.asset(
                skinPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => RobotAvatarWidget(config: config!, size: size * 0.85),
              )
            : RobotAvatarWidget(config: config!, size: size * 0.85),
      ),
    );
  }
}

/// Custom painter for the robot. Uses simple geometric shapes
/// matching the SVG-based React robot.
class _RobotPainter extends CustomPainter {
  final RobotConfig config;
  final Color color;

  _RobotPainter({required this.config, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    canvas.save();
    canvas.scale(scale, scale * (size.height / 130) / (size.width / 100));

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw body at y=65
    _drawBody(canvas, paint, strokePaint);
    // Draw legs at y=115
    _drawLegs(canvas, paint, strokePaint);
    // Draw arms at y=72
    _drawArms(canvas, paint, strokePaint);
    // Draw head at y=2
    _drawHead(canvas, paint, strokePaint);
    // Draw eyes
    _drawEyes(canvas);
    // Draw mouth
    _drawMouth(canvas);
    // Draw accessory
    _drawAccessory(canvas, paint);

    canvas.restore();
  }

  void _drawHead(Canvas canvas, Paint fill, Paint stroke) {
    canvas.save();
    canvas.translate(0, 2);
    switch (config.head) {
      case 'square':
        canvas.drawRRect(
          RRect.fromLTRBR(22, 14, 78, 64, const Radius.circular(8)),
          fill,
        );
        break;
      case 'triangle':
        final path = Path()
          ..moveTo(50, 8)
          ..lineTo(82, 58)
          ..lineTo(18, 58)
          ..close();
        canvas.drawPath(path, fill);
        break;
      case 'cat':
        canvas.drawCircle(const Offset(50, 42), 24, fill);
        final ear1 = Path()
          ..moveTo(30, 22)
          ..lineTo(26, 4)
          ..lineTo(42, 18)
          ..close();
        final ear2 = Path()
          ..moveTo(70, 22)
          ..lineTo(74, 4)
          ..lineTo(58, 18)
          ..close();
        canvas.drawPath(ear1, fill);
        canvas.drawPath(ear2, fill);
        break;
      case 'star':
        final path = Path()..moveTo(50, 6);
        const points = [
          57.0,
          28.0,
          80.0,
          28.0,
          62.0,
          42.0,
          68.0,
          64.0,
          50.0,
          50.0,
          32.0,
          64.0,
          38.0,
          42.0,
          20.0,
          28.0,
          43.0,
          28.0
        ];
        for (int i = 0; i < points.length; i += 2) {
          path.lineTo(points[i], points[i + 1]);
        }
        path.close();
        canvas.drawPath(path, fill);
        break;
      default: // round
        canvas.drawCircle(const Offset(50, 38), 28, fill);
        break;
    }
    canvas.restore();
  }

  void _drawEyes(Canvas canvas) {
    canvas.save();
    canvas.translate(0, 2);
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;

    switch (config.eyes) {
      case 'happy':
        final p = Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        final path1 = Path()
          ..moveTo(32, 36)
          ..quadraticBezierTo(38, 28, 44, 36);
        final path2 = Path()
          ..moveTo(56, 36)
          ..quadraticBezierTo(62, 28, 68, 36);
        canvas.drawPath(path1, p);
        canvas.drawPath(path2, p);
        break;
      case 'heart':
        final heartPaint = Paint()..color = const Color(0xFFFF4B6E);
        canvas.drawCircle(const Offset(34, 35), 5, heartPaint);
        canvas.drawCircle(const Offset(66, 35), 5, heartPaint);
        break;
      default: // round
        canvas.drawCircle(const Offset(38, 38), 7, eyePaint);
        canvas.drawCircle(const Offset(62, 38), 7, eyePaint);
        canvas.drawCircle(const Offset(40, 37), 3.5, pupilPaint);
        canvas.drawCircle(const Offset(64, 37), 3.5, pupilPaint);
        // Highlight
        final highlightPaint = Paint()..color = Colors.white;
        canvas.drawCircle(const Offset(41.5, 35.5), 1.5, highlightPaint);
        break;
    }
    canvas.restore();
  }

  void _drawMouth(Canvas canvas) {
    canvas.save();
    canvas.translate(0, 2);
    final mouthPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    switch (config.mouth) {
      case 'line':
        canvas.drawLine(const Offset(40, 52), const Offset(60, 52), mouthPaint);
        break;
      case 'zigzag':
        final path = Path()
          ..moveTo(36, 52)
          ..lineTo(42, 48)
          ..lineTo(48, 52)
          ..lineTo(54, 48)
          ..lineTo(60, 52)
          ..lineTo(66, 48);
        canvas.drawPath(path, mouthPaint..strokeWidth = 2);
        break;
      case 'open':
        final ovalPaint = Paint()..color = const Color(0xFF333333);
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 52), width: 16, height: 12), ovalPaint);
        break;
      default: // smile
        final path = Path()
          ..moveTo(38, 50)
          ..quadraticBezierTo(50, 60, 62, 50);
        canvas.drawPath(path, mouthPaint);
        break;
    }
    canvas.restore();
  }

  void _drawBody(Canvas canvas, Paint fill, Paint stroke) {
    canvas.save();
    canvas.translate(0, 65);
    switch (config.body) {
      case 'rounded':
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(50, 28), width: 56, height: 52),
          fill,
        );
        break;
      case 'slim':
        canvas.drawRRect(
          RRect.fromLTRBR(35, 0, 65, 55, const Radius.circular(10)),
          fill,
        );
        break;
      case 'tank':
        canvas.drawRRect(
          RRect.fromLTRBR(20, 5, 80, 45, const Radius.circular(6)),
          fill,
        );
        final treadPaint = Paint()..color = color.withValues(alpha: 0.7);
        canvas.drawRRect(
          RRect.fromLTRBR(15, 40, 85, 52, const Radius.circular(4)),
          treadPaint,
        );
        break;
      default: // box
        canvas.drawRRect(
          RRect.fromLTRBR(25, 0, 75, 50, const Radius.circular(8)),
          fill,
        );
        break;
    }
    canvas.restore();
  }

  void _drawArms(Canvas canvas, Paint fill, Paint stroke) {
    // Left arm
    canvas.save();
    canvas.translate(4, 72);
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, 14, 30, const Radius.circular(7)),
      fill,
    );
    canvas.restore();
    // Right arm
    canvas.save();
    canvas.translate(82, 72);
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, 14, 30, const Radius.circular(7)),
      fill,
    );
    canvas.restore();
  }

  void _drawLegs(Canvas canvas, Paint fill, Paint stroke) {
    switch (config.legs) {
      case 'wheels':
        final wheelPaint = Paint()..color = const Color(0xFF555555);
        final hubPaint = Paint()..color = const Color(0xFF888888);
        canvas.drawCircle(const Offset(36, 124), 8, wheelPaint);
        canvas.drawCircle(const Offset(36, 124), 3, hubPaint);
        canvas.drawCircle(const Offset(64, 124), 8, wheelPaint);
        canvas.drawCircle(const Offset(64, 124), 3, hubPaint);
        break;
      default: // normal
        final legPaint = Paint()..color = color.withValues(alpha: 0.87);
        canvas.drawRRect(
          RRect.fromLTRBR(32, 115, 46, 130, const Radius.circular(5)),
          legPaint,
        );
        canvas.drawRRect(
          RRect.fromLTRBR(54, 115, 68, 130, const Radius.circular(5)),
          legPaint,
        );
        break;
    }
  }

  void _drawAccessory(Canvas canvas, Paint fill) {
    canvas.save();
    canvas.translate(0, 8);
    switch (config.accessory) {
      case 'crown':
        final crownPaint = Paint()..color = const Color(0xFFFFC800);
        final path = Path()
          ..moveTo(34, -2)
          ..lineTo(38, -16)
          ..lineTo(44, -6)
          ..lineTo(50, -18)
          ..lineTo(56, -6)
          ..lineTo(62, -16)
          ..lineTo(66, -2)
          ..close();
        canvas.drawPath(path, crownPaint);
        break;
      case 'antenna':
        final antennaPaint = Paint()
          ..color = color
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(50, 0), const Offset(50, -20), antennaPaint);
        canvas.drawCircle(const Offset(50, -24), 5, Paint()..color = const Color(0xFFFF4B4B));
        break;
      case 'halo':
        final haloPaint = Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(50, -10), width: 44, height: 12),
          haloPaint,
        );
        break;
      default:
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RobotPainter oldDelegate) {
    return oldDelegate.config != config || oldDelegate.color != color;
  }
}
