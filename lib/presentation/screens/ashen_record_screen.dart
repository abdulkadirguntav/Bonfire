import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
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
        return Icons.local_fire_department_rounded;
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
        return '+%${level * 5} Öz';
      case AttributeType.adaptability:
        return '-%${level * 4} Hasar';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final isAtBonfire = user?.isAtBonfireDay ?? false;
    final essence = user?.essence ?? 0;

    return Scaffold(
      backgroundColor: AppPalette.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: AppPalette.primaryGold,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE ASHEN RECORD',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cinzel(
                            color: AppPalette.primaryGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ),
                        Text(
                          'NİTELİKLER VE GEÇMİŞİN KÜLLERİ',
                          style: GoogleFonts.inter(
                            color: AppPalette.textAshGray,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppPalette.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.whatshot_rounded,
                          color: AppPalette.primaryGold,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$essence ÖZ',
                          style: GoogleFonts.cinzel(
                            color: AppPalette.primaryGold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Character Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppPalette.borderSubtle,
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14161C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppPalette.primaryGold.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: AppPalette.primaryGold,
                          size: 22,
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
                              color: AppPalette.primaryGold,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.selectedClass.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppPalette.textAshGray,
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
                    color: const Color(0xFF221E18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppPalette.primaryGold.withValues(alpha: 0.4),
                      width: 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppPalette.primaryGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔥 BONFIRE GÜNÜNDESİN: Nitelik geliştirme (Level Up) mühürleri açıldı!',
                          style: GoogleFonts.inter(
                            color: AppPalette.primaryGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppPalette.borderSubtle,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: AppPalette.textAshGray, size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mühürlü: Stat geliştirme yalnızca Bonfire günlerinde (Gün 3, 7, 14, 30) yapılabilir.',
                          style: GoogleFonts.inter(
                            color: AppPalette.textAshGray,
                            fontSize: 11,
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
                    const SizedBox(height: 6),
                    ...AttributeType.values.map((attribute) {
                      final currentLevel = user?.attributeLevel(attribute) ?? 0;
                      final cost = user == null
                          ? 100
                          : AttributeService.getUpgradeCost(user, attribute);
                      final canAfford = isAtBonfire && essence >= cost;
                      final bonusText =
                          _bonusTextFor(attribute, currentLevel);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppPalette.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: canAfford
                                ? AppPalette.primaryGold.withValues(alpha: 0.3)
                                : AppPalette.borderSubtle,
                            width: 0.8,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                _iconForAttribute(attribute),
                                color: canAfford
                                    ? AppPalette.primaryGold
                                    : AppPalette.textAshGray,
                                size: 18,
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
                                            color: AppPalette.textBoneWhite,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF14161C),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: AppPalette.borderSubtle,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            'LV. $currentLevel',
                                            style: GoogleFonts.inter(
                                              color: AppPalette.primaryGold,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${attribute.description} ($bonusText)',
                                      style: GoogleFonts.inter(
                                        color: AppPalette.textAshGray,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
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
                                                content: Text(
                                                  '✨ ${attribute.nameTr} geliştirildi! ($bonusText)',
                                                ),
                                              ),
                                            );
                                          }
                                        } on NotAtBonfireDayException {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '🔒 Sadece Bonfire günlerinde stat yükseltebilirsin!',
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
                                                  'Yetersiz Öz (Essence)!',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppPalette.primaryGold,
                                  disabledForegroundColor:
                                      AppPalette.textDim,
                                  side: BorderSide(
                                    color: canAfford
                                        ? AppPalette.primaryGold
                                        : AppPalette.borderSubtle,
                                    width: 0.8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  '+$cost ÖZ',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),

                    // Section 2: General Statistics (Chronicle/History)
                    const SectionTitle('Geçmiş ve İstatistikler (Chronicle)'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppPalette.borderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          _StatRow(
                            icon: Icons.shield_outlined,
                            label: 'Yenilen Düşmanlar (Görevler)',
                            value: '${user?.enemiesDefeated ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.dangerous_outlined,
                            label: 'Katledilen Boss Fazları',
                            value: '${user?.bossPhasesDefeated ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.heart_broken_outlined,
                            label: 'Ölüm Sayısı',
                            value: '${user?.deathCount ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.replay_outlined,
                            label: 'Geri Alınan Kül İzleri',
                            value: '${user?.ashMarksReclaimed ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.whatshot_outlined,
                            label: 'En Yüksek Gün Serisi',
                            value: 'Gün ${user?.highestStreak ?? 1}',
                            isHighlighted: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Danger Zone / Reset Character
                    const SectionTitle('Küllerin Sonu (Tehlikeli Bölge)'),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1112),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppPalette.bloodCrimson.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Karakterini silip sıfırdan yeni bir sınıfla başlamak istiyorsan aşağıdaki mührü kullanabilirsin. Tüm ilerlemen ve verilerin silinir.',
                            style: GoogleFonts.inter(
                              color: AppPalette.textAshGray,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF140D0E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: AppPalette.bloodCrimson,
                                        width: 1.0,
                                      ),
                                    ),
                                    title: Text(
                                      'KÜLLERE DÖNÜŞ (KARAKTERİ SİL)',
                                      style: GoogleFonts.cinzel(
                                        color: AppPalette.bloodBright,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    content: Text(
                                      '⚠️ Bu işlem GERİ ALINAMAZ!\n\nSeçtiğin sınıf, biriktirdiğin tüm Öz, tamamladığın yeminler, Boss ilerlemen ve kadim notların tamamen silinecektir.\n\nGerçekten tüm küllerini savurmak ve sıfırdan yeni bir karakter yaratmak istiyor musun?',
                                      style: GoogleFonts.inter(
                                        color: AppPalette.textBoneWhite,
                                        fontSize: 12,
                                        height: 1.45,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: Text(
                                          'VAZGEÇ',
                                          style: GoogleFonts.inter(
                                            color: AppPalette.textAshGray,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppPalette.bloodBright,
                                          side: const BorderSide(
                                            color: AppPalette.bloodCrimson,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Text(
                                          'TÜM VERİLERİ SİL',
                                          style: GoogleFonts.cinzel(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref
                                      .read(userControllerProvider.notifier)
                                      .wipeAndResetAllProgress();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPalette.bloodBright,
                                side: const BorderSide(
                                  color: AppPalette.bloodCrimson,
                                  width: 0.9,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.delete_forever_rounded, size: 16),
                              label: Text(
                                'KARAKTERİ VE TÜM VERİLERİ SİL',
                                style: GoogleFonts.cinzel(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
    required this.value,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? AppPalette.primaryGold
                : AppPalette.textAshGray,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isHighlighted
                    ? AppPalette.textBoneWhite
                    : AppPalette.textAshGray,
                fontSize: 12,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cinzel(
              color: isHighlighted
                  ? AppPalette.primaryGold
                  : AppPalette.textBoneWhite,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
