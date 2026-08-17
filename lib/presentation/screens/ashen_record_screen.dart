import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/localization/app_localizations.dart';
import 'package:bonfire/core/services/notification_service.dart';
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

  String _bonusTextFor(AttributeType type, int level, AppLocalizations l10n) {
    if (l10n.isTurkish) {
      switch (type) {
        case AttributeType.vitality:
          return '+${level * 15} Max Can';
        case AttributeType.endurance:
          return '+${level * 10} Max Stamina';
        case AttributeType.strength:
          return '+%${level * 5} Öz';
        case AttributeType.adaptability:
          return '-%${level * 4} Hasar';
      }
    }
    switch (type) {
      case AttributeType.vitality:
        return '+${level * 15} Max HP';
      case AttributeType.endurance:
        return '+${level * 10} Max Stamina';
      case AttributeType.strength:
        return '+${level * 5}% Essence';
      case AttributeType.adaptability:
        return '-${level * 4}% Damage';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
                          l10n.recordTitle,
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
                          l10n.isTurkish ? 'NİTELİKLER VE GEÇMİŞİN KÜLLERİ' : 'ATTRIBUTES & HISTORICAL ASHES',
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
                    SectionTitle(l10n.attributesTitle),
                    const SizedBox(height: 6),
                    ...AttributeType.values.map((attribute) {
                      final currentLevel = user?.attributeLevel(attribute) ?? 0;
                      final cost = user == null
                          ? 100
                          : AttributeService.getUpgradeCost(user, attribute);
                      final canAfford = isAtBonfire && essence >= cost;
                      final bonusText =
                          _bonusTextFor(attribute, currentLevel, l10n);

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
                                          (l10n.isTurkish
                                                  ? attribute.nameTr
                                                  : attribute.nameEn)
                                              .toUpperCase(),
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
                                      '${l10n.isTurkish ? attribute.descriptionTr : attribute.descriptionEn} ($bonusText)',
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
                                                  '✨ ${(l10n.isTurkish ? attribute.nameTr : attribute.nameEn)} ${l10n.isTurkish ? 'geliştirildi!' : 'upgraded!'} ($bonusText)',
                                                ),
                                              ),
                                            );
                                          }
                                        } on NotAtBonfireDayException {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.bonfireRequiredToLevel,
                                                ),
                                              ),
                                            );
                                          }
                                        } on InsufficientEssenceException {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.isTurkish
                                                      ? 'Yetersiz Öz (Essence)!'
                                                      : 'Insufficient Essence!',
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
                                  '+$cost ${l10n.essence}',
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
                    SectionTitle(l10n.chronicleTitle),
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
                            label: l10n.isTurkish
                                ? 'Yenilen Düşmanlar (Yeminler)'
                                : 'Vows Completed (Enemies Slain)',
                            value: '${user?.enemiesDefeated ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.dangerous_outlined,
                            label: l10n.isTurkish
                                ? 'Katledilen Boss Fazları'
                                : 'Boss Phases Defeated',
                            value: '${user?.bossPhasesDefeated ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.heart_broken_outlined,
                            label: l10n.isTurkish ? 'Ölüm Sayısı' : 'Death Count',
                            value: '${user?.deathCount ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.replay_outlined,
                            label: l10n.isTurkish
                                ? 'Geri Alınan Kül İzleri'
                                : 'Ash Marks Reclaimed',
                            value: '${user?.ashMarksReclaimed ?? 0}',
                          ),
                          const Divider(height: 1, color: AppPalette.dividerLine),
                          _StatRow(
                            icon: Icons.whatshot_outlined,
                            label: l10n.isTurkish
                                ? 'En Yüksek Gün Serisi'
                                : 'Highest Streak',
                            value: '${l10n.streakDay} ${user?.highestStreak ?? 1}',
                            isHighlighted: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section: Notification & System Test
                    SectionTitle(l10n.isTurkish ? 'Bildirim ve Hatırlatıcı Testi' : 'Notification & Alarm Test'),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppPalette.borderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.isTurkish
                                ? 'Telefonunuzun bildirim çubuğunda ve kilit ekranında Bonfire uyarılarının çalıştığını doğrulamak için test bildirimi gönderin.'
                                : 'Trigger an immediate test reminder to verify notifications work on your lock screen and notification shade.',
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
                                await NotificationService.instance.showImmediateTestNotification(
                                  title: l10n.isTurkish
                                      ? '🔥 BONFIRE: Kadim Ateş Canlı!'
                                      : '🔥 BONFIRE: The Flame Burns!',
                                  body: l10n.isTurkish
                                      ? 'Bildirim altyapısı sorunsuz çalışıyor. Yeminlerin koruma altında!'
                                      : 'Notification channel active. Your daily vows are protected!',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.testNotificationSent,
                                        style: GoogleFonts.inter(fontSize: 12),
                                      ),
                                      backgroundColor: const Color(0xFF1F232C),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPalette.primaryGold,
                                side: const BorderSide(
                                  color: AppPalette.primaryGold,
                                  width: 0.9,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.notifications_active_rounded, size: 16),
                              label: Text(
                                l10n.testNotification,
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
                    const SizedBox(height: 16),

                    // Section 3: Danger Zone / Reset Character
                    SectionTitle(l10n.dangerZone),
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
                            l10n.isTurkish
                                ? 'Karakterini silip sıfırdan yeni bir sınıfla başlamak istiyorsan aşağıdaki mührü kullanabilirsin. Tüm ilerlemen ve verilerin silinir.'
                                : 'Use the seal below to erase your character and start fresh. All progress, vows, and essence will be cleared.',
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
                                      l10n.wipeConfirmTitle,
                                      style: GoogleFonts.cinzel(
                                        color: AppPalette.bloodBright,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    content: Text(
                                      l10n.wipeConfirmDesc,
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
                                          l10n.cancel,
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
                                          l10n.confirmWipe,
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
                                l10n.wipeCharacter,
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
