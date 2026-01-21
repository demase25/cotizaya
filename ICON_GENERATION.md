# Generación del Icono Launcher de PresuYa

## Opción 1: Usar flutter_launcher_icons (Recomendado)

1. **Crear la imagen del icono:**
   - Ejecuta la app en modo desarrollo
   - Navega a la pantalla de generación de icono (si está disponible)
   - O usa el widget `PresuYaLauncherIcon` en una pantalla temporal
   - Toma un screenshot o exporta la imagen en 1024x1024px
   - Guarda la imagen como `assets/icon/app_icon.png`

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Generar los iconos:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

## Opción 2: Generar manualmente

1. Usa el widget `PresuYaLauncherIcon` con tamaño 1024x1024
2. Toma un screenshot o exporta la imagen
3. Usa una herramienta como [App Icon Generator](https://www.appicon.co/) para generar todos los tamaños necesarios
4. Reemplaza los archivos en:
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Widget disponible

```dart
import 'package:cotiza_ya/core/widgets/presuya_launcher_icon.dart';

// Para mostrar el icono en 1024x1024
PresuYaLauncherIcon(size: 1024)
```
