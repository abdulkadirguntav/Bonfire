import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/services/shop_service.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final catalog = ShopService.defaultCatalog();
    return Scaffold(
      appBar: AppBar(title: const Text('THE KILN')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          OrnateFrame(
            radius: 10,
            padding: const EdgeInsets.all(1.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(children: [
                const Icon(Icons.auto_awesome,
                    color: GothicPalette.emberBright),
                const SizedBox(width: 9),
                const Text('ESSENCE HELD',
                    style: TextStyle(
                        color: GothicPalette.parchment,
                        fontSize: 12,
                        letterSpacing: 1.5)),
                const Spacer(),
                Text('${user?.totalEssence ?? 0}',
                    style: const TextStyle(
                        color: GothicPalette.goldBright,
                        fontSize: 21,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Forge offerings'),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 3 : 2;
              return GridView.builder(
                itemCount: catalog.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: columns == 2 ? .62 : .82,
                ),
                itemBuilder: (_, index) => _KilnItem(item: catalog[index]),
              );
            }),
          ),
        ]),
      ),
    );
  }
}

class _KilnItem extends ConsumerWidget {
  const _KilnItem({required this.item});
  final ShopItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    return OrnateFrame(
      radius: 12,
      glow: true,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 6),
            Text(item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: GothicPalette.goldBright,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: GothicPalette.parchment, fontSize: 11, height: 1.3)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.auto_awesome,
                  color: GothicPalette.emberBright, size: 15),
              const SizedBox(width: 4),
              Text('${item.price}',
                  style: const TextStyle(
                      color: GothicPalette.parchmentLight,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: user == null
                    ? null
                    : () async {
                        final currentUser = user;
                        if (!ShopService.canAfford(currentUser, item)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Yeterli Essence yok.')));
                          return;
                        }
                        await ref
                            .read(userControllerProvider.notifier)
                            .saveUser(ShopService.purchase(currentUser, item));
                      },
                child: const Text('FORGE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
