import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/attributes.dart';
import 'package:bonfire/domain/services/attribute_service.dart';
import 'package:bonfire/domain/services/shop_service.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class AshenRecordScreen extends ConsumerWidget {
  const AshenRecordScreen({super.key});

  IconData _iconForAttribute(AttributeType type) {
    switch (type) {
      case AttributeType.vitality:
        return Icons.favorite_rounded;
      case AttributeType.endurance:
        return Icons.bolt_rounded;
      case AttributeType.strength:
        return Icons.fitness_center_rounded;
      case AttributeType.adaptability:
        return Icons.shield_rounded;
    }
  }

  String _bonusTextFor(AttributeType type, int level) {
    switch (type) {
      case AttributeType.vitality:
        return '+${level * 15} Max HP';
      case AttributeType.endurance:
        return '+${level * 10} Max Stamina';
      case AttributeType.strength:
        return '+%${level * 5} Öz Çarpanı';
      case AttributeType.adaptability:
        return '-%${level * 4} Ceza Hasarı';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final isAtBonfire = user?.isAtBonfireDay ?? false;
    final essence = user?.essence ?? 0;

    return Scaffold(
      backgroundColor: GothicPalette.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with overflow-safe Expanded title
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: GothicPalette.goldBright,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'THE ASHEN RECORD',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: GothicPalette.goldBright,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: GothicPalette.ironBlack,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: GothicPalette.bronze,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.whatshot_rounded,
                          color: GothicPalette.goldBright,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$essence ÖZ',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.goldBright,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Karakter Kağıdı, Nitelikler ve Geçmişin Külleri',
                style: TextStyle(
                  color: GothicPalette.parchmentDim,
                  fontSize: 11,
                  fontFamily: GoogleFonts.cinzel().fontFamily,
                ),
              ),
              const SizedBox(height: 12),

              // Character Profile Header Card (Removed confusing extra level badge)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GothicPalette.onyx,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: GothicPalette.charcoal,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: GothicPalette.ironBlack,
                        border: Border.all(
                          color: GothicPalette.bronze,
                          width: 1.0,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: GothicPalette.goldBright,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.selectedClass.className.toUpperCase() ??
                                'SAVAŞÇI',
                            style: GoogleFonts.cinzel(
                              color: GothicPalette.goldBright,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.selectedClass.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GothicPalette.parchmentDim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Bonfire Level-Up Status Banner
              if (isAtBonfire)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1E12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GothicPalette.emberBright,
                      width: 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: GothicPalette.goldBright, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔥 BONFIRE GÜNÜNDESİN: Nitelik geliştirme (Level Up) mühürleri açıldı!',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.goldBright,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: GothicPalette.ironBlack,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: GothicPalette.charcoal,
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: GothicPalette.parchmentDim, size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mühürlü: Stat geliştirme yalnızca Bonfire günlerinde (Gün 3, 7, 14, 30) yapılabilir.',
                          style: TextStyle(
                            color: GothicPalette.parchmentDim,
                            fontSize: 10.5,
                            fontFamily: GoogleFonts.cinzel().fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              // Scrollable Character Sheet Sections
              Expanded(
                child: ListView(
                  children: [
                    // Section 1: Attributes & Level Up
                    const SectionTitle('Kadim Nitelikler (Attributes)'),
                    const SizedBox(height: 8),
                    ...AttributeType.values.map((attribute) {
                      final currentLevel = user?.attributeLevel(attribute) ?? 0;
                      final cost = user == null
                          ? 100
                          : AttributeService.getUpgradeCost(user, attribute);
                      final canAfford = isAtBonfire && essence >= cost;
                      final bonusText =
                          _bonusTextFor(attribute, currentLevel);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OrnateFrame(
                          radius: 8,
                          borderWidth: 0.6,
                          outerGradient: canAfford
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF3F321D),
                                    Color(0xFF6E5A32),
                                    Color(0xFF3F321D),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    GothicPalette.charcoal,
                                    GothicPalette.ironBlack,
                                  ],
                                ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            child: Row(
                              children: [
                                Icon(
                                  _iconForAttribute(attribute),
                                  color: canAfford
                                      ? GothicPalette.goldBright
                                      : GothicPalette.parchmentDim,
                                  size: 19,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            attribute.nameTr.toUpperCase(),
                                            style: GoogleFonts.cinzel(
                                              color: GothicPalette.goldBright,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: GothicPalette.ironBlack,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              border: Border.all(
                                                color: GothicPalette.bronze,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              'LV. $currentLevel',
                                              style: GoogleFonts.cinzel(
                                                color:
                                                    GothicPalette.parchmentLight,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${attribute.description} ($bonusText)',
                                        style: const TextStyle(
                                          color: GothicPalette.parchmentDim,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Level Up Action
                                OutlinedButton(
                                  onPressed: !canAfford
                                      ? null
                                      : () async {
                                          try {
                                            await ref
                                                .read(userControllerProvider
                                                    .notifier)
                                                .levelUp(attribute);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      GothicPalette.goldDeep,
                                                  content: Text(
                                                    '🔥 ${attribute.nameTr} seviye atladı! ($bonusText)',
                                                  ),
                                                ),
                                              );
                                            }
                                          } on InsufficientEssenceException {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Yetersiz Öz (Essence)!'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: GothicPalette.goldBright,
                                    disabledForegroundColor:
                                        GothicPalette.parchmentDim,
                                    side: BorderSide(
                                      color: canAfford
                                          ? GothicPalette.goldBright
                                          : GothicPalette.charcoal,
                                      width: 0.8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.arrow_upward_rounded,
                                              size: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            'GELİŞTİR',
                                            style: GoogleFonts.cinzel(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$cost Öz',
                                        style: TextStyle(
                                          color: canAfford
                                              ? GothicPalette.goldBright
                                              : GothicPalette.parchmentDim,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),

                    // Section 2: Lifetime Statistics (Geçmişin Külleri)
                    const SectionTitle('Geçmişin Külleri (İstatistikler)'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: GothicPalette.onyx,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: GothicPalette.charcoal,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          _StatRow(
                            icon: Icons.shield_rounded,
                            label: 'Yenilen Düşmanlar',
                            detail: 'Tamamlanan standart yeminler',
                            value: '${user?.enemiesDefeated ?? 0}',
                          ),
                          const Divider(
                              height: 1,
                              color: GothicPalette.charcoal,
                              thickness: 0.6),
                          _StatRow(
                            icon: Icons.dangerous_rounded,
                            label: 'Katledilen Boss\'lar',
                            detail: 'Aşılan bağımlılık / irade fazları',
                            value: '${user?.bossPhasesDefeated ?? 0}',
                          ),
                          const Divider(
                              height: 1,
                              color: GothicPalette.charcoal,
                              thickness: 0.6),
                          _StatRow(
                            icon: Icons.heart_broken_rounded,
                            label: 'Ölüm Sayısı',
                            detail: 'Canın sıfırlandığı anlar',
                            value: '${user?.deathCount ?? 0}',
                          ),
                          const Divider(
                              height: 1,
                              color: GothicPalette.charcoal,
                              thickness: 0.6),
                          _StatRow(
                            icon: Icons.replay_rounded,
                            label: 'Geri Alınan Kül İzleri',
                            detail: 'Kurtarılan kayıp Öz (Ash Mark)',
                            value: '${user?.ashMarksReclaimed ?? 0}',
                          ),
                          const Divider(
                              height: 1,
                              color: GothicPalette.charcoal,
                              thickness: 0.6),
                          _StatRow(
                            icon: Icons.whatshot_rounded,
                            label: 'En Yüksek İrade Serisi',
                            detail: 'Ulaşılan en uzun gün serisi rekoru',
                            value: 'Gün ${user?.highestStreak ?? 1}',
                            isGold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.detail,
    required this.value,
    this.isGold = false,
  });

  final IconData icon;
  final String label;
  final String detail;
  final String value;
  final bool isGold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Icon(icon,
              size: 17,
              color: isGold
                  ? GothicPalette.goldBright
                  : GothicPalette.parchmentDim),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    color: isGold
                        ? GothicPalette.goldBright
                        : GothicPalette.parchmentLight,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(
                    color: GothicPalette.parchmentDim,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cinzel(
              color: isGold
                  ? GothicPalette.goldBright
                  : GothicPalette.parchmentLight,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
