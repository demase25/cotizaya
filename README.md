# PresuYa 📱

Aplicación móvil de cotizaciones rápida y eficiente desarrollada con Flutter. Crea presupuestos, genera PDFs profesionales y compártelos con tus clientes.

## 🚀 Características

- ✅ **Crear presupuestos rápidamente** - Interfaz intuitiva para crear cotizaciones en segundos
- 📄 **Generar PDFs profesionales** - Exporta tus presupuestos en formato PDF con múltiples monedas (ARS, BRL, MXN, USD, EUR)
- 💾 **Almacenamiento local** - Todos tus datos se guardan localmente usando Hive
- 📥 **Guardar PDFs** - Guarda directamente en el celular (Descargas/PresuYa)
- 🎨 **Diseño moderno** - Interfaz limpia y profesional
- 📊 **Gestión de presupuestos** - Organiza tus presupuestos por estado (Pendiente/Cobrado)
- 🖼️ **Logo personalizado** - Agrega el logo de tu negocio a los PDFs (PresuYa PRO)
- 📱 **Compartir por WhatsApp** - Envía presupuestos directamente a tus clientes
- 🔄 **Autocompletado** - Sugerencias de clientes e ítems usados recientemente
- 📱 **Multiplataforma** - Funciona en Android, iOS, Web, Windows, macOS y Linux

## 📋 Requisitos

- Flutter SDK 3.10.4 o superior
- Dart SDK 3.10.4 o superior

## 🛠️ Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/demase25/cotizaya.git
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
- `downloadsfolder` - Guardar PDFs en carpeta Descargas del celular
- `share_plus` - Compartir archivos

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
- Autocompletado de nombres de clientes usados anteriormente
- Chips de ítems recientes para añadir productos/servicios rápidamente
- Ver todos los presupuestos organizados por estado (Todos, Pendientes, Cobrados)
- Marcar presupuestos como cobrados
- Eliminar presupuesto individual (menú de 3 puntos en cada tarjeta)
- Borrar todos los presupuestos desde Configuración
- Vista previa antes de generar PDF
- Límite de 5 presupuestos/mes en versión gratuita (PresuYa PRO para más)

### Generación de PDFs
- Exportar presupuestos en formato PDF
- Vista previa del PDF antes de guardar o compartir
- **Guardar PDF**: guarda directamente en el celular (Descargas/PresuYa)
- **Compartir**: envía por WhatsApp o diálogo nativo del sistema
- Incluir logo personalizado (PresuYa PRO)
- Símbolo de moneda según configuración (ARS, BRL, MXN, USD, EUR)
- Información de contacto del negocio

### Configuración
- Perfil del negocio (nombre, teléfono)
- Agregar logo personalizado (PresuYa PRO)
- Configuración de moneda (persiste al seleccionar)
- Borrar todos los presupuestos

## 🎨 Paleta de colores

- **Primario**: `#1E3A8A` (Azul profundo)
- **Secundario**: `#22C55E` (Verde éxito)
- **Pendiente**: `#EF4444` (Rojo)
- **Cobrado**: `#22C55E` (Verde)

## 📝 Changelog

### v1.0.0 (2025)
- **Correcciones**: Eliminación correcta de presupuestos (solo el seleccionado), botón "Borrar todos" en Settings funcional, moneda persiste al elegir
- **PDFs**: Guardar directamente en el celular (Descargas/PresuYa), botón Compartir para enviar por WhatsApp u otras apps
- **UX**: Autocompletado de clientes, ítems recientes, límite PRO (5 presupuestos/mes)

## 📄 Licencia

Este proyecto es privado y está bajo desarrollo.

## 👨‍💻 Autor

Desarrollado con ❤️ usando Flutter

---

**Nota**: Este proyecto está en desarrollo activo. Las funcionalidades pueden cambiar.
