class UserProfileModel {
  final String businessName;
  final String phone;
  final String? logoPath;

  UserProfileModel({
    required this.businessName,
    required this.phone,
    this.logoPath,
  });

  Map<String, dynamic> toMap() => {
        'businessName': businessName,
        'phone': phone,
        'logoPath': logoPath,
      };

  factory UserProfileModel.fromMap(Map map) {
    return UserProfileModel(
      businessName: map['businessName'] ?? '',
      phone: map['phone'] ?? '',
      logoPath: map['logoPath'],
    );
  }
}
