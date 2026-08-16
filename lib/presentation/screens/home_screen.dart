import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/constants/daily_quotes.dart';
import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';
import 'package:bonfire/presentation/widgets/task_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final ashMark = ref.watch(ashMarkControllerProvider);
    final tasks = ref.watch(tasksProvider);
    final today = DateTime.now();
    final todayTasks = tasks.where((task) => task.matchesDate(today)).toList();

    final hp =
        user == null || user.maxHp == 0 ? 0.0 : user.currentHp / user.maxHp;
    const maxStamina = User.maxStamina;
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
                  Text(
                    'BONFIRE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: GothicPalette.goldBright,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
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
              const SizedBox(height: 12),
              // Daily Philosophical Quote Card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        fontSize: 16,
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
              const SizedBox(height: 14),
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
                            '${task.category.label} (-${task.category.staminaCost} / +${task.category.essenceReward})',
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
                  ref.read(tasksProvider.notifier).removeTask(task.id),
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
