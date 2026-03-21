class LoyaltyCard {
  final String? id;
  final String shopName;
  final String cardNumber;
  final String? description;
  final String color;
  final String barcodeFormat;
  final DateTime createdAt;
  final DateTime lastUsed;

  const LoyaltyCard({
    this.id,
    required this.shopName,
    required this.cardNumber,
    this.description,
    this.color = '#0066CC',
    this.barcodeFormat = 'code128',
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
    if (other is! LoyaltyCard) return false;
    // Both have id → compare by id only
    if (id != null && other.id != null) return id == other.id;
    // Fallback for cards without id (backward compat with old saved data)
    return other.id == id &&
        other.shopName == shopName &&
        other.cardNumber == cardNumber;
  }

  @override
  int get hashCode =>
      id != null ? id.hashCode : Object.hash(shopName, cardNumber);

  @override
  String toString() {
    return 'LoyaltyCard(id: $id, shopName: $shopName, cardNumber: $cardNumber)';
  }
}
