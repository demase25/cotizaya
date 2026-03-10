import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:downloadsfolder/downloadsfolder.dart';
import '../../pdf/services/pdf_generator_service.dart';
import '../models/budget_item_model.dart';
import '../../../core/constants/colors.dart';

class PreviewPdfScreen extends StatefulWidget {
  final String clientName;
  final List<BudgetItemModel> items;
  final double total;
  final String? budgetId; // ID del presupuesto si ya existe

  const PreviewPdfScreen({
    super.key,
    required this.clientName,
    required this.items,
    required this.total,
    this.budgetId,
  });

  @override
  State<PreviewPdfScreen> createState() => _PreviewPdfScreenState();
}

class _PreviewPdfScreenState extends State<PreviewPdfScreen> {
  bool _isGenerating = false;

  String get _fileName {
    final clientSlug = widget.clientName.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\-]'), '');
    return 'presupuesto_${clientSlug}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  Future<void> _savePdf(BuildContext context) async {
    try {
      final pdf = await PdfGeneratorService.generateBudgetPdf(
        clientName: widget.clientName,
        items: widget.items,
        total: widget.total,
      );
      final pdfBytes = Uint8List.fromList(await pdf.save());
      await _saveToDownloads(context, pdfBytes, _fileName);
    } catch (e) {
      if (mounted) _showError(context, 'Error al guardar: ${e.toString()}');
    }
  }

  Future<void> _saveToDownloads(BuildContext context, Uint8List pdfBytes, String fileName) async {
    bool saved = false;
    String? saveLocation;
    try {
      final downloadDir = await getDownloadDirectory();
      final presuyaDir = Directory(path.join(downloadDir.path, 'PresuYa'));
      if (!await presuyaDir.exists()) await presuyaDir.create(recursive: true);
      final file = File(path.join(presuyaDir.path, fileName));
      await file.writeAsBytes(pdfBytes);
      saved = true;
      saveLocation = 'Descargas/PresuYa';
    } catch (_) {
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(path.join(tempDir.path, fileName));
        await tempFile.writeAsBytes(pdfBytes);
        saved = await copyFileIntoDownloadFolder(tempFile.path, fileName) ?? false;
        try { await tempFile.delete(); } catch (_) {}
        if (saved) saveLocation = 'Descargas';
      } catch (_) {
        final dir = await getApplicationDocumentsDirectory();
        await File(path.join(dir.path, fileName)).writeAsBytes(pdfBytes);
        saved = true;
        saveLocation = null;
      }
    }
    if (mounted && saved) {
      _showSuccess(context, saveLocation != null ? 'PDF guardado en $saveLocation' : 'PDF guardado');
    } else if (!saved && mounted) {
      _showError(context, 'No se pudo guardar en Descargas');
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text(
          'Vista Previa del PDF',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.picture_as_pdf,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con ícono PDF y nombre de archivo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'presupuesto.pdf',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Presupuesto para ${widget.clientName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Revisá antes de compartir',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vista previa del PDF con "hoja" blanca centrada
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isGenerating
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        key: const ValueKey('pdf-preview'),
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PdfPreview(
                            build: (format) async {
                              setState(() => _isGenerating = true);
                              try {
                                final pdf = await PdfGeneratorService.generateBudgetPdf(
                                  clientName: widget.clientName,
                                  items: widget.items,
                                  total: widget.total,
                                );
                                return pdf.save();
                              } finally {
                                if (mounted) {
                                  setState(() => _isGenerating = false);
                                }
                              }
                            },
                            padding: EdgeInsets.zero,
                            allowPrinting: true,
                            allowSharing: false,
                            canChangePageFormat: false,
                            canChangeOrientation: false,
                            canDebug: false,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Enviar por WhatsApp'),
                onPressed: () async {
                  try {
                    // Generar el PDF
                    final pdf = await PdfGeneratorService.generateBudgetPdf(
                      clientName: widget.clientName,
                      items: widget.items,
                      total: widget.total,
                    );
                    final pdfBytes = await pdf.save();

                    // Guardar temporalmente el PDF
                    final tempDir = await getTemporaryDirectory();
                    final fileName = 'presupuesto_${widget.clientName.replaceAll(' ', '_')}.pdf';
                    final filePath = path.join(tempDir.path, fileName);
                    final file = File(filePath);
                    await file.writeAsBytes(pdfBytes);

                    // Abrir WhatsApp directamente usando método nativo
                    const platform = MethodChannel('com.presuya.app/whatsapp');
                    try {
                      await platform.invokeMethod('shareToWhatsApp', {
                        'filePath': filePath,
                        'text': 'Presupuesto para ${widget.clientName}',
                      });
                    } catch (e) {
                      // Si falla (por ejemplo en iOS o si WhatsApp no está instalado), mostrar error
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.toString().contains('WHATSAPP_NOT_INSTALLED')
                                        ? 'WhatsApp no está instalado en tu dispositivo'
                                        : 'Error al abrir WhatsApp: ${e.toString()}',
                                  ),
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
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Error al generar PDF: ${e.toString()}'),
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
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Guardar PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _savePdf(context),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Compartir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () async {
                  try {
                    // Generar el PDF
                    final pdf = await PdfGeneratorService.generateBudgetPdf(
                      clientName: widget.clientName,
                      items: widget.items,
                      total: widget.total,
                    );
                    final pdfBytes = await pdf.save();

                    // Compartir usando el diálogo nativo del sistema
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: 'presupuesto_${widget.clientName.replaceAll(' ', '_')}.pdf',
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Error al compartir: ${e.toString()}'),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
