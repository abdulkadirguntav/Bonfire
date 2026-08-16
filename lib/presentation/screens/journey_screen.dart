import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/domain/models/reflection.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/soapstone.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';
import 'package:bonfire/presentation/providers/soapstone_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

const List<int> bonfireMilestones = [3, 7, 14, 30, 60, 90];

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final ashMark = ref.watch(ashMarkControllerProvider);
    final reflections = ref.watch(reflectionControllerProvider);
    final soapstones = ref.watch(soapstoneControllerProvider);

    final currentStreak = user?.currentStreak ?? 1;

    // Check if user is currently standing at an unclaimed bonfire milestone (3, 7, 14, 30)
    final eligibleMilestone = bonfireMilestones.where((m) {
      return currentStreak >= m && !(user?.hasClaimedMilestone(m) ?? false);
    }).firstOrNull;

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppPalette.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Back Button
              Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppPalette.primaryGold,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: AppPalette.primaryGold,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE CHRONICLE',
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
                          'YOLCULUK HARİTASI VE ARŞİVLER',
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
                          'GÜN $currentStreak',
                          style: GoogleFonts.inter(
                            color: AppPalette.textBoneWhite,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Unclaimed Bonfire Shrine Event Banner
              if (eligibleMilestone != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF221E18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppPalette.primaryGold.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppPalette.primaryGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'BONFIRE BULUNDU! (GÜN $eligibleMilestone)',
                              style: GoogleFonts.cinzel(
                                color: AppPalette.primaryGold,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ateşin başında dinlendin. Canın tamamen yenilendi! Kalıcı bir stat artışı seçerek ateşi körükle:',
                        style: GoogleFonts.inter(
                          color: AppPalette.textBoneWhite,
                          fontSize: 11.5,
                          height: 1.35,
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
                                      content: Text(
                                        '🔥 Kudret seçildi: +20 Max HP kazanıldı!',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPalette.bloodBright,
                                side: const BorderSide(
                                    color: AppPalette.bloodCrimson, width: 0.8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                '+20 MAX HP',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
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
                                      content: Text(
                                        '⚡ Dayanıklılık seçildi: +15 Max Stamina kazanıldı!',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPalette.staminaBlue,
                                side: const BorderSide(
                                    color: AppPalette.staminaBlue, width: 0.8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                '+15 STAMINA',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Ash Mark indicator banner
              if (ashMark != null && ashMark.lostEssence > 0) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1517),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppPalette.bloodCrimson.withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.dangerous_rounded,
                          color: AppPalette.bloodBright, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'KÜL İZİ HEDEFİ: Gün ${ashMark.targetStreak} (${ashMark.lostEssence} Kayıp Öz)',
                          style: GoogleFonts.inter(
                            color: AppPalette.textBoneWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Minimal TabBar
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppPalette.dividerLine,
                      width: 1.0,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppPalette.primaryGold,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppPalette.primaryGold,
                  unselectedLabelColor: AppPalette.textAshGray,
                  labelStyle: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                  unselectedLabelStyle: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'YOL HARİTASI'),
                    Tab(text: 'KADİM İZLER'),
                    Tab(text: 'MUHASEBE'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // TabBarViews
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Roadmap & Milestone Grid
                    _JourneyGridView(
                      currentStreak: currentStreak,
                      claimedMilestones: (user?.claimedMilestones ?? const <int>[]).toList(),
                      ashMark: ashMark,
                    ),

                    // Tab 2: Soapstone Past Inscriptions
                    _PastSoapstonesView(soapstones: soapstones),

                    // Tab 3: Past Reflections Archive
                    _PastReflectionsView(reflections: reflections),
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

class _JourneyGridView extends StatelessWidget {
  const _JourneyGridView({
    required this.currentStreak,
    required this.claimedMilestones,
    required this.ashMark,
  });

  final int currentStreak;
  final List<int> claimedMilestones;
  final dynamic ashMark;

  @override
  Widget build(BuildContext context) {
    const totalDays = 90;

    return GridView.builder(
      itemCount: totalDays,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final day = index + 1;
        final isPassed = day < currentStreak;
        final isCurrent = day == currentStreak;
        final isBonfire = bonfireMilestones.contains(day);
        final isMarket = ShopItem.isMarketOpenOnStreak(day);
        final isAshMark =
            ashMark != null && ashMark.lostEssence > 0 && ashMark.targetStreak == day;
        final isClaimed = claimedMilestones.contains(day);

        Color bgColor;
        Color borderColor;

        if (isCurrent) {
          bgColor = const Color(0xFF221E18);
          borderColor = AppPalette.primaryGold;
        } else if (isPassed) {
          bgColor = AppPalette.surface;
          borderColor = AppPalette.borderSubtle;
        } else if (isAshMark) {
          bgColor = const Color(0xFF1F1517);
          borderColor = AppPalette.bloodCrimson;
        } else {
          bgColor = AppPalette.surface;
          borderColor = AppPalette.borderSubtle;
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: isCurrent ? 1.0 : 0.6,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$day',
                      style: GoogleFonts.cinzel(
                        color: isCurrent
                            ? AppPalette.primaryGold
                            : isPassed
                                ? AppPalette.textBoneWhite
                                : AppPalette.textDim,
                        fontSize: 12.5,
                        fontWeight:
                            isCurrent ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    if (isMarket) ...[
                      const SizedBox(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14161C),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '🛒',
                          style: GoogleFonts.inter(fontSize: 8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isBonfire)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    size: 11,
                    color: isClaimed
                        ? AppPalette.primaryGold
                        : isPassed || isCurrent
                            ? const Color(0xFFE25822)
                            : AppPalette.textDim,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PastSoapstonesView extends StatelessWidget {
  const _PastSoapstonesView({required this.soapstones});

  final List<Soapstone> soapstones;

  @override
  Widget build(BuildContext context) {
    if (soapstones.isEmpty) {
      return Center(
        child: Text(
          'Henüz zemine kazınmış bir not bulunmuyor.',
          style: GoogleFonts.inter(
            color: AppPalette.textAshGray,
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: soapstones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = soapstones[index];
        final dateStr =
            '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppPalette.borderSubtle,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      color: AppPalette.textAshGray,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.isEdited)
                    Text(
                      'DÜZENLENDİ',
                      style: GoogleFonts.inter(
                        color: AppPalette.textDim,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '❝ ${item.message} ❞',
                style: GoogleFonts.cinzel(
                  color: AppPalette.primaryGold,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PastReflectionsView extends StatelessWidget {
  const _PastReflectionsView({required this.reflections});

  final List<Reflection> reflections;

  @override
  Widget build(BuildContext context) {
    if (reflections.isEmpty) {
      return Center(
        child: Text(
          'Henüz mühürlenmiş bir gün sonu muhasebesi yok.',
          style: GoogleFonts.inter(
            color: AppPalette.textAshGray,
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: reflections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = reflections[index];
        final dateStr =
            '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppPalette.borderSubtle,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.cinzel(
                  color: AppPalette.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...item.answers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          color: AppPalette.textAshGray,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: GoogleFonts.inter(
                          color: AppPalette.textBoneWhite,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
