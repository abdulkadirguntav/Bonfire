import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';
import 'package:bonfire/presentation/widgets/task_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final tasks = ref.watch(tasksProvider);
    final tasksForToday =
        tasks.where((task) => task.matchesDate(DateTime.now())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFB89B5B),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bonfire',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF14191D),
                  border: Border.all(color: const Color(0xFF2A2F36)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HP',
                            style: TextStyle(
                                color: Color(0xFFB2BAC7), fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user == null
                                ? '0/0'
                                : '${user.currentHp}/${user.maxHp}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Essence',
                            style: TextStyle(
                                color: Color(0xFFB2BAC7), fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user == null ? '0' : '${user.totalEssence}',
                            style: const TextStyle(
                              color: Color(0xFFB89B5B),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Günlük görevler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: tasksForToday.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = tasksForToday[index];
                    return _TaskCard(task: task);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFF12161A),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const TaskBottomSheet(),
          );
        },
        backgroundColor: const Color(0xFFB89B5B),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: task.isBoss ? const Color(0xFF1E1A15) : const Color(0xFF14191D),
        border: Border.all(
          color:
              task.isBoss ? const Color(0xFFB89B5B) : const Color(0xFF2A2F36),
          width: task.isBoss ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: const Color(0xFFB89B5B),
            onChanged: (value) async {
              if (user == null) return;

              final next = value ?? false;
              final delta = TaskEconomyService.calculateCompletionDelta(
                user,
                task,
                isCompleted: next,
              );

              if (delta == 0) return;

              await ref
                  .read(tasksProvider.notifier)
                  .toggleComplete(task.id, isCompleted: next);

              final updatedUser = user.copyWith(
                totalEssence: user.totalEssence + delta,
              );

              if (task.isBoss && next) {
                await ref
                    .read(userControllerProvider.notifier)
                    .markFirstBossDefeated();
              }

              await ref
                  .read(userControllerProvider.notifier)
                  .saveUser(updatedUser);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isBoss ? const Color(0xFFFFDCA0) : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (task.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      task.description,
                      style: const TextStyle(
                        color: Color(0xFFB2BAC7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (task.habitTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Zaman: ${task.habitTime}',
                      style: const TextStyle(
                        color: Color(0xFF8F949B),
                        fontSize: 11,
                      ),
                    ),
                  ),
                if (task.isBoss)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Boss task',
                      style: TextStyle(
                        color: Color(0xFFB89B5B),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(tasksProvider.notifier).removeTask(task.id);
            },
            icon: const Icon(Icons.delete_outline, color: Color(0xFFB2BAC7)),
          ),
        ],
      ),
    );
  }
}
