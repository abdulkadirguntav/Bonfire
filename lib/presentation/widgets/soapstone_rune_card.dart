import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
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
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPalette.borderSubtle, width: 0.8),
        ),
        title: Text(
          isEditing ? 'Zemin Yazısını Düzenle' : 'Zemine Kadim Not Bırak',
          style: GoogleFonts.cinzel(
            color: AppPalette.primaryGold,
            fontWeight: FontWeight.w700,
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
              style: GoogleFonts.inter(
                color: AppPalette.textBoneWhite,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 120,
              style: GoogleFonts.cinzel(
                color: AppPalette.primaryGold,
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
            child: Text('İptal',
                style: GoogleFonts.inter(color: AppPalette.textAshGray)),
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
              foregroundColor: AppPalette.primaryGold,
              side: const BorderSide(color: AppPalette.primaryGold, width: 0.8),
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

    // If locked
    if (!isUnlocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppPalette.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppPalette.textAshGray,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'MÜHÜRLÜ SOAPSTONE: Bir Boss aşaması aşıldığında kadim zemin yazısı açılacak.',
                style: GoogleFonts.inter(
                  color: AppPalette.textAshGray,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If unlocked: Minimalist Apple x Dark Souls card
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppPalette.primaryGold.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppPalette.primaryGold,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'KADİM ZEMİN YAZISI (SOAPSTONE)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    color: AppPalette.primaryGold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (todaySoapstone?.isEdited == true) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14161C),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppPalette.borderSubtle,
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    'DÜZENLENDİ',
                    style: GoogleFonts.inter(
                      color: AppPalette.textAshGray,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (todaySoapstone == null) ...[
            Text(
              'Ateşin yanına bugün için henüz bir iz bırakmadın.',
              style: GoogleFonts.inter(
                color: AppPalette.textAshGray,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showWriteDialog(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPalette.primaryGold,
                  side: const BorderSide(
                      color: AppPalette.borderSubtle, width: 0.8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: Text(
                  'ZEMİNE NOT KAZI',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF14161C),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppPalette.borderSubtle, width: 0.8),
              ),
              child: Text(
                '❝ ${todaySoapstone.message} ❞',
                style: GoogleFonts.cinzel(
                  color: AppPalette.primaryGold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!todaySoapstone.isEdited)
                  OutlinedButton.icon(
                    onPressed: () => _showWriteDialog(
                      context,
                      ref,
                      existingId: todaySoapstone.id,
                      initialText: todaySoapstone.message,
                      isEditing: true,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.primaryGold,
                      side: const BorderSide(
                          color: AppPalette.borderSubtle, width: 0.8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 12),
                    label: Text(
                      'DÜZENLE (1 HAK)',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
