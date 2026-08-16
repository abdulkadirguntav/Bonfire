import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';
import 'package:bonfire/presentation/widgets/task_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final tasks = ref.watch(tasksProvider);
    final todayTasks =
        tasks.where((task) => task.matchesDate(DateTime.now())).toList();
    final hp =
        user == null || user.maxHp == 0 ? 0.0 : user.currentHp / user.maxHp;
    final maxStamina = user?.selectedClass.maxStamina ?? 0;
    final stamina = user == null || maxStamina == 0
        ? 0.0
        : user.currentStamina / maxStamina;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: GothicPalette.emberBright, size: 30),
                const SizedBox(width: 9),
                Text('BONFIRE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GothicPalette.goldBright,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3)),
              ]),
              const SizedBox(height: 18),
              OrnateFrame(
                glow: true,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: _Stat(
                                  label: 'VITALITY',
                                  value: user == null
                                      ? '0 / 0'
                                      : '${user.currentHp} / ${user.maxHp}')),
                          const SizedBox(width: 16),
                          _Stat(
                              label: 'ESSENCE',
                              value:
                                  user == null ? '0' : '${user.totalEssence}',
                              gold: true),
                        ]),
                        const SizedBox(height: 14),
                        DetailedHpBar(
                            value: hp, label: 'HEALTH  ${(hp * 100).round()}%'),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              'STAMINA  ${user?.currentStamina ?? 0} / $maxStamina',
                              style: const TextStyle(
                                color: GothicPalette.parchment,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: stamina.clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: GothicPalette.ironBlack,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    GothicPalette.goldBright,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 22),
              const SectionTitle('Today\'s vows'),
              const SizedBox(height: 12),
              Expanded(
                child: todayTasks.isEmpty
                    ? const Center(
                        child: Text('No vows have been sworn today.',
                            style:
                                TextStyle(color: GothicPalette.parchmentDim)))
                    : ListView.separated(
                        itemCount: todayTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            _TaskCard(task: todayTasks[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const TaskBottomSheet(),
        ),
        child: const Icon(Icons.add),
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
        Text(label,
            style: const TextStyle(
                color: GothicPalette.parchmentDim,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: gold
                    ? GothicPalette.goldBright
                    : GothicPalette.parchmentLight,
                fontSize: 24,
                fontWeight: FontWeight.w800)),
      ]);
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    return OrnateFrame(
      radius: 12,
      borderWidth: task.isBoss ? 1.0 : 0.7,
      outerGradient: task.isBoss
          ? GothicPalette.goldFrameGradient
          : GothicPalette.goldFrameGradientSoft,
      glow: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Checkbox(
            value: task.isCompletedOn(DateTime.now()),
            onChanged: user == null
                ? null
                : (value) async {
                    final next = value ?? false;
                    await ref
                        .read(tasksProvider.notifier)
                        .toggleComplete(task.id, isCompleted: next);
                    if (task.isBoss && next) {
                      await ref
                          .read(userControllerProvider.notifier)
                          .markFirstBossDefeated();
                    }
                  },
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title,
                  style: TextStyle(
                      color: task.isBoss
                          ? GothicPalette.goldBright
                          : GothicPalette.parchmentLight,
                      fontWeight: FontWeight.w700,
                      decoration: task.isCompletedOn(DateTime.now())
                          ? TextDecoration.lineThrough
                          : null)),
              if (task.description.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(task.description,
                        style: const TextStyle(
                            color: GothicPalette.parchment, fontSize: 12))),
              if (task.habitTime != null || task.isBoss)
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        task.isBoss
                            ? '✦ BOSS VOW${task.habitTime == null ? '' : '  •  ${task.habitTime}'}'
                            : 'TIME  ${task.habitTime}',
                        style: const TextStyle(
                            color: GothicPalette.emberBright,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1))),
            ]),
          )),
          IconButton(
              onPressed: () =>
                  ref.read(tasksProvider.notifier).removeTask(task.id),
              icon: const Icon(Icons.delete_outline,
                  color: GothicPalette.parchmentDim)),
        ]),
      ),
    );
  }
}
