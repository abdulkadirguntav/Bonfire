import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/presentation/providers/soapstone_provider.dart';

class SoapstoneRuneCard extends ConsumerWidget {
  const SoapstoneRuneCard({super.key});

  void _showWriteDialog(
    BuildContext context,
    WidgetRef ref, {
    String? existingId,
    String? initialText,
    bool isEditing = false,
  }) {
    final controller = TextEditingController(text: initialText ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GothicPalette.onyx,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: GothicPalette.goldDeep, width: 0.8),
        ),
        title: Text(
          isEditing ? 'Zemin Yazısını Düzenle' : 'Zemine Kadim Not Bırak',
          style: GoogleFonts.cinzel(
            color: GothicPalette.goldBright,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? '⚠️ Dikkat: Bu mesajı gün içinde yalnızca 1 kez düzenleme hakkınız vardır.'
                  : 'Yolculuğundaki diğer küllere ağırbaşlı bir mesaj bırak (Günde 1 kez).',
              style: const TextStyle(
                color: GothicPalette.parchment,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 120,
              style: GoogleFonts.cinzel(
                color: GothicPalette.goldBright,
                fontSize: 13,
              ),
              decoration: const InputDecoration(
                hintText: 'Örn: İleriye bak, vazgeçiş yok...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal',
                style: TextStyle(color: GothicPalette.parchmentDim)),
          ),
          OutlinedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              try {
                if (isEditing && existingId != null) {
                  await ref
                      .read(soapstoneControllerProvider.notifier)
                      .editMessage(existingId, text);
                } else {
                  await ref
                      .read(soapstoneControllerProvider.notifier)
                      .postMessage(text);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: GothicPalette.goldBright,
              side: const BorderSide(color: GothicPalette.brass),
            ),
            child: Text(isEditing ? 'DÜZENLE' : 'KAZI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(isSoapstoneUnlockedProvider);
    final todaySoapstone =
        ref.watch(soapstoneControllerProvider.notifier).getTodaySoapstone();

    // If locked (no boss defeated / phase < 2)
    if (!isUnlocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: GothicPalette.ironBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: GothicPalette.charcoal,
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: GothicPalette.parchmentDim,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'MÜHÜRLÜ SOAPSTONE: Bir Boss aşaması aşıldığında kadim zemin yazısı açılacak.',
                style: TextStyle(
                  color: GothicPalette.parchmentDim,
                  fontSize: 10.5,
                  fontFamily: GoogleFonts.cinzel().fontFamily,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If unlocked: Glowing Golden Rune Card
    return OrnateFrame(
      radius: 10,
      outerGradient: const LinearGradient(
        colors: [
          Color(0xFF3F321D),
          Color(0xFF7A6028),
          Color(0xFFB89B5B),
          Color(0xFF3F321D),
        ],
      ),
      glow: true,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: GothicPalette.goldBright,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'KADİM ZEMİN YAZISI (SOAPSTONE)',
                  style: GoogleFonts.cinzel(
                    color: GothicPalette.goldBright,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (todaySoapstone?.isEdited == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: GothicPalette.ironBlack,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: GothicPalette.bronze, width: 0.5),
                    ),
                    child: const Text(
                      'DÜZENLENDİ',
                      style: TextStyle(
                        color: GothicPalette.parchmentDim,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (todaySoapstone == null) ...[
              const Text(
                'Ateşin yanına bugün için henüz bir iz bırakmadın.',
                style: TextStyle(
                  color: GothicPalette.parchmentLight,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showWriteDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GothicPalette.goldBright,
                    side: const BorderSide(
                        color: GothicPalette.goldDeep, width: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text(
                    'ZEMİNE NOT KAZI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: GothicPalette.ironBlack,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: GothicPalette.bronze,
                    width: 0.6,
                  ),
                ),
                child: Text(
                  '❝ ${todaySoapstone.message} ❞',
                  style: GoogleFonts.cinzel(
                    color: GothicPalette.goldBright,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                ),
              ),
              if (!todaySoapstone.isEdited) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showWriteDialog(
                      context,
                      ref,
                      existingId: todaySoapstone.id,
                      initialText: todaySoapstone.message,
                      isEditing: true,
                    ),
                    icon: const Icon(Icons.edit_outlined,
                        size: 13, color: GothicPalette.goldBright),
                    label: const Text(
                      'Düzenle (1 Hak Kaldı)',
                      style: TextStyle(
                        color: GothicPalette.goldBright,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
