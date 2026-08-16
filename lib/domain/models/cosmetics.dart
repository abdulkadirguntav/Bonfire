/// Data model for Phase 3 End-Game cosmetics (Bonfire Auras).
class BonfireAura {
  const BonfireAura({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.cost,
    required this.description,
  });

  final String id;
  final String name;
  final String colorHex;
  final int cost;
  final String description;

  static const List<BonfireAura> defaultAuras = [
    BonfireAura(
      id: 'ember_standard',
      name: 'Közün Ateşi (Standard)',
      colorHex: '#E25822',
      cost: 0,
      description: 'Klasik sönmeyen köz alevi.',
    ),
    BonfireAura(
      id: 'void_purple',
      name: 'Boşluk Alevi (Void Purple)',
      colorHex: '#8A2BE2',
      cost: 500,
      description: 'Derin karanlıktan yükselen eflatun alevler.',
    ),
    BonfireAura(
      id: 'abyssal_blue',
      name: 'Uçurum Ateşi (Abyssal Blue)',
      colorHex: '#00BFFF',
      cost: 1000,
      description: 'Kadim soğuk ve sönmeyen masmavi ışık.',
    ),
    BonfireAura(
      id: 'radiant_gold',
      name: 'Güneşin İradesi (Radiant Gold)',
      colorHex: '#FFD700',
      cost: 2000,
      description: 'Güneşin şövalyelerine layık kutsal altın parıltı.',
    ),
  ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorHex': colorHex,
        'cost': cost,
        'description': description,
      };

  factory BonfireAura.fromJson(Map<String, dynamic> json) => BonfireAura(
        id: json['id'] as String? ?? 'ember_standard',
        name: json['name'] as String? ?? '',
        colorHex: json['colorHex'] as String? ?? '#E25822',
        cost: json['cost'] as int? ?? 0,
        description: json['description'] as String? ?? '',
      );
}

/// Data model for Phase 3 Titles.
class UserTitle {
  const UserTitle({
    required this.id,
    required this.title,
    required this.cost,
    required this.unlockRequirement,
  });

  final String id;
  final String title;
  final int cost;
  final String unlockRequirement;

  static const List<UserTitle> defaultTitles = [
    UserTitle(
      id: 'ashen_one',
      title: 'Ashen One (Küllerin Sahibi)',
      cost: 0,
      unlockRequirement: 'Başlangıç Unvanı',
    ),
    UserTitle(
      id: 'unyielding',
      title: 'The Unyielding (Yenilmez İrade)',
      cost: 300,
      unlockRequirement: '14 Günlük Seri',
    ),
    UserTitle(
      id: 'lord_of_cinder',
      title: 'Lord of Cinder (Küllerin Efendisi)',
      cost: 1000,
      unlockRequirement: '30 Günlük Seri ve 1 Boss Aşaması',
    ),
    UserTitle(
      id: 'flame_keeper',
      title: 'Flame Keeper (Alev Muhafızı)',
      cost: 2500,
      unlockRequirement: 'End-Game Hedefi',
    ),
  ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cost': cost,
        'unlockRequirement': unlockRequirement,
      };

  factory UserTitle.fromJson(Map<String, dynamic> json) => UserTitle(
        id: json['id'] as String? ?? 'ashen_one',
        title: json['title'] as String? ?? '',
        cost: json['cost'] as int? ?? 0,
        unlockRequirement: json['unlockRequirement'] as String? ?? '',
      );
}
