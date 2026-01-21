import 'package:flutter/material.dart';
import 'presuya_logo.dart';

/// Widget que renderiza el logo de PresuYa como icono launcher
/// con fondo blanco redondeado, listo para exportar como imagen
class PresuYaLauncherIcon extends StatelessWidget {
  final double size;

  const PresuYaLauncherIcon({
    super.key,
    this.size = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22), // Rounded square
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: size * 0.05,
            offset: Offset(0, size * 0.02),
          ),
        ],
      ),
      child: Center(
        child: PresuYaLogo.iconOnly(
          size: size * 0.6,
          lightBackground: true,
        ),
      ),
    );
  }
}
