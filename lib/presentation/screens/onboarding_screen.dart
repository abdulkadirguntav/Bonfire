import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/theme/app_theme.dart';
import 'package:bonfire/core/widgets/bonfire_logo.dart';
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
    return Scaffold(
      backgroundColor: AppPalette.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: BonfireLogo(size: 32, fontSize: 24),
              ),
              const SizedBox(height: 14),
              Text(
                'Sınıfını Seç (Choose Your Path)',
                style: GoogleFonts.cinzel(
                  color: AppPalette.textBoneWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bonfire yolculuğuna hangi karakterin güç ve zayıflıklarıyla başlayacaksın?',
                style: GoogleFonts.inter(
                  color: AppPalette.textAshGray,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: CharacterClass.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final characterClass = CharacterClass.values[index];
                    final isSelected = _selectedClass == characterClass;

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppPalette.surfaceElevated
                            : AppPalette.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppPalette.primaryGold
                              : AppPalette.borderSubtle,
                          width: isSelected ? 1.0 : 0.8,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () =>
                            setState(() => _selectedClass = characterClass),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppPalette.primaryGold
                                          : const Color(0xFF14161C),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppPalette.borderSubtle,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        characterClass.className.substring(0, 1),
                                        style: GoogleFonts.cinzel(
                                          color: isSelected
                                              ? const Color(0xFF0E1013)
                                              : AppPalette.textBoneWhite,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
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
                                          characterClass.className.toUpperCase(),
                                          style: GoogleFonts.cinzel(
                                            color: isSelected
                                                ? AppPalette.primaryGold
                                                : AppPalette.textBoneWhite,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        Text(
                                          'HP: ${characterClass.baseHp}  •  Stamina: ${characterClass.maxStamina}',
                                          style: GoogleFonts.inter(
                                            color: AppPalette.textAshGray,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppPalette.primaryGold
                                            : AppPalette.textDim,
                                        width: 1.5,
                                      ),
                                      color: isSelected
                                          ? AppPalette.primaryGold
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Color(0xFF0E1013),
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                characterClass.description,
                                style: GoogleFonts.inter(
                                  color: AppPalette.textAshGray,
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _TraitChip(
                                    label:
                                        'Hasar: ${(characterClass.damageMultiplier * 100).round()}%',
                                    isBuff:
                                        characterClass.damageMultiplier <= 1.0,
                                  ),
                                  _TraitChip(
                                    label:
                                        'Öz Kazancı: ${(characterClass.essenceMultiplier * 100).round()}%',
                                    isBuff:
                                        characterClass.essenceMultiplier >= 1.0,
                                  ),
                                ],
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
                    foregroundColor: AppPalette.primaryGold,
                    side: const BorderSide(
                        color: AppPalette.primaryGold, width: 0.9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'YOLCULUĞA BAŞLA',
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip({
    required this.label,
    required this.isBuff,
  });

  final String label;
  final bool isBuff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF14161C),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isBuff
              ? AppPalette.primaryGold.withValues(alpha: 0.3)
              : AppPalette.bloodCrimson.withValues(alpha: 0.3),
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isBuff ? AppPalette.primaryGold : AppPalette.bloodBright,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
