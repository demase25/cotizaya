import 'package:cotiza_ya/core/constants/app_constants.dart';
import 'package:cotiza_ya/core/utils/formatters.dart';

class CurrencyUtils {
  static double parseAmount(String value) {
    if (value.isEmpty) return 0.0;
    
    // Remove currency symbols and spaces
    String cleaned = value
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    
    try {
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }
  
  static String formatAmount(double amount) {
    return Formatters.formatCurrency(amount);
  }
  
  static String formatAmountInput(double amount) {
    if (amount == 0.0) return '';
    return amount.toStringAsFixed(2);
  }
  
  static bool isValidAmount(String value) {
    if (value.isEmpty) return false;
    final amount = parseAmount(value);
    return amount > 0 && amount <= AppConstants.maxAmount;
  }
  
  static double calculateTotal(List<double> amounts) {
    return amounts.fold(0.0, (sum, amount) => sum + amount);
  }
  
  static double calculateSubtotal(double total, double tax) {
    return total / (1 + (tax / 100));
  }
  
  static double calculateTax(double subtotal, double taxRate) {
    return subtotal * (taxRate / 100);
  }
}
