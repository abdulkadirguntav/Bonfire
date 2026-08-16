import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
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
        return GothicPalette.emberBright;
      case ItemType.ashenEstus:
        return const Color(0xFF00BFFF);
      case ItemType.purgingStone:
        return GothicPalette.goldBright;
      case ItemType.ringOfSacrifice:
        return GothicPalette.bloodBright;
      case ItemType.scrollOfStasis:
        return const Color(0xFF9370DB);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final currentStreak = user?.currentStreak ?? 1;
    final isMarketOpen = ShopItem.isMarketOpenOnStreak(currentStreak);
    final nextMarketDay = ShopItem.nextMarketDay(currentStreak);
    final daysLeft = nextMarketDay - currentStreak;
    final catalog = ShopItem.defaultKilnCatalog;

    return Scaffold(
      backgroundColor: GothicPalette.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with overflow-safe title
              Row(
                children: [
                  const Icon(
                    Icons.fireplace_rounded,
                    color: GothicPalette.emberBright,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'THE KILN',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: GothicPalette.goldBright,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
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
                          '${user?.essence ?? 0} ÖZ',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.goldBright,
                            fontSize: 12,
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
                'Kadim Eşyalar ve Seyyar Tüccar Pazarı',
                style: TextStyle(
                  color: GothicPalette.parchmentDim,
                  fontSize: 11,
                  fontFamily: GoogleFonts.cinzel().fontFamily,
                ),
              ),
              const SizedBox(height: 12),

              // Market Open/Closed Status Banner
              if (isMarketOpen)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2012),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GothicPalette.goldBright,
                      width: 0.9,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded,
                          color: GothicPalette.goldBright, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔥 PAZAR AÇIK (GÜN $currentStreak): Seyyar tüccar kamp kurdu. Eşya satın alabilirsin.',
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: GothicPalette.ironBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GothicPalette.charcoal,
                      width: 0.7,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: GothicPalette.parchmentDim, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mühürlü: Market her 5 günde bir (Gün 5, 10, 15, 20, 25, 30...) açılır. Sonraki pazar: Gün $nextMarketDay ($daysLeft gün kaldı).',
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
                            color: const Color(0xFF1E2A1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '🛡️ Arınma Koruması: ${user.activePurgingStones} Görev',
                            style: const TextStyle(
                              color: Color(0xFF81C784),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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
                            color: const Color(0xFF2A1E35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF9370DB),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            '⏳ Zaman Donduruldu (Stasis)',
                            style: TextStyle(
                              color: Color(0xFFBA68C8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
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

                    return OrnateFrame(
                      radius: 12,
                      outerGradient: LinearGradient(
                        colors: [
                          itemColor.withValues(alpha: 0.25),
                          GothicPalette.charcoal,
                          GothicPalette.ironBlack,
                        ],
                      ),
                      glow: true,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: GothicPalette.ironBlack,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: itemColor,
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: itemColor.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _iconForName(item.iconName),
                                    color: itemColor,
                                    size: 20,
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
                                            item.name.toUpperCase(),
                                            style: GoogleFonts.cinzel(
                                              color: GothicPalette.goldBright,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          if (ownedCount > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: GothicPalette.ironBlack,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: GothicPalette.bronze,
                                                  width: 0.6,
                                                ),
                                              ),
                                              child: Text(
                                                '$ownedCount Adet Var',
                                                style: const TextStyle(
                                                  color:
                                                      GothicPalette.parchment,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.nameTr,
                                        style: const TextStyle(
                                          color: GothicPalette.parchmentDim,
                                          fontSize: 10.5,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: GothicPalette.parchmentLight,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '${item.cost} ÖZ',
                                  style: GoogleFonts.cinzel(
                                    color: canAfford
                                        ? GothicPalette.goldBright
                                        : GothicPalette.parchmentDim,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Spacer(),
                                if (ownedCount > 0 &&
                                    item.type != ItemType.ringOfSacrifice) ...[
                                  OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(userControllerProvider
                                                .notifier)
                                            .useItem(item.type);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '✨ ${item.name} kullanıldı!',
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
                                      side: BorderSide(color: itemColor),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                    ),
                                    child: const Text(
                                      'KULLAN',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
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
                                                  backgroundColor:
                                                      GothicPalette.goldDeep,
                                                  content: Text(
                                                    '🛡️ ${item.name} satın alındı!',
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
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  ),
                                  child: Text(
                                    !isMarketOpen
                                        ? 'KAPALI'
                                        : 'SATIN AL',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
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
