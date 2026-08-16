import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/core/theme/gothic_theme.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  CharacterClass _selectedClass = CharacterClass.warrior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: GothicPalette.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: GothicPalette.emberBright,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BONFIRE',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: GothicPalette.goldBright,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Sınıfını Seç (Choose Your Path)',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: GothicPalette.parchmentLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bonfire yolculuğuna hangi karakterin güç ve zayıflıklarıyla başlayacaksın?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: GothicPalette.parchmentDim,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: CharacterClass.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final characterClass = CharacterClass.values[index];
                    final isSelected = _selectedClass == characterClass;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E2A2F)
                            : const Color(0xFF12161A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? GothicPalette.goldBright
                              : GothicPalette.charcoal,
                          width: isSelected ? 1.2 : 0.8,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            setState(() => _selectedClass = characterClass),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? GothicPalette.goldBright
                                          : GothicPalette.ironBlack,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: GothicPalette.bronze,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        characterClass.className.substring(0, 1),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.black
                                              : GothicPalette.parchmentLight,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          characterClass.className,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: isSelected
                                                ? GothicPalette.goldBright
                                                : GothicPalette.parchmentLight,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'HP: ${characterClass.baseHp} • Stamina: ${characterClass.maxStamina} • Öz: ${characterClass.essenceMultiplier}x • Hasar: ${characterClass.damageMultiplier}x',
                                          style: const TextStyle(
                                            color: GothicPalette.parchmentDim,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: GothicPalette.goldBright,
                                      size: 22,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                characterClass.description,
                                style: const TextStyle(
                                  color: GothicPalette.parchment,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(userControllerProvider.notifier)
                        .selectClass(_selectedClass);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GothicPalette.goldBright,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: GothicPalette.brass,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '${_selectedClass.className.toUpperCase()} OLARAK YOLCULUĞA BAŞLA',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
