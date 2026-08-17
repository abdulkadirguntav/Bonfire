import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonfire/core/localization/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

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
                child: BonfireLogo(
                  size: 72,
                  fontSize: 22,
                  vertical: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.choosePath,
                style: GoogleFonts.cinzel(
                  color: AppPalette.textBoneWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.choosePathSubtitle,
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
                                      child: Icon(
                                        _getClassIcon(characterClass),
                                        color: isSelected
                                            ? const Color(0xFF0E1013)
                                            : AppPalette.primaryGold,
                                        size: 18,
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
                                          l10n.className(characterClass.name),
                                          style: GoogleFonts.cinzel(
                                            color: AppPalette.textBoneWhite,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getClassDifficulty(
                                              characterClass, l10n),
                                          style: GoogleFonts.inter(
                                            color: isSelected
                                                ? AppPalette.primaryGold
                                                : AppPalette.textAshGray,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected
                                        ? AppPalette.primaryGold
                                        : AppPalette.textDim,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getClassDescription(characterClass, l10n),
                                style: GoogleFonts.inter(
                                  color: AppPalette.textDim,
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _TraitChip(
                                    label:
                                        '${l10n.health}: ${characterClass.baseHp}',
                                    isBuff: characterClass.baseHp >= 100,
                                  ),
                                  _TraitChip(
                                    label:
                                        '${l10n.stamina}: ${characterClass.maxStamina}',
                                    isBuff: characterClass.maxStamina >= 100,
                                  ),
                                  _TraitChip(
                                    label: l10n.isTurkish
                                        ? 'Hasar: ${(characterClass.damageMultiplier * 100).round()}%'
                                        : 'Damage Taken: ${(characterClass.damageMultiplier * 100).round()}%',
                                    isBuff:
                                        characterClass.damageMultiplier <= 1.0,
                                  ),
                                  _TraitChip(
                                    label: l10n.isTurkish
                                        ? 'Öz Kazancı: ${(characterClass.essenceMultiplier * 100).round()}%'
                                        : 'Essence: ${(characterClass.essenceMultiplier * 100).round()}%',
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
                    l10n.beginJourney,
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

  IconData _getClassIcon(CharacterClass characterClass) {
    switch (characterClass) {
      case CharacterClass.mage:
        return Icons.auto_awesome_rounded;
      case CharacterClass.warrior:
        return Icons.shield_rounded;
      case CharacterClass.prisoner:
        return Icons.lock_open_rounded;
    }
  }

  String _getClassDifficulty(
      CharacterClass characterClass, AppLocalizations l10n) {
    if (l10n.isTurkish) {
      switch (characterClass) {
        case CharacterClass.mage:
          return 'Başlangıç Seviyesi (Yüksek Can, Düşük Ceza)';
        case CharacterClass.warrior:
          return 'Dengeli Seviye (Standart İrade)';
        case CharacterClass.prisoner:
          return 'Zor Seviye (Yüksek Risk / Yüksek Ödül)';
      }
    }
    switch (characterClass) {
      case CharacterClass.mage:
        return 'Beginner Path (High HP, Low Penalty)';
      case CharacterClass.warrior:
        return 'Balanced Path (Standard Will)';
      case CharacterClass.prisoner:
        return 'Hard Path (High Risk / High Reward)';
    }
  }

  String _getClassDescription(
      CharacterClass characterClass, AppLocalizations l10n) {
    if (l10n.isTurkish) {
      switch (characterClass) {
        case CharacterClass.mage:
          return 'Alışkanlık bilinci yeni gelişen kullanıcılar için uygundur. Yüksek can havuzu ve az hasar alma avantajı sunar.';
        case CharacterClass.warrior:
          return 'Disiplin ve dayanıklılığı eşit dengede tutmak isteyen kullanıcılar için idealdir.';
        case CharacterClass.prisoner:
          return 'Sadece cesareti olanlar için. Düşük can ile başlar, kaçırılan görevlerde ağır ceza alır ancak %50 daha fazla Öz kazanır.';
      }
    }
    switch (characterClass) {
      case CharacterClass.mage:
        return 'Ideal for novices. Features high survivability with 150 HP and reduced penalty damage.';
      case CharacterClass.warrior:
        return 'Balanced for seekers of discipline. 100 HP and 100 Stamina for steady progress.';
      case CharacterClass.prisoner:
        return 'Only for the brave. 50 HP with heavy damage penalties, but yields 50% more Essence.';
    }
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
