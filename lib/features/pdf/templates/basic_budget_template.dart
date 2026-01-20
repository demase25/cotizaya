import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cotiza_ya/features/budgets/models/budget_item_model.dart';

pw.Widget buildBudgetPdf({
  required String clientName,
  required List<BudgetItemModel> items,
  required double total,
  required String businessName,
  required String phone,
  String? logoPath,
}) {
  // Cargar el logo si existe
  pw.ImageProvider? logoProvider;
  if (logoPath != null && logoPath.isNotEmpty) {
    try {
      final File logoFile = File(logoPath);
      if (logoFile.existsSync()) {
        final Uint8List logoBytes = logoFile.readAsBytesSync();
        logoProvider = pw.MemoryImage(logoBytes);
      }
    } catch (e) {
      // Si hay error al cargar el logo, continuar sin él
      logoProvider = null;
    }
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Header con logo y información de la empresa
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo (si existe)
          if (logoProvider != null) ...[
            pw.Container(
              width: 80,
              height: 80,
              child: pw.Image(logoProvider, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 16),
          ],
          // Información de la empresa
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  businessName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    phone,
                    style: pw.TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),

      pw.Text(
        'Presupuesto para:',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(clientName),
      pw.SizedBox(height: 16),

      pw.Table.fromTextArray(
        headers: ['Descripción', 'Precio'],
        data: items
            .map(
              (e) => [
                e.description,
                '\$${e.price.toStringAsFixed(2)}'
              ],
            )
            .toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),

      pw.SizedBox(height: 20),

      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Total: \$${total.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
