class UserProfileModel {
  final String businessName;
  final String phone;
  final String? logoPath;
  final String currency;
  final bool showTaxes;

  UserProfileModel({
    required this.businessName,
    required this.phone,
    this.logoPath,
    this.currency = 'MXN',
    this.showTaxes = true,
  });

  Map<String, dynamic> toMap() => {
        'businessName': businessName,
        'phone': phone,
        'logoPath': logoPath,
        'currency': currency,
        'showTaxes': showTaxes,
      };

  factory UserProfileModel.fromMap(Map map) {
    return UserProfileModel(
      businessName: map['businessName'] ?? '',
      phone: map['phone'] ?? '',
      logoPath: map['logoPath'],
      currency: map['currency'] ?? 'MXN',
      showTaxes: map['showTaxes'] is bool ? map['showTaxes'] as bool : true,
    );
  }
}
