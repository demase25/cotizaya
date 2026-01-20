# Cotiza YA! 📱

Aplicación móvil de cotizaciones rápida y eficiente desarrollada con Flutter.

## 🚀 Características

- ✅ **Crear presupuestos rápidamente** - Interfaz intuitiva para crear cotizaciones en segundos
- 📄 **Generar PDFs profesionales** - Exporta tus presupuestos en formato PDF
- 💾 **Almacenamiento local** - Todos tus datos se guardan localmente usando Hive
- 🎨 **Diseño moderno** - Interfaz limpia y profesional
- 📊 **Gestión de presupuestos** - Organiza tus presupuestos por estado (Pendiente/Cobrado)
- 🖼️ **Logo personalizado** - Agrega el logo de tu negocio a los PDFs
- 📱 **Multiplataforma** - Funciona en Android, iOS, Web, Windows, macOS y Linux

## 📋 Requisitos

- Flutter SDK 3.10.4 o superior
- Dart SDK 3.10.4 o superior

## 🛠️ Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/cotizaya.git
cd cotizaya
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## 📦 Dependencias principales

- `hive` & `hive_flutter` - Almacenamiento local
- `pdf` & `printing` - Generación y visualización de PDFs
- `image_picker` - Selección de imágenes para el logo
- `path_provider` - Gestión de rutas de archivos
- `uuid` - Generación de IDs únicos
- `intl` - Formateo de fechas y monedas

## 🏗️ Estructura del proyecto

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── budgets/
│   │   ├── models/
│   │   ├── data/
│   │   ├── screens/
│   │   └── widgets/
│   ├── pdf/
│   │   ├── services/
│   │   └── templates/
│   └── settings/
│       ├── models/
│       ├── data/
│       └── screens/
└── routes/
```

## 📱 Funcionalidades

### Gestión de Presupuestos
- Crear nuevos presupuestos con múltiples ítems
- Ver todos los presupuestos organizados por estado
- Marcar presupuestos como cobrados
- Eliminar presupuestos
- Vista previa antes de generar PDF

### Generación de PDFs
- Exportar presupuestos en formato PDF
- Incluir logo personalizado
- Información de contacto del negocio
- Compartir por WhatsApp u otras aplicaciones

### Configuración
- Perfil del negocio (nombre, teléfono)
- Agregar logo personalizado
- Configuración de moneda
- Opciones de impuestos

## 🎨 Paleta de colores

- **Primario**: `#1E3A8A` (Azul profundo)
- **Secundario**: `#22C55E` (Verde éxito)
- **Pendiente**: `#EF4444` (Rojo)
- **Cobrado**: `#22C55E` (Verde)

## 📄 Licencia

Este proyecto es privado y está bajo desarrollo.

## 👨‍💻 Autor

Desarrollado con ❤️ usando Flutter

---

**Nota**: Este proyecto está en desarrollo activo. Las funcionalidades pueden cambiar.
