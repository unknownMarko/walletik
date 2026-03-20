class LoyaltyCard {
  final String? id;
  final String shopName;
  final String cardNumber;
  final String? description;
  final String color;
  final String barcodeFormat;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime lastUsed;

  const LoyaltyCard({
    this.id,
    required this.shopName,
    required this.cardNumber,
    this.description,
    this.color = '#0066CC',
    this.barcodeFormat = 'code128',
    this.category = 'Other',
    this.isFavorite = false,
    required this.createdAt,
    required this.lastUsed,
  });

  LoyaltyCard copyWith({
    String? id,
    String? shopName,
    String? cardNumber,
    String? description,
    String? color,
    String? barcodeFormat,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      cardNumber: cardNumber ?? this.cardNumber,
      description: description ?? this.description,
      color: color ?? this.color,
      barcodeFormat: barcodeFormat ?? this.barcodeFormat,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'cardNumber': cardNumber,
      'description': description,
      'color': color,
      'barcodeFormat': barcodeFormat,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String?,
      shopName: json['shopName'] as String? ?? '',
      cardNumber: json['cardNumber'] as String? ?? '',
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#0066CC',
      barcodeFormat: json['barcodeFormat'] as String? ?? 'code128',
      category: json['category'] as String? ?? 'Other',
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      lastUsed: _parseDateTime(json['lastUsed']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoyaltyCard &&
        other.id == id &&
        other.shopName == shopName &&
        other.cardNumber == cardNumber;
  }

  @override
  int get hashCode => Object.hash(id, shopName, cardNumber);

  @override
  String toString() {
    return 'LoyaltyCard(id: $id, shopName: $shopName, cardNumber: $cardNumber)';
  }
}
