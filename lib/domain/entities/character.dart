import 'character_class.dart';

class Character {
  final String id;
  final String name;
  final CharacterClass characterClass;
  int currentHp;
  int streak;
  int bestStreak;
  int essence;

  Character({
    required this.id,
    required this.name,
    required this.characterClass,
    int? currentHp,
    int? streak,
    int? bestStreak,
    int? essence,
  })  : currentHp = currentHp ?? characterClass.maxHp,
        streak = streak ?? 0,
        bestStreak = bestStreak ?? 0,
        essence = essence ?? 0;

  bool get isDead => currentHp <= 0;

  void takeDamage(int amount) {
    currentHp -= amount;
    if (currentHp < 0) currentHp = 0;
  }

  void heal(int amount) {
    currentHp += amount;
    if (currentHp > characterClass.maxHp) {
      currentHp = characterClass.maxHp;
    }
  }

  void gainEssence(int amount) {
    essence += amount;
  }

  void resetForNewDay() {
    // no-op for now; placeholder for refreshDay logic
  }
}
