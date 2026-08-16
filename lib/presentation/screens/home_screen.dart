import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/constants/daily_quotes.dart';
import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/boss_provider.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';
import 'package:bonfire/presentation/widgets/task_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final ashMark = ref.watch(ashMarkControllerProvider);
    final boss = ref.watch(bossControllerProvider);
    final tasks = ref.watch(tasksProvider);
    final today = DateTime.now();
    final todayTasks = tasks.where((task) => task.matchesDate(today)).toList();

    final hp =
        user == null || user.maxHp == 0 ? 0.0 : user.currentHp / user.maxHp;
    final maxStamina = user?.maxStamina ?? 100;
    final stamina = user == null || maxStamina == 0
        ? 0.0
        : user.currentStamina / maxStamina;

    final todayQuote = quoteForDate(today);

    return Scaffold(
      backgroundColor: GothicPalette.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: GothicPalette.emberBright,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BONFIRE',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: GothicPalette.goldBright,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                            ),
                      ),
                      if (user != null)
                        Text(
                          user.selectedClass.className.toUpperCase(),
                          style: const TextStyle(
                            color: GothicPalette.parchmentDim,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          'GÜN ${user?.currentStreak ?? 1}',
                          style: const TextStyle(
                            color: GothicPalette.parchmentLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Status frame: HP, Stamina, Essence
              OrnateFrame(
                glow: true,
                radius: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            DetailedHpBar(
                              value: hp,
                              label:
                                  'CAN (HP)  ${user?.currentHp ?? 0} / ${user?.maxHp ?? 0}',
                              height: 12,
                              fillGradient: GothicPalette.healthCore,
                            ),
                            const SizedBox(height: 10),
                            DetailedHpBar(
                              value: stamina,
                              label:
                                  'STAMINA  ${user?.currentStamina ?? 0} / $maxStamina',
                              height: 12,
                              fillGradient: GothicPalette.staminaCore,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _Stat(
                        label: 'ÖZ (ESSENCE)',
                        value: user == null ? '0' : '${user.essence}',
                        gold: true,
                      ),
                    ],
                  ),
                ),
              ),
              // Ash mark reclaim banner
              if (ashMark != null) ...[
                const SizedBox(height: 10),
                OrnateFrame(
                  radius: 8,
                  outerGradient: const LinearGradient(
                    colors: [
                      Color(0xFF5A1E1E),
                      Color(0xFF8E2A2A),
                      Color(0xFF3A1212),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.replay_rounded,
                          color: GothicPalette.bloodBright,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'KÜL İZİ: ${ashMark.lostEssence} Kayıp Öz • Hedef: Gün ${ashMark.targetStreak}',
                            style: const TextStyle(
                              color: GothicPalette.parchmentLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Boss Battle Card
              if (boss == null)
                _AddBossButton(
                  onPressed: () => _showAddBossDialog(context, ref),
                )
              else
                _BossBattleCard(boss: boss),
              const SizedBox(height: 10),
              // Daily Philosophical Quote Card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: GothicPalette.onyx,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: GothicPalette.charcoal,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '❝',
                      style: TextStyle(
                        color: GothicPalette.goldBright,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        todayQuote,
                        style: const TextStyle(
                          color: GothicPalette.parchment,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const SectionTitle('Bugünün Yeminleri (Vows)'),
              const SizedBox(height: 8),
              Expanded(
                child: todayTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Bugün için henüz bir yemin edilmedi.',
                              style: TextStyle(
                                color: GothicPalette.parchmentDim,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _AddTaskRow(
                              onPressed: () => _showTaskSheet(context),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 4),
                        itemCount: todayTasks.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          if (index == todayTasks.length) {
                            return _AddTaskRow(
                              onPressed: () => _showTaskSheet(context),
                            );
                          }
                          return _TaskCard(task: todayTasks[index]);
                        },
                      ),
              ),
            ],
          ),
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
        backgroundColor: GothicPalette.onyx,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GothicPalette.bronze, width: 0.8),
        ),
        title: const Text(
          'Uzun Vadeli Boss Ekle',
          style: TextStyle(
            color: GothicPalette.goldBright,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bağımlılık ya da irade mücadeleni bir Boss olarak tanımla (Örn: Sigarayı Bırak, Şekeri Kes).\n\n• Faz 1: 30 Gün\n• Faz 2: 90 Gün\n• Faz 3: 180 Gün\n• Faz 4: 365 Gün\n\nGünde 1 kez iradeni test et. Direndikçe canı azalır, her faz bittiğinde devasa Öz kazanırsın!',
              style: TextStyle(color: GothicPalette.parchment, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              style: const TextStyle(color: GothicPalette.parchmentLight),
              decoration: const InputDecoration(
                hintText: 'Boss / Bağımlılık Adı',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal', style: TextStyle(color: GothicPalette.parchmentDim)),
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
              foregroundColor: GothicPalette.goldBright,
              side: const BorderSide(color: GothicPalette.brass),
            ),
            child: const Text('BOSS\'U MEYDANA OKU'),
          ),
        ],
      ),
    );
  }
}

class _AddBossButton extends StatelessWidget {
  const _AddBossButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: OrnateFrame(
        radius: 10,
        outerGradient: const LinearGradient(
          colors: [
            Color(0xFF3F321D),
            Color(0xFF6E5A32),
            Color(0xFF3F321D),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: const [
              Icon(Icons.shield_outlined, color: GothicPalette.goldBright, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '⚔️ BOSS EKLE (Uzun Vadeli Bağımlılık Savaşı)',
                  style: TextStyle(
                    color: GothicPalette.goldBright,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Icon(Icons.add, color: GothicPalette.goldBright, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _BossBattleCard extends ConsumerWidget {
  const _BossBattleCard({required this.boss});

  final dynamic boss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double hpRatio = boss.maxHp > 0 ? boss.currentHp / boss.maxHp : 0.0;
    final bool hasInteractedToday = boss.wasInteractedOn(DateTime.now());

    return OrnateFrame(
      radius: 12,
      outerGradient: const LinearGradient(
        colors: [
          Color(0xFF4A1A1A),
          Color(0xFF8A3030),
          Color(0xFF6A2020),
          Color(0xFF3A1212),
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
                const Icon(Icons.dangerous_rounded,
                    color: GothicPalette.bloodBright, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'BOSS: ${boss.title.toUpperCase()}',
                    style: const TextStyle(
                      color: GothicPalette.goldBright,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GothicPalette.bloodBright,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    boss.phase > 1 ? 'FAZ ${boss.phase} (MUTATED)' : 'FAZ 1',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: GothicPalette.parchmentDim, size: 16),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: GothicPalette.onyx,
                        title: const Text('Boss Mücadelesini Bırak?',
                            style: TextStyle(color: GothicPalette.goldBright)),
                        content: const Text(
                            'Bu boss\'u terk etmek istediğine emin misin?',
                            style: TextStyle(color: GothicPalette.parchment)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('İptal')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Terk Et',
                                  style: TextStyle(color: GothicPalette.bloodBright))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(bossControllerProvider.notifier).abandonBoss();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            DetailedHpBar(
              value: hpRatio,
              label: 'BOSS HP  ${boss.currentHp} / ${boss.maxHp} GÜN',
              height: 11,
              fillGradient: const LinearGradient(
                colors: [Color(0xFFE25822), Color(0xFF8E2A2A)],
              ),
            ),
            const SizedBox(height: 10),
            if (hasInteractedToday)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: GothicPalette.ironBlack,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GothicPalette.charcoal, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle_outline_rounded,
                        color: GothicPalette.goldBright, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Bugünün İrade Vuruşu Tamamlandı (Yarın Yenilenecek)',
                      style: TextStyle(
                        color: GothicPalette.parchmentLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
                                backgroundColor: GothicPalette.goldDeep,
                                content: Text(
                                  '🏆 BOSS FAZ ${result.boss.phase}\'E GEÇTİ (${result.boss.maxHp} Gün)! +${result.essenceGained} devasa Öz kazandın!',
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
                        foregroundColor: GothicPalette.goldBright,
                        side: const BorderSide(color: GothicPalette.brass, width: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.shield_rounded, size: 15),
                      label: const Text('DİRENDİM',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
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
                              backgroundColor: GothicPalette.blood,
                              content: Text(
                                '💀 İraden kırıldı! -${result.damageTaken} HP hasar aldın ve Boss kendini iyileştirdi (+1 Gün).',
                              ),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GothicPalette.bloodBright,
                        side: const BorderSide(color: GothicPalette.blood, width: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      icon: const Icon(Icons.heart_broken_rounded, size: 15),
                      label: const Text('YENİLDİM',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AddTaskRow extends StatelessWidget {
  const _AddTaskRow({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: GothicPalette.goldBright,
          side: const BorderSide(color: GothicPalette.bronze, width: 0.8),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'YENİ YEMİN ET',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.gold = false});

  final String label;
  final String value;
  final bool gold;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          label,
          style: const TextStyle(
            color: GothicPalette.parchmentDim,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: gold ? GothicPalette.goldBright : GothicPalette.parchmentLight,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ]);
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final isCompleted = task.isCompletedOn(DateTime.now());

    return OrnateFrame(
      radius: 10,
      borderWidth: 0.7,
      outerGradient: task.acceptedWhileExhausted
          ? const LinearGradient(
              colors: [
                Color(0xFF5A2222),
                Color(0xFF8E2A2A),
                Color(0xFF4A1818),
              ],
            )
          : GothicPalette.goldFrameGradientSoft,
      glow: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isCompleted,
              activeColor: GothicPalette.gold,
              onChanged: user == null
                  ? null
                  : (value) async {
                      final next = value ?? false;
                      await ref
                          .read(tasksProvider.notifier)
                          .toggleComplete(task.id, isCompleted: next);
                    },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: GothicPalette.parchmentLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              decoration:
                                  isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GothicPalette.ironBlack,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: GothicPalette.bronze,
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            '${task.category.label} (-${task.category.staminaCost} / +${TaskEconomyService.rewardFor(task.category, user: user)})',
                            style: const TextStyle(
                              color: GothicPalette.goldBright,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          task.description,
                          style: const TextStyle(
                            color: GothicPalette.parchment,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (task.habitTime != null) ...[
                            Text(
                              'SAAT: ${task.habitTime}',
                              style: const TextStyle(
                                color: GothicPalette.emberBright,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (task.acceptedWhileExhausted)
                            const Text(
                              '⚠️ TÜKENMİŞ (1.5x Hasar)',
                              style: TextStyle(
                                color: GothicPalette.bloodBright,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(tasksProvider.notifier).deleteTask(task.id),
              icon: const Icon(
                Icons.delete_outline,
                color: GothicPalette.parchmentDim,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
