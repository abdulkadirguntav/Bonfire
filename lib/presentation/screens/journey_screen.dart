import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/reflection.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/soapstone.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/reflection_provider.dart';
import 'package:bonfire/presentation/providers/soapstone_provider.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
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
    final tasks = ref.watch(tasksProvider);
    final reflections = ref.watch(reflectionControllerProvider);
    final soapstones = ref.watch(soapstoneControllerProvider);

    final currentStreak = user?.currentStreak ?? 1;

    // Check if user is currently standing at an unclaimed bonfire milestone (3, 7, 14, 30)
    final eligibleMilestone = bonfireMilestones.where((m) {
      return currentStreak >= m && !(user?.hasClaimedMilestone(m) ?? false);
    }).firstOrNull;

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: GothicPalette.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Back Button and overflow safety
              Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: GothicPalette.goldBright,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: GothicPalette.goldBright,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'THE CHRONICLE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: GothicPalette.goldBright,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
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
                          color: GothicPalette.emberBright,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GÜN $currentStreak',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.parchmentLight,
                            fontSize: 11.5,
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
                'Yolculuk Haritası, Pazar Günleri ve Arşivler',
                style: TextStyle(
                  color: GothicPalette.parchmentDim,
                  fontSize: 11,
                  fontFamily: GoogleFonts.cinzel().fontFamily,
                ),
              ),
              const SizedBox(height: 12),

              // Unclaimed Bonfire Shrine Event Banner
              if (eligibleMilestone != null) ...[
                OrnateFrame(
                  radius: 12,
                  outerGradient: GothicPalette.emberCore,
                  glow: true,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: GothicPalette.goldBright,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'BONFIRE BULUNDU! (GÜN $eligibleMilestone)',
                                style: GoogleFonts.cinzel(
                                  color: GothicPalette.goldBright,
                                  fontSize: 12.5,
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
                                      const EdgeInsets.symmetric(vertical: 7),
                                ),
                                child: const Text(
                                  '+20 MAX HP',
                                  style: TextStyle(
                                    fontSize: 10.5,
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
                                      const EdgeInsets.symmetric(vertical: 7),
                                ),
                                child: const Text(
                                  '+15 STAMINA',
                                  style: TextStyle(
                                    fontSize: 10.5,
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
                const SizedBox(height: 10),
              ],

              // Ash Mark indicator banner
              if (ashMark != null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                          color: GothicPalette.bloodBright, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'KÜL İZİ HEDEFİ: Gün ${ashMark.targetStreak} (${ashMark.lostEssence} Kayıp Öz)',
                          style: GoogleFonts.cinzel(
                            color: GothicPalette.parchmentLight,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Tabs: [1] Yolculuk & Pazar Takvimi, [2] Soapstone Notları, [3] Muhasebe Cevapları
              TabBar(
                controller: _tabController,
                indicatorColor: GothicPalette.goldBright,
                labelColor: GothicPalette.goldBright,
                unselectedLabelColor: GothicPalette.parchmentDim,
                labelStyle: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: GoogleFonts.cinzel(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'YOLCULUK'),
                  Tab(text: 'KADİM NOTLAR'),
                  Tab(text: 'MUHASEBE'),
                ],
              ),
              const SizedBox(height: 8),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Timeline Path with Market & Bonfire milestones
                    ListView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      children: [
                        _ChroniclePath(
                          currentStreak: currentStreak,
                          claimedMilestones:
                              user?.claimedMilestones ?? const {},
                          targetAshMarkStreak: ashMark?.targetStreak,
                          tasks: tasks,
                          reflections: reflections,
                          soapstones: soapstones,
                        ),
                      ],
                    ),
                    // Tab 2: Soapstone Notes Archive
                    _SoapstoneArchiveList(soapstones: soapstones),
                    // Tab 3: Stoic Reflections Archive
                    _ReflectionsArchiveList(reflections: reflections),
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
    required this.reflections,
    required this.soapstones,
  });

  final int currentStreak;
  final Set<int> claimedMilestones;
  final int? targetAshMarkStreak;
  final List<Task> tasks;
  final List<Reflection> reflections;
  final List<Soapstone> soapstones;

  @override
  Widget build(BuildContext context) {
    final maxNode = (currentStreak > 25 ? currentStreak + 7 : 30);
    final nodes = List.generate(maxNode, (index) => index + 1);

    return Column(
      children: nodes.map((dayNumber) {
        final isMilestone = bonfireMilestones.contains(dayNumber);
        final isMarketDay = ShopItem.isMarketOpenOnStreak(dayNumber);
        final isCurrentDay = dayNumber == currentStreak;
        final isPast = dayNumber < currentStreak;
        final isAshMarkTarget = targetAshMarkStreak == dayNumber;
        final isClaimed = claimedMilestones.contains(dayNumber);

        final matchingSoapstone = isCurrentDay && soapstones.isNotEmpty
            ? soapstones.firstOrNull
            : null;

        final matchingReflection = isCurrentDay && reflections.isNotEmpty
            ? reflections.firstOrNull
            : null;

        return _TimelineNode(
          dayNumber: dayNumber,
          isMilestone: isMilestone,
          isMarketDay: isMarketDay,
          isCurrentDay: isCurrentDay,
          isPast: isPast,
          isAshMarkTarget: isAshMarkTarget,
          isClaimed: isClaimed,
          isLast: dayNumber == maxNode,
          soapstone: matchingSoapstone,
          reflection: matchingReflection,
        );
      }).toList(),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.dayNumber,
    required this.isMilestone,
    required this.isMarketDay,
    required this.isCurrentDay,
    required this.isPast,
    required this.isAshMarkTarget,
    required this.isClaimed,
    required this.isLast,
    this.soapstone,
    this.reflection,
  });

  final int dayNumber;
  final bool isMilestone;
  final bool isMarketDay;
  final bool isCurrentDay;
  final bool isPast;
  final bool isAshMarkTarget;
  final bool isClaimed;
  final bool isLast;
  final Soapstone? soapstone;
  final Reflection? reflection;

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
    } else if (isMarketDay) {
      nodeColor = GothicPalette.gold;
      nodeIcon = Icons.storefront_rounded;
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
            width: 40,
            child: Column(
              children: [
                Container(
                  width: isMilestone || isCurrentDay || isMarketDay ? 34 : 26,
                  height: isMilestone || isCurrentDay || isMarketDay ? 34 : 26,
                  decoration: BoxDecoration(
                    color: isCurrentDay
                        ? GothicPalette.goldBright
                        : GothicPalette.ironBlack,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: nodeColor,
                      width: isCurrentDay || isMilestone || isMarketDay
                          ? 1.4
                          : 0.8,
                    ),
                    boxShadow: (isCurrentDay || isMilestone || isMarketDay)
                        ? [
                            BoxShadow(
                              color: nodeColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      nodeIcon,
                      color: isCurrentDay ? Colors.black : nodeColor,
                      size: isMilestone || isCurrentDay || isMarketDay ? 17 : 13,
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
          const SizedBox(width: 10),
          // Right content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: isCurrentDay
                      ? const Color(0xFF1E262C)
                      : isMilestone
                          ? const Color(0xFF1A1713)
                          : isMarketDay
                              ? const Color(0xFF181C16)
                              : GothicPalette.onyx,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isCurrentDay
                        ? GothicPalette.goldBright
                        : isMilestone
                            ? GothicPalette.bronze
                            : isMarketDay
                                ? GothicPalette.goldDeep
                                : GothicPalette.charcoal,
                    width: isCurrentDay || isMilestone || isMarketDay
                        ? 0.9
                        : 0.5,
                  ),
                ),
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
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (isCurrentDay) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: GothicPalette.goldBright,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'BUGÜN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                        if (isMilestone) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isClaimed
                                  ? GothicPalette.goldDeep
                                  : GothicPalette.ember,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              isClaimed ? 'KÖRÜKLENDİ' : 'BONFIRE NOKTASI',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                        if (isMarketDay) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F321D),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                  color: GothicPalette.goldDeep, width: 0.5),
                            ),
                            child: const Text(
                              '🛒 MARKET GÜNÜ',
                              style: TextStyle(
                                color: GothicPalette.goldBright,
                                fontSize: 8.5,
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
                              : isMarketDay
                                  ? '🛒 Seyyar Tüccar Pazarı: Kadim eşyalar satın alınabilir.'
                                  : isCurrentDay
                                      ? 'Mevcut irade durağındasın. Yeminlerini tamamla.'
                                      : isPast
                                          ? 'Yolculukta geçilen aşama.'
                                          : 'Gelecek irade durağı.',
                      style: TextStyle(
                        color: isAshMarkTarget
                            ? GothicPalette.bloodBright
                            : GothicPalette.parchmentDim,
                        fontSize: 10.5,
                      ),
                    ),
                    // Embedded Soapstone note if present
                    if (soapstone != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: GothicPalette.ironBlack,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: GothicPalette.goldDeep, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                size: 11, color: GothicPalette.goldBright),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Soapstone: "${soapstone!.message}"',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cinzel(
                                  color: GothicPalette.goldBright,
                                  fontSize: 9.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SoapstoneArchiveList extends StatelessWidget {
  const _SoapstoneArchiveList({required this.soapstones});

  final List<Soapstone> soapstones;

  @override
  Widget build(BuildContext context) {
    if (soapstones.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_outlined,
                color: GothicPalette.parchmentDim, size: 34),
            const SizedBox(height: 8),
            Text(
              'Henüz zemine kazınmış bir Soapstone notu yok.',
              style: TextStyle(
                color: GothicPalette.parchmentDim,
                fontSize: 11.5,
                fontFamily: GoogleFonts.cinzel().fontFamily,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: soapstones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final soap = soapstones[index];
        final formattedDate =
            '${soap.date.day}.${soap.date.month}.${soap.date.year}';

        return OrnateFrame(
          radius: 8,
          outerGradient: const LinearGradient(
            colors: [
              Color(0xFF3F321D),
              Color(0xFF6E5A32),
              Color(0xFF3F321D),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: GothicPalette.goldBright, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: GoogleFonts.cinzel(
                        color: GothicPalette.parchmentDim,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (soap.isEdited)
                      const Text(
                        '(Düzenlendi)',
                        style: TextStyle(
                          color: GothicPalette.parchmentDim,
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '❝ ${soap.message} ❞',
                  style: GoogleFonts.cinzel(
                    color: GothicPalette.goldBright,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReflectionsArchiveList extends StatelessWidget {
  const _ReflectionsArchiveList({required this.reflections});

  final List<Reflection> reflections;

  @override
  Widget build(BuildContext context) {
    if (reflections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.nightlight_round_outlined,
                color: GothicPalette.parchmentDim, size: 34),
            const SizedBox(height: 8),
            Text(
              'Henüz mühürlenmiş bir Muhasebe günlüğü yok.',
              style: TextStyle(
                color: GothicPalette.parchmentDim,
                fontSize: 11.5,
                fontFamily: GoogleFonts.cinzel().fontFamily,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: reflections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final refEntry = reflections[index];
        final formattedDate =
            '${refEntry.date.day}.${refEntry.date.month}.${refEntry.date.year}';

        return Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: GothicPalette.onyx,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: GothicPalette.charcoal,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: GothicPalette.emberBright, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'MUHASEBE • $formattedDate',
                    style: GoogleFonts.cinzel(
                      color: GothicPalette.goldBright,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ...refEntry.questionsAndAnswers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.cinzel(
                          color: GothicPalette.parchment,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: GothicPalette.parchmentLight,
                          fontSize: 11.5,
                          height: 1.35,
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
