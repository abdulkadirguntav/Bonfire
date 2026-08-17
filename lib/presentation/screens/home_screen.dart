import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/localization/app_localizations.dart';
import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/core/widgets/bonfire_logo.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/boss_provider.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';
import 'package:bonfire/presentation/screens/ashen_record_screen.dart';
import 'package:bonfire/presentation/screens/journey_screen.dart';
import 'package:bonfire/presentation/screens/reflection_screen.dart';
import 'package:bonfire/presentation/screens/shop_screen.dart';
import 'package:bonfire/presentation/widgets/soapstone_rune_card.dart';
import 'package:bonfire/presentation/widgets/task_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppPalette.scaffoldBackground,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: const [
          _DashboardView(),
          ShopScreen(),
          ReflectionScreen(),
          AshenRecordScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppPalette.dividerLine,
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.local_fire_department_outlined),
              selectedIcon: const Icon(Icons.local_fire_department_rounded),
              label: l10n.tabBonfire,
            ),
            NavigationDestination(
              icon: const Icon(Icons.token_outlined),
              selectedIcon: const Icon(Icons.token_rounded),
              label: l10n.tabShop,
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_rounded),
              label: l10n.tabReflection,
            ),
            NavigationDestination(
              icon: const Icon(Icons.shield_outlined),
              selectedIcon: const Icon(Icons.shield_rounded),
              label: l10n.tabRecord,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends ConsumerWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userControllerProvider);
    final ashMark = ref.watch(ashMarkControllerProvider);
    final boss = ref.watch(bossControllerProvider);
    final tasks = ref.watch(tasksProvider);
    final today = DateTime.now();
    final todayTasks = tasks.where((task) => task.matchesDate(today)).toList();

    final hpRatio =
        user == null || user.maxHp == 0 ? 0.0 : user.currentHp / user.maxHp;
    final maxStamina = user?.maxStamina ?? 100;
    final staminaRatio = user == null || maxStamina == 0
        ? 0.0
        : user.currentStamina / maxStamina;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Row(
              children: [
                const BonfireLogo(size: 32, fontSize: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: user != null
                      ? Text(
                          l10n.className(user.selectedClass.name).toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: AppPalette.textAshGray,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                // Minimal Streak Badge -> Tap navigates to The Chronicle
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const JourneyScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
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
                          '${l10n.streakDay} ${user?.currentStreak ?? 1}',
                          style: GoogleFonts.inter(
                            color: AppPalette.textBoneWhite,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppPalette.textAshGray,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Minimalist Status Card (HP, Stamina, Essence)
            Container(
              padding: const EdgeInsets.all(14),
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
                  Expanded(
                    child: Column(
                      children: [
                        DetailedHpBar(
                          value: hpRatio,
                          label:
                              '${l10n.health}  ${user?.currentHp ?? 0} / ${user?.maxHp ?? 0}',
                          activeColor: AppPalette.bloodCrimson,
                        ),
                        const SizedBox(height: 12),
                        DetailedHpBar(
                          value: staminaRatio,
                          label:
                              '${l10n.stamina}  ${user?.currentStamina ?? 0} / $maxStamina',
                          activeColor: AppPalette.staminaBlue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 1,
                    height: 52,
                    color: AppPalette.dividerLine,
                  ),
                  const SizedBox(width: 16),
                  MinimalStatBadge(
                    label: l10n.essence,
                    value: user == null ? '0' : '${user.essence}',
                    isGold: true,
                  ),
                ],
              ),
            ),

            // Ash Mark banner (Only when actual lost essence exists)
            if (ashMark != null && ashMark.lostEssence > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1517),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppPalette.bloodCrimson.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.replay_rounded,
                      color: AppPalette.bloodBright,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.isTurkish
                            ? 'KÜL İZİ: ${ashMark.lostEssence} Kayıp Öz • Hedef: Gün ${ashMark.targetStreak}'
                            : 'ASH MARK: ${ashMark.lostEssence} Lost Essence • Target: Day ${ashMark.targetStreak}',
                        style: GoogleFonts.inter(
                          color: AppPalette.textBoneWhite,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Boss Section
            if (boss == null)
              _AddBossMinimalButton(
                onPressed: () => _showAddBossDialog(context, ref),
              )
            else
              _BossBattleMinimalCard(boss: boss),

            const SizedBox(height: 10),

            // Soapstone Rune Card
            const SoapstoneRuneCard(),

            const SizedBox(height: 12),

            // Vows (Habits) Header
            SectionTitle(l10n.vowsTitle),
            const SizedBox(height: 6),

            // Frameless, Breathable Task List
            Expanded(
              child: todayTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.noVows,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppPalette.textAshGray,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _AddTaskMinimalButton(
                            onPressed: () => _showTaskSheet(context),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 6),
                      itemCount: todayTasks.length + 1,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppPalette.dividerLine,
                      ),
                      itemBuilder: (_, index) {
                        if (index == todayTasks.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _AddTaskMinimalButton(
                              onPressed: () => _showTaskSheet(context),
                            ),
                          );
                        }
                        return _MinimalTaskRow(task: todayTasks[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaskBottomSheet(),
    );
  }

  static void _showAddBossDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPalette.borderSubtle, width: 0.8),
        ),
        title: Text(
          l10n.isTurkish ? 'Uzun Vadeli Boss Ekle' : 'Create Long-Term Boss',
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
              l10n.isTurkish
                  ? 'Bağımlılık ya da irade mücadeleni bir Boss olarak tanımla (Örn: Sigarayı Bırak, Şekeri Kes).\n\n• Faz 1: 30 Gün • Faz 2: 90 Gün\n• Faz 3: 180 Gün • Faz 4: 365 Gün\n\nGünde 1 kez iradeni test et. Faz bittiğinde devasa Öz kazanırsın.'
                  : 'Formulate an addiction or willpower battle as an Ancient Boss (e.g. Quit Smoking, Cut Sugar).\n\n• Phase 1: 30 Days • Phase 2: 90 Days\n• Phase 3: 180 Days • Phase 4: 365 Days\n\nStrike once per day. Massive Essence rewarded on phase defeat.',
              style: GoogleFonts.inter(
                color: AppPalette.textBoneWhite,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              style: GoogleFonts.inter(color: AppPalette.textBoneWhite),
              decoration: InputDecoration(
                hintText: l10n.isTurkish
                    ? 'Boss / Bağımlılık Adı'
                    : 'Boss / Habit Name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(color: AppPalette.textAshGray),
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final text = titleController.text.trim();
              if (text.isEmpty) return;
              await ref
                  .read(bossControllerProvider.notifier)
                  .createBoss(title: text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPalette.primaryGold,
              side: const BorderSide(color: AppPalette.primaryGold, width: 0.8),
            ),
            child: Text(l10n.isTurkish ? 'MEYDANA OKU' : 'CHALLENGE'),
          ),
        ],
      ),
    );
  }
}

class _AddBossMinimalButton extends StatelessWidget {
  const _AddBossMinimalButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
            const Icon(Icons.shield_outlined,
                color: AppPalette.primaryGold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.isTurkish
                    ? 'BOSS EKLE (Uzun Vadeli İrade Savaşı)'
                    : 'ADD BOSS (Long-term Will Battle)',
                style: GoogleFonts.cinzel(
                  color: AppPalette.primaryGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const Icon(Icons.add, color: AppPalette.primaryGold, size: 16),
          ],
        ),
      ),
    );
  }
}

class _BossBattleMinimalCard extends ConsumerWidget {
  const _BossBattleMinimalCard({required this.boss});

  final dynamic boss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final double hpRatio = boss.maxHp > 0 ? boss.currentHp / boss.maxHp : 0.0;
    final bool hasInteractedToday = boss.wasInteractedOn(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppPalette.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dangerous_rounded,
                  color: AppPalette.bloodCrimson, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'BOSS: ${boss.title.toUpperCase()}',
                  style: GoogleFonts.cinzel(
                    color: AppPalette.textBoneWhite,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B1618),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppPalette.bloodCrimson.withValues(alpha: 0.6),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  boss.phase > 1
                      ? (l10n.isTurkish
                          ? 'FAZ ${boss.phase}'
                          : 'PHASE ${boss.phase}')
                      : (l10n.isTurkish ? 'FAZ 1' : 'PHASE 1'),
                  style: GoogleFonts.inter(
                    color: AppPalette.bloodBright,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close,
                    color: AppPalette.textAshGray, size: 15),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppPalette.surface,
                      title: Text(
                        l10n.isTurkish
                            ? 'Boss Mücadelesini Bırak?'
                            : 'Abandon Boss Battle?',
                        style:
                            GoogleFonts.cinzel(color: AppPalette.primaryGold),
                      ),
                      content: Text(
                        l10n.isTurkish
                            ? 'Bu boss mücadelesini terk etmek istediğine emin misin?'
                            : 'Are you sure you wish to abandon this battle?',
                        style:
                            GoogleFonts.inter(color: AppPalette.textBoneWhite),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            l10n.cancel,
                            style: GoogleFonts.inter(
                                color: AppPalette.textAshGray),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            l10n.isTurkish ? 'Terk Et' : 'Abandon',
                            style: GoogleFonts.inter(
                                color: AppPalette.bloodCrimson),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(bossControllerProvider.notifier)
                        .abandonBoss();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          DetailedHpBar(
            value: hpRatio,
            label:
                '${l10n.bossHp}  ${boss.currentHp} / ${boss.maxHp} ${l10n.streakDay}',
            activeColor: AppPalette.bloodCrimson,
          ),
          const SizedBox(height: 10),
          if (hasInteractedToday)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF14161C),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppPalette.borderSubtle, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppPalette.primaryGold, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.bossStruckToday,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppPalette.textAshGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await ref
                          .read(bossControllerProvider.notifier)
                          .resist();
                      if (result != null && context.mounted) {
                        if (result.didPhaseMutate) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.isTurkish
                                    ? '🏆 BOSS FAZ ${result.boss.phase}\'E GEÇTİ! +${result.essenceGained} Öz kazandın.'
                                    : '🏆 BOSS MUTATED TO PHASE ${result.boss.phase}! +${result.essenceGained} Essence reclaimed.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.isTurkish
                                    ? '🛡️ İradeni korudun! Boss -1 Gün kaybetti.'
                                    : '🛡️ Fortitude proven! Boss lost 1 HP.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.primaryGold,
                      side: const BorderSide(
                          color: AppPalette.primaryGold, width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    icon: const Icon(Icons.shield_rounded, size: 14),
                    label: Text(
                      l10n.isTurkish ? 'DİRENDİM' : 'STAND FIRM',
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await ref
                          .read(bossControllerProvider.notifier)
                          .fail();
                      if (result != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.isTurkish
                                  ? '💀 İraden kırıldı! -${result.damageTaken} HP hasar aldın ve Boss kendini iyileştirdi.'
                                  : '💀 Will faltered! Suffered -${result.damageTaken} HP damage.',
                            ),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.bloodBright,
                      side: const BorderSide(
                          color: AppPalette.bloodCrimson, width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    icon: const Icon(Icons.heart_broken_rounded, size: 14),
                    label: Text(
                      l10n.isTurkish ? 'YENİLDİM' : 'FALTER',
                      style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AddTaskMinimalButton extends StatelessWidget {
  const _AddTaskMinimalButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.primaryGold,
          side: const BorderSide(color: AppPalette.borderSubtle, width: 0.9),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: Text(
          l10n.addVow.toUpperCase(),
          style: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

/// Frameless Minimal Task Row with Swipe-to-Delete and Confirmation
class _MinimalTaskRow extends ConsumerWidget {
  const _MinimalTaskRow({required this.task});

  final Task task;

  Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
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
          l10n.deleteVowTitle,
          style: GoogleFonts.cinzel(
            color: AppPalette.bloodBright,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        content: Text(
          l10n.isTurkish
              ? '\'${task.title}\' yemini silinecektir. Harcanan ${task.category.staminaCost} Stamina iade edilecektir.\n\nEmin misin?'
              : 'Vow \'${task.title}\' will be forsaken. Consumed ${task.category.staminaCost} Stamina will be refunded.\n\nAre you sure?',
          style: GoogleFonts.inter(
            color: AppPalette.textBoneWhite,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(color: AppPalette.textAshGray),
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
              l10n.delete,
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userControllerProvider);
    final isCompleted = task.isCompletedOn(DateTime.now());

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (direction) async {
        await ref.read(tasksProvider.notifier).deleteTask(task.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppPalette.bloodCrimson.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.delete,
              style: GoogleFonts.cinzel(
                color: AppPalette.bloodBright,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.delete_forever_rounded,
              color: AppPalette.bloodBright,
              size: 20,
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: user == null
                  ? null
                  : (value) async {
                      final next = value ?? false;
                      await ref
                          .read(tasksProvider.notifier)
                          .toggleComplete(task.id, isCompleted: next);
                    },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.inter(
                            color: isCompleted
                                ? AppPalette.textAshGray
                                : AppPalette.textBoneWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.5,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14161C),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppPalette.borderSubtle,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          '${task.category.label} (-${task.category.staminaCost} / +${TaskEconomyService.rewardFor(task.category, user: user)})',
                          style: GoogleFonts.inter(
                            color: AppPalette.primaryGold,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        task.description,
                        style: GoogleFonts.inter(
                          color: AppPalette.textAshGray,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (task.habitTime != null || task.acceptedWhileExhausted)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (task.habitTime != null) ...[
                            const Icon(
                              Icons.alarm_on_rounded,
                              size: 11,
                              color: AppPalette.primaryGold,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${l10n.habitTime}: ${task.habitTime}',
                              style: GoogleFonts.inter(
                                color: AppPalette.textAshGray,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (task.acceptedWhileExhausted)
                            Text(
                              l10n.isTurkish
                                  ? '⚠️ Tükenmiş (1.5x Hasar)'
                                  : '⚠️ Exhausted (1.5x Damage)',
                              style: GoogleFonts.inter(
                                color: AppPalette.bloodCrimson,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final confirm = await _confirmDelete(context);
                if (confirm) {
                  await ref.read(tasksProvider.notifier).deleteTask(task.id);
                }
              },
              icon: const Icon(
                Icons.delete_outline,
                color: AppPalette.textDim,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
