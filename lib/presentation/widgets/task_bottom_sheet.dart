import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';
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
        color: AppPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(color: AppPalette.borderSubtle, width: 1.0),
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
                Text(
                  'YENİ YEMİN ET',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.primaryGold,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppPalette.textAshGray),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Kategori Seçimi',
              style: GoogleFonts.inter(
                color: AppPalette.textBoneWhite,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.values.map((category) {
                final selected = _selectedCategory == category;
                final reward = TaskEconomyService.rewardFor(category, user: user);
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = category),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppPalette.surfaceElevated : const Color(0xFF14161C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected ? AppPalette.primaryGold : AppPalette.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${category.label} (-${category.staminaCost} / +$reward)',
                      style: GoogleFonts.inter(
                        color: selected ? AppPalette.primaryGold : AppPalette.textAshGray,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Example habit suggestions for the selected category
            Text(
              '${_selectedCategory.label} İçin Örnek Yeminler:',
              style: GoogleFonts.inter(
                color: AppPalette.textAshGray,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: currentSuggestions.map((suggestion) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _titleController.text = suggestion;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14161C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppPalette.borderSubtle,
                        width: 0.6,
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: GoogleFonts.inter(
                        color: AppPalette.textBoneWhite,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              style: GoogleFonts.inter(color: AppPalette.textBoneWhite),
              decoration: const InputDecoration(
                hintText: 'Yemin Adı (Örn: 30 Dk Kitap Oku)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: GoogleFonts.inter(color: AppPalette.textBoneWhite),
              decoration: const InputDecoration(
                hintText: 'Açıklama (İsteğe bağlı)',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hatırlatıcı Saat',
                  style: GoogleFonts.inter(
                    color: AppPalette.textBoneWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.primaryGold,
                    side: const BorderSide(color: AppPalette.borderSubtle, width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  icon: const Icon(Icons.access_time_rounded, size: 14),
                  label: Text(
                    _habitTime ?? 'Saat Seç',
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Tekrar Günleri',
              style: GoogleFonts.inter(
                color: AppPalette.textBoneWhite,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekdays.map((item) {
                final isSelected = _selectedDays.contains(item.value);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        if (_selectedDays.length > 1) {
                          _selectedDays.remove(item.value);
                        }
                      } else {
                        _selectedDays.add(item.value);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected ? AppPalette.surfaceElevated : const Color(0xFF14161C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? AppPalette.primaryGold : AppPalette.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.label,
                        style: GoogleFonts.inter(
                          color: isSelected ? AppPalette.primaryGold : AppPalette.textAshGray,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (isExhausted) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1517),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppPalette.bloodCrimson.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppPalette.bloodBright, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stamina tükendi. Bu görevi kaçırırsan 1.5x hasar alacaksın.',
                        style: GoogleFonts.inter(
                          color: AppPalette.bloodBright,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _acceptedExhaustionRisk,
                      onChanged: (value) => setState(
                        () => _acceptedExhaustionRisk = value ?? false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _submit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPalette.primaryGold,
                  side: const BorderSide(color: AppPalette.primaryGold, width: 0.9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'YEMİNİ MÜHÜRLE',
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
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
