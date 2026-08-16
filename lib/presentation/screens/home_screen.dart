import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldBackground,
      body: IndexedStack(
        index: _currentIndex,
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
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.local_fire_department_outlined),
              selectedIcon: Icon(Icons.local_fire_department_rounded),
              label: 'BONFIRE',
            ),
            NavigationDestination(
              icon: Icon(Icons.token_outlined),
              selectedIcon: Icon(Icons.token_rounded),
              label: 'THE KILN',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'MUHASEBE',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield_rounded),
              label: 'KAYIT',
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
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppPalette.primaryGold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'BONFIRE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          color: AppPalette.primaryGold,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                      if (user != null)
                        Text(
                          user.selectedClass.className.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: AppPalette.textAshGray,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        ),
                    ],
                  ),
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
                          'GÜN ${user?.currentStreak ?? 1}',
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
                              'CAN  ${user?.currentHp ?? 0} / ${user?.maxHp ?? 0}',
                          activeColor: AppPalette.bloodCrimson,
                        ),
                        const SizedBox(height: 12),
                        DetailedHpBar(
                          value: staminaRatio,
                          label:
                              'STAMINA  ${user?.currentStamina ?? 0} / $maxStamina',
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
                    label: 'ÖZ',
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
                        'KÜL İZİ: ${ashMark.lostEssence} Kayıp Öz • Hedef: Gün ${ashMark.targetStreak}',
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
            const SectionTitle('Bugünün Yeminleri'),
            const SizedBox(height: 6),

            // Frameless, Breathable Task List
            Expanded(
              child: todayTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bugün için henüz bir yemin edilmedi.',
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
          'Uzun Vadeli Boss Ekle',
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
              'Bağımlılık ya da irade mücadeleni bir Boss olarak tanımla (Örn: Sigarayı Bırak, Şekeri Kes).\n\n• Faz 1: 30 Gün • Faz 2: 90 Gün\n• Faz 3: 180 Gün • Faz 4: 365 Gün\n\nGünde 1 kez iradeni test et. Faz bittiğinde devasa Öz kazanırsın.',
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
              decoration: const InputDecoration(
                hintText: 'Boss / Bağımlılık Adı',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal',
                style: GoogleFonts.inter(color: AppPalette.textAshGray)),
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
            child: const Text('MEYDANA OKU'),
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
                'BOSS EKLE (Uzun Vadeli İrade Savaşı)',
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
                  boss.phase > 1 ? 'FAZ ${boss.phase}' : 'FAZ 1',
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
                      title: Text('Boss Mücadelesini Bırak?',
                          style: GoogleFonts.cinzel(
                              color: AppPalette.primaryGold)),
                      content: Text(
                          'Bu boss mücadelesini terk etmek istediğine emin misin?',
                          style: GoogleFonts.inter(
                              color: AppPalette.textBoneWhite)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('İptal')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Terk Et',
                                style: GoogleFonts.inter(
                                    color: AppPalette.bloodCrimson))),
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
            label: 'BOSS CANI  ${boss.currentHp} / ${boss.maxHp} GÜN',
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
                      'Bugünün İrade Vuruşu Tamamlandı',
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
                                '🏆 BOSS FAZ ${result.boss.phase}\'E GEÇTİ! +${result.essenceGained} Öz kazandın.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '🛡️ İradeni korudun! Boss -1 Gün kaybetti.',
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
                    label: Text('DİRENDİM',
                        style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w700)),
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
                              '💀 İraden kırıldı! -${result.damageTaken} HP hasar aldın ve Boss kendini iyileştirdi.',
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
                    label: Text('YENİLDİM',
                        style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w700)),
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
          'YENİ YEMİN ET',
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

/// Frameless Minimal Task Row separated by 1px subtle divider
class _MinimalTaskRow extends ConsumerWidget {
  const _MinimalTaskRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final isCompleted = task.isCompletedOn(DateTime.now());

    return Padding(
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
                          Text(
                            'Saat: ${task.habitTime}',
                            style: GoogleFonts.inter(
                              color: AppPalette.textAshGray,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (task.acceptedWhileExhausted)
                          Text(
                            '⚠️ Tükenmiş (1.5x Hasar)',
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
            onPressed: () =>
                ref.read(tasksProvider.notifier).deleteTask(task.id),
            icon: const Icon(
              Icons.delete_outline,
              color: AppPalette.textDim,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}
