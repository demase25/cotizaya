import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import '../../pdf/services/pdf_generator_service.dart';
import '../models/budget_item_model.dart';
import '../models/budget_model.dart';
import '../data/budget_local_repository.dart';
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
  final _repo = BudgetLocalRepository();

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
                  await Printing.sharePdf(
                    bytes: await (await PdfGeneratorService.generateBudgetPdf(
                      clientName: widget.clientName,
                      items: widget.items,
                      total: widget.total,
                    ))
                        .save(),
                    filename: 'presupuesto.pdf',
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Marcar como Cobrado'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.paid,
                  side: BorderSide(color: AppColors.paid),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  // Si ya existe un presupuesto, actualizar su estado
                  if (widget.budgetId != null) {
                    _repo.updateStatus(widget.budgetId!, BudgetStatus.paid);
                  } else {
                    // Si no existe, crear uno nuevo como cobrado
                    final budget = BudgetModel(
                      id: const Uuid().v4(),
                      clientName: widget.clientName.isEmpty
                          ? 'Consumidor Final'
                          : widget.clientName,
                      total: widget.total,
                      status: BudgetStatus.paid,
                      date: DateTime.now(),
                    );
                    _repo.save(budget);
                  }

                  // Mostrar mensaje de confirmación
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.budgetId != null
                                    ? 'Presupuesto marcado como cobrado'
                                    : 'Presupuesto guardado como cobrado',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.paid,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  // Volver a la pantalla anterior
                  if (mounted) {
                    Navigator.pop(context);
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
