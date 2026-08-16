import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/core/widgets/ornate_widgets.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

const Map<TaskCategory, List<String>> _categorySuggestions = {
  TaskCategory.physical: [
    'Ağırlık Antrenmanı',
    '5 km Koşu',
    '100 Şınav & Mekik',
    'Esneme & Mobilite',
    'Tempolu Yürüyüş',
  ],
  TaskCategory.mental: [
    'Ders Çalışmak (Pomodoro)',
    '30 Sayfa Kitap Oku',
    'Kodlama / Proje Pratiği',
    'Yabancı Dil Pratiği',
    'Makale / Analiz Oku',
  ],
  TaskCategory.spiritual: [
    '15 Dk Meditasyon',
    'Günlük Tutma (Journaling)',
    'Derin Nefes Egzersizi',
    'Doğada Sessiz Yürüyüş',
    'Dijital Detoks (1 Saat)',
  ],
  TaskCategory.routine: [
    '2.5 Litre Su İç',
    'Erken Uyan (07:00)',
    'Yatağı Topla',
    'Vitaminlerini Al',
    'Ekranı 23:00\'te Kapat',
  ],
};

class TaskBottomSheet extends ConsumerStatefulWidget {
  const TaskBottomSheet({super.key});

  @override
  ConsumerState<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends ConsumerState<TaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<int> _selectedDays = {};
  TaskCategory _selectedCategory = TaskCategory.routine;
  String? _habitTime;
  bool _acceptedExhaustionRisk = false;

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
        _habitTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir görev/yemin adı girin.')),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir gün seçmelisin.')),
      );
      return;
    }

    final user = ref.read(userControllerProvider);
    final isExhausted = user != null && StaminaService.isExhausted(user);

    if (isExhausted && !_acceptedExhaustionRisk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stamina tükendi! Görevi eklemek için aşırı efor riskini onaylamalısın.',
          ),
        ),
      );
      return;
    }

    final task = Task(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      category: _selectedCategory,
      habitTime: _habitTime,
      scheduledDays: Set<int>.from(_selectedDays),
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(tasksProvider.notifier).addTask(
            task,
            acceptedExhaustionWarning: _acceptedExhaustionRisk,
          );
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
    final user = ref.watch(userControllerProvider);
    final isExhausted = user != null && StaminaService.isExhausted(user);

    final weekdays = <({String label, int value})>[
      (label: 'Pzt', value: DateTime.monday),
      (label: 'Sal', value: DateTime.tuesday),
      (label: 'Çar', value: DateTime.wednesday),
      (label: 'Per', value: DateTime.thursday),
      (label: 'Cum', value: DateTime.friday),
      (label: 'Cmt', value: DateTime.saturday),
      (label: 'Paz', value: DateTime.sunday),
    ];

    final currentSuggestions =
        _categorySuggestions[_selectedCategory] ?? const [];

    return Container(
      decoration: const BoxDecoration(
        color: GothicPalette.onyx,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: GothicPalette.bronze, width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yeni Yemin Et (Görev Ekle)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: GothicPalette.goldBright,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: GothicPalette.parchmentDim),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Kategori Seçimi',
              style: TextStyle(
                color: GothicPalette.parchmentLight,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.values.map((category) {
                final selected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(
                    '${category.label} (-${category.staminaCost} / +${category.essenceReward})',
                  ),
                  selected: selected,
                  selectedColor: GothicPalette.goldBright,
                  backgroundColor: GothicPalette.ironBlack,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.black
                        : GothicPalette.parchmentLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Example habit suggestions for the selected category
            Text(
              '${_selectedCategory.label} İçin Örnek Yeminler:',
              style: const TextStyle(
                color: GothicPalette.goldBright,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: currentSuggestions.map((suggestion) {
                return ActionChip(
                  avatar: const Icon(
                    Icons.touch_app_rounded,
                    size: 13,
                    color: GothicPalette.emberBright,
                  ),
                  label: Text(suggestion),
                  backgroundColor: const Color(0xFF1B2228),
                  side: const BorderSide(
                    color: GothicPalette.charcoal,
                    width: 0.8,
                  ),
                  labelStyle: const TextStyle(
                    color: GothicPalette.parchmentLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: () {
                    setState(() {
                      _titleController.text = suggestion;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: GothicPalette.parchmentLight),
              decoration: const InputDecoration(
                hintText: 'Yemin Adı (Örn: 30 Dk Kitap Oku)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: const TextStyle(color: GothicPalette.parchmentLight),
              decoration: const InputDecoration(
                hintText: 'Açıklama (İsteğe bağlı)',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alışkanlık Zamanı (Saat)',
                  style: TextStyle(color: GothicPalette.parchmentLight, fontSize: 13),
                ),
                TextButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time_rounded,
                      size: 16, color: GothicPalette.goldBright),
                  label: Text(
                    _habitTime ?? 'Saat Seç',
                    style: const TextStyle(color: GothicPalette.goldBright),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Haftanın Günleri',
              style: TextStyle(
                color: GothicPalette.parchmentLight,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: weekdays.map((day) {
                final value = day.value;
                final selected = _selectedDays.contains(value);
                return ChoiceChip(
                  label: Text(day.label),
                  selected: selected,
                  selectedColor: GothicPalette.goldBright,
                  backgroundColor: GothicPalette.ironBlack,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.black
                        : GothicPalette.parchmentLight,
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
            if (isExhausted) ...[
              const SizedBox(height: 16),
              OrnateFrame(
                radius: 8,
                outerGradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A1E1E),
                    Color(0xFF9E2A2A),
                    Color(0xFF3A1010),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded,
                              color: GothicPalette.emberBright, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'TÜKENMİŞLİK UYARISI',
                            style: TextStyle(
                              color: GothicPalette.bloodBright,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Stamina\'nız tükendi (0). Bu görevi eklerseniz ve gün sonunda yapmazsanız standart HP hasarı 1.5x (bir buçuk kat) olarak yansıtılacaktır.',
                        style: TextStyle(
                          color: GothicPalette.parchmentLight,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedExhaustionRisk,
                            activeColor: GothicPalette.bloodBright,
                            onChanged: (val) {
                              setState(() => _acceptedExhaustionRisk = val ?? false);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Aşırı efor riskini kabul ediyorum',
                              style: TextStyle(
                                color: GothicPalette.goldBright,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _submit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: GothicPalette.goldBright,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: GothicPalette.brass, width: 1.0),
                ),
                child: const Text(
                  'YEMİNİ MÜHÜRLE (EKLE)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
