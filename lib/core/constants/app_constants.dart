class AppConstants {
  // App info
  static const String appName = 'Cotiza YA!';
  static const String appVersion = '1.0.0';
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Currency
  static const String defaultCurrency = 'MXN';
  static const String currencySymbol = '\$';
  
  // Budget status
  static const String statusDraft = 'draft';
  static const String statusSent = 'sent';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';
  
  // Payment status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusPaid = 'paid';
  
  // Storage keys
  static const String budgetsKey = 'budgets';
  static const String settingsKey = 'settings';
  
  // Limits
  static const int maxBudgetItems = 100;
  static const double maxAmount = 999999999.99;
}
