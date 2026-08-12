class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.healAmount,
    this.icon = '🧪',
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final int healAmount;
  final String icon;

  static ShopItem estusFlask() {
    return const ShopItem(
      id: 'estus_flask',
      name: 'Estus Flask',
      description: 'Restores a portion of HP.',
      price: 25,
      healAmount: 25,
      icon: '🧪',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'healAmount': healAmount,
        'icon': icon,
      };

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      healAmount: json['healAmount'] as int? ?? 0,
      icon: json['icon'] as String? ?? '🧪',
    );
  }
}
