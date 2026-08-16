/// Eşya Tipleri ve The Kiln (Mağaza) kataloğu.
enum ItemType {
  estusFlask(
    id: 'estus_flask',
    name: 'Estus Flask',
    nameTr: 'Can Şişesi',
    cost: 50,
    iconName: 'local_drink',
    description: 'Yaralarını sarar ve 40 HP yeniler (Maksimum canı aşamaz).',
  ),
  ashenEstus(
    id: 'ashen_estus',
    name: 'Ashen Estus',
    nameTr: 'Kül Şişesi',
    cost: 40,
    iconName: 'electric_bolt',
    description: 'Tükenen iradeni ve günlük Stamina\'nı tamamen doldurur.',
  ),
  purgingStone(
    id: 'purging_stone',
    name: 'Purging Stone',
    nameTr: 'Arınma Taşı',
    cost: 70,
    iconName: 'shield',
    description:
        'Kullanıldığında o gün ihmal edilen 1 görevin gün sonu HP cezasını engeller.',
  ),
  ringOfSacrifice(
    id: 'ring_of_sacrifice',
    name: 'Ring of Sacrifice',
    nameTr: 'Fedakarlık Yüzüğü',
    cost: 150,
    iconName: 'fingerprint',
    description:
        'Envanterdeyken ölüm halinde Gün Serisi sıfırlanır ancak elindeki tüm Öz\'ler korunur (Ash Mark oluşmaz). Dirilirken yok olur.',
  ),
  scrollOfStasis(
    id: 'scroll_of_stasis',
    name: 'Scroll of Stasis',
    nameTr: 'Zaman Tomarı',
    cost: 300,
    iconName: 'hourglass_full',
    description:
        'Mevcut günü dondurur. O gün görev yapılmasa bile HP düşmez, seri bozulmaz (Tatil / Hastalık modu).',
  );

  const ItemType({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.cost,
    required this.iconName,
    required this.description,
  });

  final String id;
  final String name;
  final String nameTr;
  final int cost;
  final String iconName;
  final String description;

  static ItemType fromId(String id) => ItemType.values.firstWhere(
        (item) => item.id == id,
        orElse: () => ItemType.estusFlask,
      );
}

class ShopItem {
  const ShopItem({
    required this.type,
    required this.stock,
  });

  final ItemType type;
  final int stock;

  String get id => type.id;
  String get name => type.name;
  String get nameTr => type.nameTr;
  int get cost => type.cost;
  String get description => type.description;
  String get iconName => type.iconName;

  static List<ShopItem> get defaultKilnCatalog => ItemType.values
      .map((type) => ShopItem(type: type, stock: -1)) // -1 = Unlimited in kiln
      .toList();
}
