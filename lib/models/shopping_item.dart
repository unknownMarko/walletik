class ShoppingItem {
  final String id;
  final String name;
  final int quantity;
  final String category;
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.category = 'Groceries',
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'notes': notes,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      category: json['category'] as String? ?? 'Groceries',
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
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
    return other is ShoppingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, isCompleted: $isCompleted)';
  }
}
