import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../data/settings_local_repository.dart';
import '../../budgets/data/budget_local_repository.dart';
import '../models/user_profile_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repo = SettingsLocalRepository();
  final _budgetRepo = BudgetLocalRepository();
  final _imagePicker = ImagePicker();
  
  bool _showTaxes = true;
  String _currency = 'MXN';
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final profile = _repo.getProfile();
    _businessController.text = profile.businessName;
    _phoneController.text = profile.phone;
    _logoPath = profile.logoPath;
    _currency = profile.currency;
    _showTaxes = profile.showTaxes;
  }

  @override
  void dispose() {
    _businessController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo_library, color: AppColors.primary),
              ),
              title: const Text('Galería'),
              subtitle: const Text('Seleccionar desde tus fotos'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text('Cámara'),
              subtitle: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (image != null) {
        // Eliminar logo anterior si existe
        if (_logoPath != null) {
          try {
            final File oldFile = File(_logoPath!);
            if (oldFile.existsSync()) {
              oldFile.deleteSync();
            }
          } catch (e) {
            // Ignorar errores al eliminar
          }
        }

        // Copiar la imagen al directorio de documentos de la app
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String extension = path.extension(image.path);
        final String newPath = path.join(appDocDir.path, 'logo_$timestamp$extension');
        
        // Copiar el archivo
        final File sourceFile = File(image.path);
        final File newFile = await sourceFile.copy(newPath);
        
        setState(() {
          _logoPath = newFile.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Logo agregado correctamente'),
                  ),
                ],
              ),
              backgroundColor: AppColors.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error al seleccionar imagen: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeLogo() {
    if (_logoPath != null) {
      try {
        final File logoFile = File(_logoPath!);
        if (logoFile.existsSync()) {
          logoFile.deleteSync();
        }
      } catch (e) {
        // Ignorar errores al eliminar
      }
    }
    setState(() {
      _logoPath = null;
    });
  }

  void _save() {
    final profile = UserProfileModel(
      businessName: _businessController.text,
      phone: _phoneController.text,
      logoPath: _logoPath,
      currency: _currency,
      showTaxes: _showTaxes,
    );

    _repo.saveProfile(profile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text('Tu perfil quedó guardado localmente'),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    // Volver automáticamente a HomeScreen después de guardar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _deleteAllBudgets() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar todos los presupuestos'),
        content: const Text(
          '¿Estás seguro? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar borrado de todos los presupuestos
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Presupuestos eliminados'),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.settings,
              size: 24,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Logo primero — protagonista
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu logo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: _showImageSourceDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _logoPath != null
                            ? AppColors.secondary.withOpacity(0.35)
                            : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: _logoPath != null && File(_logoPath!).existsSync()
                        ? Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Image.file(
                                    File(_logoPath!),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image,
                                        color: Colors.grey.shade300,
                                        size: 48,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 14,
                                right: 14,
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: _showImageSourceDialog,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 36,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Toca para agregar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Galería o cámara',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                if (_logoPath != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Eliminar logo'),
                            content: const Text(
                              '¿Quieres quitar el logo? No se verá en presupuestos nuevos.',
                              style: TextStyle(fontSize: 14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _removeLogo();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                                          SizedBox(width: 12),
                                          Expanded(child: Text('Logo eliminado')),
                                        ],
                                      ),
                                      backgroundColor: AppColors.secondary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      label: Text(
                        'Quitar logo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Empresa — tarjeta suave
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _businessController,
                  decoration: InputDecoration(
                    hintText: 'Ej: PresuYa Servicios',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Text(
                  'Teléfono / WhatsApp',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ej: 11 1234 5678',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PDF — tarjeta suave
          _SectionCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Moneda',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _currency,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'ARS', child: Text('ARS - \$')),
                        DropdownMenuItem(value: 'BRL', child: Text('BRL - R\$')),
                        DropdownMenuItem(value: 'MXN', child: Text('MXN - \$')),
                        DropdownMenuItem(value: 'USD', child: Text('USD - \$')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR - €')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _currency = value);
                      },
                    ),
                  ],
                ),
                Divider(height: 28, color: Colors.grey.shade200),
                Row(
                  children: [
                    Text(
                      'Impuestos en PDF',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _showTaxes,
                      onChanged: (value) => setState(() => _showTaxes = value),
                      activeColor: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Datos — tarjeta suave
          _SectionCard(
            child: InkWell(
              onTap: _deleteAllBudgets,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Borrar todos los presupuestos',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 22),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // App — tarjeta suave (solo versión)
          _SectionCard(
            child: Row(
              children: [
                Text(
                  'Versión',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  AppConstants.appVersion,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Guardar
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Guardar cambios',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Tarjeta suave para agrupar secciones
class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

