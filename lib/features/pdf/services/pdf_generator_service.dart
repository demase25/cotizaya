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

    // FREE: siempre PresuYa. PRO: logo y nombre personalizados.
    final businessName = profile.isPro
        ? (profile.businessName.isEmpty ? 'PresuYa' : profile.businessName)
        : 'PresuYa';
    final logoPath = profile.isPro ? profile.logoPath : null;
    final currencySymbol = _currencySymbol(profile.currency);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return buildBudgetPdf(
            clientName: clientName,
            items: items,
            total: total,
            businessName: businessName,
            phone: profile.isPro ? profile.phone : '',
            logoPath: logoPath,
            currencySymbol: currencySymbol,
          );
        },
      ),
    );

    return pdf;
  }

  static String _currencySymbol(String code) {
    switch (code) {
      case 'ARS':
        return '\$';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return '\$';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return '\$';
    }
  }
}
