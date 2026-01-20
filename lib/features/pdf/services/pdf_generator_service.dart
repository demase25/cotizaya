import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../budgets/models/budget_item_model.dart';
import '../../settings/data/settings_local_repository.dart';
import '../templates/basic_budget_template.dart';

class PdfGeneratorService {
  static Future<pw.Document> generateBudgetPdf({
    required String clientName,
    required List<BudgetItemModel> items,
    required double total,
  }) async {
    final settingsRepo = SettingsLocalRepository();
    final profile = settingsRepo.getProfile();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return buildBudgetPdf(
            clientName: clientName,
            items: items,
            total: total,
            businessName: profile.businessName.isEmpty
                ? 'Cotiza YA!'
                : profile.businessName,
            phone: profile.phone,
            logoPath: profile.logoPath,
          );
        },
      ),
    );

    return pdf;
  }
}
