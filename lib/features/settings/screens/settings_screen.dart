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
  }

  @override
  void dispose() {
    _businessController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Copiar la imagen al directorio de documentos de la app
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String fileName = path.basename(image.path);
        final String newPath = path.join(appDocDir.path, 'logo_$fileName');
        
        // Copiar el archivo
        final File sourceFile = File(image.path);
        final File newFile = await sourceFile.copy(newPath);
        
        setState(() {
          _logoPath = newFile.path;
        });
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
            backgroundColor: AppColors.pending,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Sección: Empresa
          _SectionHeader(title: 'Empresa'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.business, color: AppColors.textSecondary),
                  title: const Text('Nombre del negocio'),
                  subtitle: TextField(
                    controller: _businessController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Juan Electricista',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.image_outlined, color: AppColors.textSecondary),
                  title: const Text('Logo'),
                  subtitle: Text(_logoPath != null ? 'Logo agregado' : 'Toca para agregar un logo'),
                  trailing: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _logoPath != null 
                            ? Colors.transparent 
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: _logoPath != null 
                            ? Border.all(color: Colors.grey.shade300, width: 1)
                            : null,
                      ),
                      child: _logoPath != null && File(_logoPath!).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_logoPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.broken_image,
                                    color: Colors.grey.shade400,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colors.grey.shade400,
                            ),
                    ),
                  ),
                  onTap: _pickImage,
                ),
                if (_logoPath != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.pending),
                    title: const Text('Eliminar logo'),
                    subtitle: const Text('Quitar el logo actual'),
                    onTap: () {
                      _removeLogo();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Logo eliminado'),
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
                    },
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone, color: AppColors.textSecondary),
                  title: const Text('Teléfono / WhatsApp'),
                  subtitle: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Ej: 11 1234 5678',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sección: PDF
          _SectionHeader(title: 'PDF'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.attach_money, color: AppColors.textSecondary),
                  title: const Text('Moneda'),
                  trailing: DropdownButton<String>(
                    value: _currency,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'MXN', child: Text('MXN - \$')),
                      DropdownMenuItem(value: 'USD', child: Text('USD - \$')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - €')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _currency = value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.receipt_long, color: AppColors.textSecondary),
                  title: const Text('Mostrar impuestos'),
                  subtitle: const Text('Incluir IVA en los presupuestos'),
                  trailing: Switch(
                    value: _showTaxes,
                    onChanged: (value) {
                      setState(() => _showTaxes = value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sección: Datos
          _SectionHeader(title: 'Datos'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Borrar presupuestos'),
              subtitle: const Text('Eliminar todos los presupuestos guardados'),
              onTap: _deleteAllBudgets,
            ),
          ),

          const SizedBox(height: 8),

          // Sección: App
          _SectionHeader(title: 'App'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
                  title: const Text('Versión'),
                  trailing: Text(
                    AppConstants.appVersion,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline, color: AppColors.textSecondary),
                  title: const Text('Contacto'),
                  subtitle: const Text('Soporte y ayuda'),
                  trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    // TODO: Navegar a pantalla de contacto
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón guardar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Guardar cambios'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
