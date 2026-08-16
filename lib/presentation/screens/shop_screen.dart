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
    final catalog = ShopItem.defaultKilnCatalog;

    return Scaffold(
      backgroundColor: GothicPalette.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.fireplace_rounded,
                    color: GothicPalette.emberBright,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'THE KILN',
                    style: GoogleFonts.cinzel(
                      color: GothicPalette.goldBright,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${user?.essence ?? 0} ÖZ',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.goldBright,
                            fontSize: 13,
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
                'Kadim Eşyalar ve Kutsal Emanetler',
                style: TextStyle(
                  color: GothicPalette.parchmentDim,
                  fontSize: 12,
                  fontFamily: GoogleFonts.cinzel().fontFamily,
                ),
              ),
              const SizedBox(height: 14),

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
                const SizedBox(height: 12),
              ],

              // Catalog List
              Expanded(
                child: ListView.separated(
                  itemCount: catalog.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = catalog[index];
                    final ownedCount = user?.itemCount(item.id) ?? 0;
                    final itemColor = _colorForItem(item.type);
                    final canAfford = (user?.essence ?? 0) >= item.cost;

                    return OrnateFrame(
                      radius: 12,
                      outerGradient: LinearGradient(
                        colors: [
                          itemColor.withValues(alpha: 0.3),
                          GothicPalette.charcoal,
                          GothicPalette.ironBlack,
                        ],
                      ),
                      glow: true,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
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
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          if (ownedCount > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
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
                                                  fontSize: 10,
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
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: GothicPalette.parchmentLight,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${item.cost} ÖZ',
                                  style: GoogleFonts.cinzel(
                                    color: canAfford
                                        ? GothicPalette.goldBright
                                        : GothicPalette.parchmentDim,
                                    fontSize: 15,
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
                                          horizontal: 14, vertical: 8),
                                    ),
                                    child: const Text(
                                      'KULLAN',
                                      style: TextStyle(
                                        fontSize: 11,
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
                                    side: const BorderSide(
                                        color: GothicPalette.brass),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                  ),
                                  child: const Text(
                                    'SATIN AL',
                                    style: TextStyle(
                                      fontSize: 11,
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
