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
    const maxStamina = User.maxStamina;
    final stamina = user == null || maxStamina == 0
        ? 0.0
        : user.currentStamina / maxStamina;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: GothicPalette.emberBright, size: 25),
                const SizedBox(width: 9),
                Text('BONFIRE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GothicPalette.goldBright,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5)),
                const Spacer(),
                Text(
                  'TODAY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: GothicPalette.parchmentDim,
                        letterSpacing: 1.6,
                      ),
                ),
              ]),
              const SizedBox(height: 14),
              OrnateFrame(
                glow: true,
                radius: 10,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  DetailedHpBar(
                                    value: hp,
                                    label:
                                        'HEALTH  ${user?.currentHp ?? 0} / ${user?.maxHp ?? 0}',
                                    height: 12,
                                    fillGradient: GothicPalette.healthCore,
                                  ),
                                  const SizedBox(height: 12),
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
                              label: 'ESSENCE',
                              value: user == null ? '0' : '${user.essence}',
                              gold: true,
                            ),
                          ],
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 20),
              const SectionTitle('Today\'s vows'),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 4),
                  itemCount: todayTasks.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bu bölüm Faz 1 kapsamı dışında.')),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Kiln',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
        ],
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
        icon: const Icon(Icons.add_rounded, size: 19),
        label: const Text('SWEAR A NEW VOW'),
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
      borderWidth: 0.7,
      outerGradient: GothicPalette.goldFrameGradientSoft,
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
                  },
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title,
                  style: TextStyle(
                      color: GothicPalette.parchmentLight,
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
              if (task.habitTime != null)
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        'TIME  ${task.habitTime}',
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
