enum ItemType {
  estusFlask(
    id: 'estus_flask',
    cost: 120,
    name: 'Estus Flask',
    nameTr: 'Can Şişesi',
    description:
        'Közün sıcaklığını taşır. Kullanıldığında anında +40 Can (HP) yeniler.',
    iconName: 'local_drink',
  ),
  ashenEstus(
    id: 'ashen_estus',
    cost: 90,
    name: 'Ashen Estus',
    nameTr: 'Kül Şişesi',
    description:
        'Sönmüş küllerin enerjisini taşır. Günlük Stamina havuzunu tamamen doldurur.',
    iconName: 'electric_bolt',
  ),
  purgingStone(
    id: 'purging_stone',
    cost: 180,
    name: 'Purging Stone',
    nameTr: 'Arınma Taşı',
    description:
        'Lanetleri ve ihmalleri temizler. O gün ihmal edilen 1 görevin gün sonu HP cezasını engeller.',
    iconName: 'shield',
  ),
  ringOfSacrifice(
    id: 'ring_of_sacrifice',
    cost: 450,
    name: 'Ring of Sacrifice',
    nameTr: 'Fedakarlık Yüzüğü',
    description:
        'Ölüm anında parçalanır. Canın sıfırlandığında Gün Serisi sıfırlanır ancak elindeki tüm Öz\'ler korunur (Ash Mark oluşmaz).',
    iconName: 'fingerprint',
  ),
  scrollOfStasis(
    id: 'scroll_of_stasis',
    cost: 800,
    name: 'Scroll of Stasis',
    nameTr: 'Zaman Tomarı',
    description:
        'Mevcut günü dondurur. O gün hiçbir görev yapılmasa dahi can düşmez ve gün serisi korunur (Tatil/Hastalık modu).',
    iconName: 'hourglass_full',
  );

  const ItemType({
    required this.id,
    required this.cost,
    required this.name,
    required this.nameTr,
    required this.description,
    required this.iconName,
  });

  final String id;
  final int cost;
  final String name;
  final String nameTr;
  final String description;
  final String iconName;

  String get nameEn => name;
  String get descriptionTr => description;
  String get descriptionEn {
    switch (this) {
      case ItemType.estusFlask:
        return 'Holds the heat of the hearth. Instantly restores +40 HP on use.';
      case ItemType.ashenEstus:
        return 'Channels the spirit of extinguished ashes. Fully restores daily Stamina.';
      case ItemType.purgingStone:
        return 'Cleanses curses and neglect. Negates end-of-day HP penalty for 1 failed vow.';
      case ItemType.ringOfSacrifice:
        return 'Shatters upon death. Preserves all Essence without leaving an Ash Mark.';
      case ItemType.scrollOfStasis:
        return 'Freezes time. Prevents streak reset and penalty damage for the day.';
    }
  }

  static ItemType fromString(String? value) {
    return ItemType.values.firstWhere(
      (type) => type.name == value || type.id == value,
      orElse: () => ItemType.estusFlask,
    );
  }
}

/// Market (The Kiln / Seyyar Tüccar) schedule and catalog
class ShopItem {
  const ShopItem({
    required this.type,
    required this.cost,
    required this.name,
    required this.nameTr,
    required this.description,
    required this.iconName,
  });

  final ItemType type;
  final int cost;
  final String name;
  final String nameTr;
  final String description;
  final String iconName;

  String get nameEn => name;
  String get descriptionTr => description;
  String get descriptionEn => type.descriptionEn;

  String get id => type.id;

  /// Market is open every 5th streak day (5, 10, 15, 20, 25, 30, 45, 60, 90...)
  static const List<int> marketMilestones = [
    5,
    10,
    15,
    20,
    25,
    30,
    45,
    60,
    90
  ];

  static bool isMarketOpenOnStreak(int streak) {
    return marketMilestones.contains(streak) || (streak > 0 && streak % 5 == 0);
  }

  static int nextMarketDay(int currentStreak) {
    if (isMarketOpenOnStreak(currentStreak)) return currentStreak;
    for (int day = currentStreak + 1; day <= currentStreak + 10; day++) {
      if (isMarketOpenOnStreak(day)) return day;
    }
    return ((currentStreak ~/ 5) + 1) * 5;
  }

  static List<ShopItem> get defaultKilnCatalog => ItemType.values
      .map(
        (type) => ShopItem(
          type: type,
          cost: type.cost,
          name: type.name,
          nameTr: type.nameTr,
          description: type.description,
          iconName: type.iconName,
        ),
      )
      .toList();
}
