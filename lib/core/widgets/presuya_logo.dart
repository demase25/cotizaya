import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PresuYaLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final double textSize;
  final bool lightBackground; // Para fondos claros (true) u oscuros (false)

  const PresuYaLogo({
    super.key,
    this.size,
    this.showText = true,
    this.textSize = 24,
    this.lightBackground = true,
  });

  /// Widget solo con el icono (sin texto) - útil para iconos launcher
  static Widget iconOnly({
    double? size,
    bool lightBackground = true,
  }) {
    final logoSize = size ?? 48.0;
    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Stack(
        children: [
          // Líneas curvas azules (velocidad/movimiento)
          Positioned(
            left: 2,
            top: logoSize * 0.3,
            child: CustomPaint(
              size: Size(logoSize * 0.6, logoSize * 0.4),
              painter: _SpeedLinesPainter(
                color: lightBackground ? AppColors.primary : Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          // Estrellas/brillos azules
          ..._buildSparklesStatic(logoSize, lightBackground),
          // Checkmark verde principal con gradiente
          Center(
            child: CustomPaint(
              size: Size(logoSize * 0.7, logoSize * 0.7),
              painter: _CheckmarkPainter(),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildSparklesStatic(double size, bool lightBackground) {
    final sparkleColor = lightBackground 
        ? AppColors.primary.withOpacity(0.6)
        : Colors.white.withOpacity(0.6);
    
    return [
      // Estrella superior izquierda
      Positioned(
        left: size * 0.15,
        top: size * 0.1,
        child: _Sparkle(size: size * 0.15, color: sparkleColor),
      ),
      // Estrella inferior derecha
      Positioned(
        right: size * 0.1,
        bottom: size * 0.15,
        child: _Sparkle(size: size * 0.12, color: sparkleColor),
      ),
      // Estrella superior derecha
      Positioned(
        right: size * 0.2,
        top: size * 0.25,
        child: _Sparkle(size: size * 0.1, color: sparkleColor),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 48.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo gráfico
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: Stack(
            children: [
              // Líneas curvas azules (velocidad/movimiento)
              Positioned(
                left: 2,
                top: logoSize * 0.3,
                child: CustomPaint(
                  size: Size(logoSize * 0.6, logoSize * 0.4),
                  painter: _SpeedLinesPainter(
                    color: lightBackground ? AppColors.primary : Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              // Estrellas/brillos azules
              ..._buildSparklesStatic(logoSize, lightBackground),
              // Checkmark verde principal con gradiente
              Center(
                child: CustomPaint(
                  size: Size(logoSize * 0.7, logoSize * 0.7),
                  painter: _CheckmarkPainter(),
                ),
              ),
            ],
          ),
        ),
        // Texto "PresuYa"
        if (showText) ...[
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Presu',
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w700,
                    color: lightBackground ? AppColors.primary : Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Ya',
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Painter para las líneas de velocidad
class _SpeedLinesPainter extends CustomPainter {
  final Color color;

  _SpeedLinesPainter({this.color = AppColors.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Línea curva superior
    final path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    path1.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width,
      size.height * 0.3,
    );
    canvas.drawPath(path1, paint);

    // Línea curva inferior
    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter para el checkmark verde con gradiente
class _CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Crear gradiente verde
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.secondaryLight,
        AppColors.secondary,
        AppColors.secondaryDark,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Dibujar checkmark
    final path = Path();
    // Línea vertical del check
    path.moveTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.7);
    // Línea horizontal del check
    path.lineTo(size.width * 0.75, size.height * 0.3);

    canvas.drawPath(path, paint);

    // Agregar brillo/highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.3, size.height * 0.5);
    highlightPath.lineTo(size.width * 0.5, size.height * 0.65);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget para las estrellas/brillos
class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const _Sparkle({required this.size, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

// Painter para las estrellas
class _SparklePainter extends CustomPainter {
  final Color color;

  _SparklePainter({this.color = AppColors.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dibujar estrella de 4 puntas
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 45) * math.pi / 180;
      final x = center.dx + radius * 0.7 * math.cos(angle);
      final y = center.dy + radius * 0.7 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

