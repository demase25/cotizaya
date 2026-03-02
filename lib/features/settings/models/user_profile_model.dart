class UserProfileModel {
  final String businessName;
  final String phone;
  final String? logoPath;
  final String currency;
  final bool showTaxes;
  final bool isPro;

  UserProfileModel({
    required this.businessName,
    required this.phone,
    this.logoPath,
    this.currency = 'MXN',
    this.showTaxes = true,
    this.isPro = false,
  });

  Map<String, dynamic> toMap() => {
        'businessName': businessName,
        'phone': phone,
        'logoPath': logoPath,
        'currency': currency,
        'showTaxes': showTaxes,
        'isPro': isPro,
      };

  factory UserProfileModel.fromMap(Map map) {
    return UserProfileModel(
      businessName: map['businessName'] ?? '',
      phone: map['phone'] ?? '',
      logoPath: map['logoPath'],
      currency: map['currency'] ?? 'MXN',
      showTaxes: map['showTaxes'] is bool ? map['showTaxes'] as bool : true,
      isPro: map['isPro'] == true,
    );
  }
}
