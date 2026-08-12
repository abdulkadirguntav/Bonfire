import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';

class TaskBottomSheet extends ConsumerStatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<int> _selectedDays = {};
  String? _habitTime;
  bool _isBoss = false;

  @override
  void initState() {
    super.initState();
    _selectedDays.add(DateTime.now().weekday);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final time = await showTimePicker(
      context: context,
      initialTime: _habitTime != null ? _parseTime(_habitTime!) : now,
    );

    if (time != null) {
      setState(() {
        _habitTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      return;
    }

    if (_selectedDays.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('En az bir gün seçmelisin.')),
        );
      }
      return;
    }

    final task = Task(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      isBoss: _isBoss,
      rewardValue: _isBoss ? 20 : 10,
      habitTime: _habitTime,
      scheduledDays: Set<int>.from(_selectedDays),
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(tasksProvider.notifier).addTask(task);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = <({String label, int value})>[
      (label: 'Pzt', value: DateTime.monday),
      (label: 'Sal', value: DateTime.tuesday),
      (label: 'Çar', value: DateTime.wednesday),
      (label: 'Per', value: DateTime.thursday),
      (label: 'Cum', value: DateTime.friday),
      (label: 'Cmt', value: DateTime.saturday),
      (label: 'Paz', value: DateTime.sunday),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Görev ekle',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Görev adı',
              hintStyle: const TextStyle(color: Color(0xFF8F949B)),
              filled: true,
              fillColor: const Color(0xFF191D22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Açıklama',
              hintStyle: const TextStyle(color: Color(0xFF8F949B)),
              filled: true,
              fillColor: const Color(0xFF191D22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Boss görevi',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              Switch(
                value: _isBoss,
                onChanged: (value) => setState(() => _isBoss = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alışkanlık zamanı',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: _pickTime,
                child: Text(
                  _habitTime ?? 'Seç',
                  style: const TextStyle(color: Color(0xFFB89B5B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Haftanın günleri',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekdays.map((day) {
              final value = day.value;
              final selected = _selectedDays.contains(value);
              return ChoiceChip(
                label: Text(day.label),
                selected: selected,
                selectedColor: const Color(0xFFB89B5B),
                labelStyle: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _selectedDays.remove(value);
                    } else {
                      _selectedDays.add(value);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB89B5B),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Görevi ekle'),
            ),
          ),
        ],
      ),
    );
  }
}
