import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/localization/app_localizations.dart';
import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/services/shop_service.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  IconData _iconForName(String iconName) {
    switch (iconName) {
      case 'local_drink':
        return Icons.local_fire_department_rounded;
      case 'electric_bolt':
        return Icons.bolt_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'fingerprint':
        return Icons.radio_button_checked_rounded;
      case 'hourglass_full':
        return Icons.hourglass_bottom_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _colorForItem(ItemType type) {
    switch (type) {
      case ItemType.estusFlask:
        return const Color(0xFFD6743A);
      case ItemType.ashenEstus:
        return AppPalette.staminaBlue;
      case ItemType.purgingStone:
        return AppPalette.primaryGold;
      case ItemType.ringOfSacrifice:
        return AppPalette.bloodCrimson;
      case ItemType.scrollOfStasis:
        return const Color(0xFF8E71A5);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userControllerProvider);
    final currentStreak = user?.currentStreak ?? 1;
    final isMarketOpen = ShopItem.isMarketOpenOnStreak(currentStreak);
    final nextMarketDay = ShopItem.nextMarketDay(currentStreak);
    final daysLeft = nextMarketDay - currentStreak;
    final catalog = ShopItem.defaultKilnCatalog;

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
                    Icons.fireplace_rounded,
                    color: AppPalette.primaryGold,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shopTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cinzel(
                            color: AppPalette.primaryGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          l10n.isTurkish
                              ? 'KADİM EŞYALAR VE SEYYAR TÜCCAR'
                              : 'ANCIENT RELICS & TRAVELLING MERCHANT',
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
                          '${user?.essence ?? 0} ${l10n.essence}',
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

              // Market Open/Closed Status Banner
              if (isMarketOpen)
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
                      const Icon(Icons.storefront_rounded,
                          color: AppPalette.primaryGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.isTurkish
                              ? '🔥 PAZAR AÇIK (${l10n.streakDay} $currentStreak): Seyyar tüccar kamp kurdu.'
                              : '🔥 MARKET OPEN (${l10n.streakDay} $currentStreak): Travelling merchant has arrived.',
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
                          l10n.isTurkish
                              ? 'Mühürlü: Pazar her 5 günde bir açılır. Sonraki pazar: Gün $nextMarketDay ($daysLeft gün kaldı).'
                              : 'Sealed: Market opens every 5 days. Next market: Day $nextMarketDay ($daysLeft days left).',
                          style: GoogleFonts.inter(
                            color: AppPalette.textAshGray,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),

              // Active status indicators (Purging stones & Stasis)
              if (user != null &&
                  (user.activePurgingStones > 0 ||
                      user.isStasisActiveOn(DateTime.now()))) ...[
                Row(
                  children: [
                    if (user.activePurgingStones > 0)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF18231C),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4CAF50)
                                  .withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            l10n.isTurkish
                                ? '🛡️ Arınma Taşı: ${user.activePurgingStones} Görev'
                                : '🛡️ Purging Stone: ${user.activePurgingStones} Vow',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF81C784),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (user.activePurgingStones > 0 &&
                        user.isStasisActiveOn(DateTime.now()))
                      const SizedBox(width: 8),
                    if (user.isStasisActiveOn(DateTime.now()))
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF221A2B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF9370DB)
                                  .withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            l10n.isTurkish
                                ? '⏳ Zaman Donduruldu'
                                : '⏳ Stasis Active',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFBA68C8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Catalog List
              Expanded(
                child: ListView.separated(
                  itemCount: catalog.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = catalog[index];
                    final ownedCount = user?.itemCount(item.id) ?? 0;
                    final itemColor = _colorForItem(item.type);
                    final canAfford =
                        isMarketOpen && (user?.essence ?? 0) >= item.cost;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppPalette.borderSubtle,
                          width: 0.9,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF14161C),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: itemColor.withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Icon(
                                    _iconForName(item.iconName),
                                    color: itemColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            (l10n.isTurkish
                                                    ? item.nameTr
                                                    : item.nameEn)
                                                .toUpperCase(),
                                            style: GoogleFonts.cinzel(
                                              color: AppPalette.textBoneWhite,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          if (ownedCount > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF14161C),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color:
                                                      AppPalette.borderSubtle,
                                                  width: 0.6,
                                                ),
                                              ),
                                              child: Text(
                                                l10n.isTurkish
                                                    ? '$ownedCount Adet'
                                                    : '$ownedCount ${l10n.owned}',
                                                style: GoogleFonts.inter(
                                                  color: AppPalette.primaryGold,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.isTurkish
                                  ? item.descriptionTr
                                  : item.descriptionEn,
                              style: GoogleFonts.inter(
                                color: AppPalette.textAshGray,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '${item.cost} ${l10n.essence}',
                                  style: GoogleFonts.cinzel(
                                    color: canAfford
                                        ? AppPalette.primaryGold
                                        : AppPalette.textAshGray,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                if (ownedCount > 0 &&
                                    item.type != ItemType.ringOfSacrifice) ...[
                                  OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(
                                                userControllerProvider.notifier)
                                            .useItem(item.type);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '✨ ${(l10n.isTurkish ? item.nameTr : item.nameEn)} ${l10n.isTurkish ? 'kullanıldı!' : 'used!'}',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: itemColor,
                                      side: BorderSide(
                                          color: itemColor, width: 0.8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.use,
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                OutlinedButton(
                                  onPressed: !canAfford
                                      ? null
                                      : () async {
                                          try {
                                            await ref
                                                .read(userControllerProvider
                                                    .notifier)
                                                .buyItem(item.type);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '🛡️ ${(l10n.isTurkish ? item.nameTr : item.nameEn)} ${l10n.isTurkish ? 'satın alındı!' : 'purchased!'}',
                                                  ),
                                                ),
                                              );
                                            }
                                          } on MarketClosedException catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(e.toString())),
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
                                    disabledForegroundColor: AppPalette.textDim,
                                    side: BorderSide(
                                      color: canAfford
                                          ? AppPalette.primaryGold
                                          : AppPalette.borderSubtle,
                                      width: 0.8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    !isMarketOpen
                                        ? (l10n.isTurkish ? 'KAPALI' : 'CLOSED')
                                        : l10n.buy,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
