import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

const List<int> bonfireMilestones = [3, 7, 14, 30, 60, 90];

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final ashMark = ref.watch(ashMarkControllerProvider);
    final tasks = ref.watch(tasksProvider);

    final currentStreak = user?.currentStreak ?? 1;

    // Check if user is currently standing at an unclaimed milestone (3, 7, 14, 30)
    final eligibleMilestone = bonfireMilestones.where((m) {
      return currentStreak >= m && !(user?.hasClaimedMilestone(m) ?? false);
    }).firstOrNull;

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
                    Icons.auto_stories_rounded,
                    color: GothicPalette.goldBright,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'THE CHRONICLE',
                    style: GoogleFonts.cinzel(
                      color: GothicPalette.goldBright,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                          color: GothicPalette.emberBright,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GÜN $currentStreak',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.parchmentLight,
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
                'Yolculuk Haritası ve Bonfire Dönüm Noktaları',
                style: TextStyle(
                  color: GothicPalette.parchmentDim,
                  fontSize: 12,
                  fontFamily: GoogleFonts.cinzel().fontFamily,
                ),
              ),
              const SizedBox(height: 14),

              // Unclaimed Bonfire Shrine Event Banner
              if (eligibleMilestone != null) ...[
                OrnateFrame(
                  radius: 12,
                  outerGradient: GothicPalette.emberCore,
                  glow: true,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: GothicPalette.goldBright,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'BONFIRE BULUNDU! (GÜN $eligibleMilestone)',
                                style: GoogleFonts.cinzel(
                                  color: GothicPalette.goldBright,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ateşin başında dinlendin. Canın tamamen yenilendi! Kalıcı bir stat artışı seçerek ateşi körükle:',
                          style: TextStyle(
                            color: GothicPalette.parchmentLight,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(userControllerProvider.notifier)
                                      .kindleMilestone(upgradeHp: true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: GothicPalette.goldDeep,
                                        content: Text(
                                          '🔥 Kudret seçildi: +20 Max HP kazanıldı!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: GothicPalette.bloodBright,
                                  side: const BorderSide(
                                      color: GothicPalette.bloodBright),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: const Text(
                                  '+20 MAX HP',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(userControllerProvider.notifier)
                                      .kindleMilestone(upgradeHp: false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: GothicPalette.goldDeep,
                                        content: Text(
                                          '⚡ Dayanıklılık seçildi: +15 Max Stamina kazanıldı!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF5EBBFF),
                                  side: const BorderSide(
                                      color: Color(0xFF1976D2)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: const Text(
                                  '+15 STAMINA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Ash Mark indicator banner
              if (ashMark != null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1212),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GothicPalette.bloodBright,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.dangerous_rounded,
                          color: GothicPalette.bloodBright, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'KÜL İZİ HEDEFİ: Gün ${ashMark.targetStreak} (${ashMark.lostEssence} Kayıp Öz)',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.parchmentLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Vertical Chronicle Timeline Path
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _ChroniclePath(
                      currentStreak: currentStreak,
                      claimedMilestones: user?.claimedMilestones ?? const {},
                      targetAshMarkStreak: ashMark?.targetStreak,
                      tasks: tasks,
                    ),
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

class _ChroniclePath extends StatelessWidget {
  const _ChroniclePath({
    required this.currentStreak,
    required this.claimedMilestones,
    required this.targetAshMarkStreak,
    required this.tasks,
  });

  final int currentStreak;
  final Set<int> claimedMilestones;
  final int? targetAshMarkStreak;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    // Generate timeline nodes up to max milestone (30 or 60 or currentStreak + 5)
    final maxNode = (currentStreak > 25 ? currentStreak + 7 : 30);
    final nodes = List.generate(maxNode, (index) => index + 1);

    return Column(
      children: nodes.map((dayNumber) {
        final isMilestone = bonfireMilestones.contains(dayNumber);
        final isCurrentDay = dayNumber == currentStreak;
        final isPast = dayNumber < currentStreak;
        final isAshMarkTarget = targetAshMarkStreak == dayNumber;
        final isClaimed = claimedMilestones.contains(dayNumber);

        return _TimelineNode(
          dayNumber: dayNumber,
          isMilestone: isMilestone,
          isCurrentDay: isCurrentDay,
          isPast: isPast,
          isAshMarkTarget: isAshMarkTarget,
          isClaimed: isClaimed,
          isLast: dayNumber == maxNode,
        );
      }).toList(),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.dayNumber,
    required this.isMilestone,
    required this.isCurrentDay,
    required this.isPast,
    required this.isAshMarkTarget,
    required this.isClaimed,
    required this.isLast,
  });

  final int dayNumber;
  final bool isMilestone;
  final bool isCurrentDay;
  final bool isPast;
  final bool isAshMarkTarget;
  final bool isClaimed;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Color nodeColor;
    IconData nodeIcon;

    if (isCurrentDay) {
      nodeColor = GothicPalette.goldBright;
      nodeIcon = Icons.local_fire_department_rounded;
    } else if (isAshMarkTarget) {
      nodeColor = GothicPalette.bloodBright;
      nodeIcon = Icons.dangerous_rounded;
    } else if (isMilestone) {
      nodeColor = isPast || isClaimed
          ? GothicPalette.goldBright
          : GothicPalette.emberBright;
      nodeIcon = Icons.fireplace_rounded;
    } else if (isPast) {
      nodeColor = GothicPalette.bronze;
      nodeIcon = Icons.check_circle_rounded;
    } else {
      nodeColor = GothicPalette.slate;
      nodeIcon = Icons.radio_button_unchecked_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left timeline axis
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: isMilestone || isCurrentDay ? 36 : 28,
                  height: isMilestone || isCurrentDay ? 36 : 28,
                  decoration: BoxDecoration(
                    color: isCurrentDay
                        ? GothicPalette.goldBright
                        : GothicPalette.ironBlack,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: nodeColor,
                      width: isCurrentDay || isMilestone ? 1.5 : 0.8,
                    ),
                    boxShadow: (isCurrentDay || isMilestone)
                        ? [
                            BoxShadow(
                              color: nodeColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      nodeIcon,
                      color: isCurrentDay ? Colors.black : nodeColor,
                      size: isMilestone || isCurrentDay ? 18 : 14,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isPast
                          ? GothicPalette.bronze
                          : GothicPalette.charcoal,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentDay
                      ? const Color(0xFF1E262C)
                      : isMilestone
                          ? const Color(0xFF1A1713)
                          : GothicPalette.onyx,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrentDay
                        ? GothicPalette.goldBright
                        : isMilestone
                            ? GothicPalette.bronze
                            : GothicPalette.charcoal,
                    width: isCurrentDay || isMilestone ? 1.0 : 0.6,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'GÜN $dayNumber',
                                style: GoogleFonts.cinzel(
                                  color: isCurrentDay
                                      ? GothicPalette.goldBright
                                      : GothicPalette.parchmentLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (isCurrentDay) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: GothicPalette.goldBright,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'BUGÜN',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                              if (isMilestone) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isClaimed
                                        ? GothicPalette.goldDeep
                                        : GothicPalette.ember,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isClaimed
                                        ? 'KÖRÜKLENDİ'
                                        : 'BONFIRE NOKTASI',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAshMarkTarget
                                ? '💀 Kül İzi: Bu güne ulaştığında kayıp Öz\'ü geri kazanacaksın.'
                                : isMilestone
                                    ? isClaimed
                                        ? '🔥 Kalıcı stat artışı bu bonfire noktasında alındı.'
                                        : isPast
                                            ? '🔥 Bonfire keşfedildi.'
                                            : '🕯️ Bonfire Tapınağı: Can fulleme & Kalıcı Stat Geliştirmesi.'
                                    : isCurrentDay
                                        ? 'Mevcut irade durağındasın. Yeminlerini tamamla.'
                                        : isPast
                                            ? 'Yolculukta geçilen aşama.'
                                            : 'Gelecek irade durağı.',
                            style: TextStyle(
                              color: isAshMarkTarget
                                  ? GothicPalette.bloodBright
                                  : GothicPalette.parchmentDim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
