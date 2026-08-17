import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/localization/app_localizations.dart';
import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/domain/models/task.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/domain/services/task_economy_service.dart';
import 'package:bonfire/presentation/providers/task_provider.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

const Map<TaskCategory, List<String>> _categorySuggestionsTr = {
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

const Map<TaskCategory, List<String>> _categorySuggestionsEn = {
  TaskCategory.physical: [
    'Strength Training',
    '5 km Run',
    '100 Push-ups & Sit-ups',
    'Stretching & Mobility',
    'Brisk Walking',
  ],
  TaskCategory.mental: [
    'Deep Study (Pomodoro)',
    'Read 30 Pages',
    'Coding / Project Work',
    'Language Practice',
    'Read an Article',
  ],
  TaskCategory.spiritual: [
    '15 Min Meditation',
    'Stoic Journaling',
    'Deep Breathing Session',
    'Nature Walk in Silence',
    'Digital Detox (1 Hour)',
  ],
  TaskCategory.routine: [
    'Drink 2.5L Water',
    'Early Rise (07:00)',
    'Make Bed',
    'Take Vitamins',
    'Screen Off by 23:00',
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
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.isTurkish
              ? 'Lütfen bir yemin adı girin.'
              : 'Please enter a vow name.'),
        ),
      );
      return;
    }

    try {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        description: description,
        scheduledDays: _selectedDays,
        habitTime: _habitTime,
        acceptedWhileExhausted: _acceptedExhaustionRisk,
      );

      await ref.read(tasksProvider.notifier).addTask(
            task,
            acceptedExhaustionWarning: _acceptedExhaustionRisk,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ExhaustionWarningRequired {
      if (!mounted) return;
      setState(() {
        _acceptedExhaustionRisk = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isTurkish
                ? '⚠️ Yetersiz Stamina! Devam etmek için aşağıdaki tükenmişlik risk kutucuğunu onaylayın.'
                : '⚠️ Insufficient Stamina! Check the exhaustion risk box to proceed.',
          ),
          backgroundColor: AppPalette.bloodCrimson,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userControllerProvider);
    final isExhausted = user != null && StaminaService.isExhausted(user);

    final suggestionsMap =
        l10n.isTurkish ? _categorySuggestionsTr : _categorySuggestionsEn;
    final currentSuggestions =
        suggestionsMap[_selectedCategory] ?? const <String>[];

    final weekdays = l10n.isTurkish
        ? [
            (label: 'Pzt', value: DateTime.monday),
            (label: 'Sal', value: DateTime.tuesday),
            (label: 'Çar', value: DateTime.wednesday),
            (label: 'Per', value: DateTime.thursday),
            (label: 'Cum', value: DateTime.friday),
            (label: 'Cmt', value: DateTime.saturday),
            (label: 'Paz', value: DateTime.sunday),
          ]
        : [
            (label: 'Mon', value: DateTime.monday),
            (label: 'Tue', value: DateTime.tuesday),
            (label: 'Wed', value: DateTime.wednesday),
            (label: 'Thu', value: DateTime.thursday),
            (label: 'Fri', value: DateTime.friday),
            (label: 'Sat', value: DateTime.saturday),
            (label: 'Sun', value: DateTime.sunday),
          ];

    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AppPalette.primaryGold, width: 1.2),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
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
                  l10n.isTurkish ? 'YENİ GÜNLÜK YEMİN' : 'NEW DAILY VOW',
                  style: GoogleFonts.cinzel(
                    color: AppPalette.primaryGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
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
              l10n.isTurkish ? 'Kategori Seçimi' : 'Vow Category',
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
                final reward =
                    TaskEconomyService.rewardFor(category, user: user);
                final categoryLabel =
                    l10n.isTurkish ? category.label : _categoryNameEn(category);
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = category),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppPalette.surfaceElevated
                          : const Color(0xFF14161C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? AppPalette.primaryGold
                            : AppPalette.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '$categoryLabel (-${category.staminaCost} / +$reward)',
                      style: GoogleFonts.inter(
                        color: selected
                            ? AppPalette.primaryGold
                            : AppPalette.textAshGray,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
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
              l10n.isTurkish
                  ? '${_selectedCategory.label} İçin Örnek Yeminler:'
                  : 'Suggestions for ${_categoryNameEn(_selectedCategory)}:',
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              decoration: InputDecoration(
                hintText: l10n.isTurkish
                    ? 'Yemin Adı (Örn: 30 Dk Kitap Oku)'
                    : 'Vow Title (e.g. Read 30 Min)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              style: GoogleFonts.inter(color: AppPalette.textBoneWhite),
              decoration: InputDecoration(
                hintText: l10n.isTurkish
                    ? 'Açıklama (İsteğe bağlı)'
                    : 'Description (Optional)',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.habitTime,
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
                    side: const BorderSide(
                        color: AppPalette.borderSubtle, width: 0.8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  icon: const Icon(Icons.access_time_rounded, size: 14),
                  label: Text(
                    _habitTime ?? (l10n.isTurkish ? 'Saat Seç' : 'Pick Time'),
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.isTurkish ? 'Tekrar Günleri' : 'Repeat Days',
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
                      color: isSelected
                          ? AppPalette.surfaceElevated
                          : const Color(0xFF14161C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppPalette.primaryGold
                            : AppPalette.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.label,
                        style: GoogleFonts.inter(
                          color: isSelected
                              ? AppPalette.primaryGold
                              : AppPalette.textAshGray,
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
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
                        l10n.isTurkish
                            ? 'Stamina tükendi. Bu görevi kaçırırsan 1.5x hasar alacaksın.'
                            : 'Stamina exhausted. Missing this vow will inflict 1.5x damage.',
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
                  side: const BorderSide(
                      color: AppPalette.primaryGold, width: 0.9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.isTurkish ? 'YEMİNİ MÜHÜRLE' : 'SEAL VOW',
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

  String _categoryNameEn(TaskCategory category) {
    switch (category) {
      case TaskCategory.physical:
        return 'Physical';
      case TaskCategory.mental:
        return 'Mental';
      case TaskCategory.spiritual:
        return 'Spiritual';
      case TaskCategory.routine:
        return 'Routine';
    }
  }
}
