import '../entities/ash_mark.dart';
import '../entities/character.dart';
import '../entities/quest_day.dart';
import '../entities/task.dart';

class SettleDayResult {
  final bool died;
  final int finalHp;
  final int essenceGained;
  final AshMark? ashMark;

  SettleDayResult({
    required this.died,
    required this.finalHp,
    required this.essenceGained,
    this.ashMark,
  });
}

class SettleDay {
  final Character character;
  final QuestDay questDay;

  SettleDay({required this.character, required this.questDay});

  SettleDayResult call() {
    var hp = character.currentHp;
    var essenceGained = 0;
    bool died = false;
    AshMark? ashMark;

    for (final task in questDay.tasks) {
      if (task.isCompleted) {
        essenceGained += task.essenceReward;
        continue;
      }

      if (task.isBoss) {
        task.miss();
        died = true;
        ashMark = AshMark(
          id: 'ash_${questDay.date.toIso8601String()}',
          diedAt: DateTime.now(),
          buriedEssence: character.essence + essenceGained,
          streakAtDeath: character.streak,
          cause: 'boss_missed',
        );
        break;
      }

      hp -= task.hpPenalty;
      task.miss();
      if (hp <= 0) {
        died = true;
        ashMark = AshMark(
          id: 'ash_${questDay.date.toIso8601String()}',
          diedAt: DateTime.now(),
          buriedEssence: character.essence + essenceGained,
          streakAtDeath: character.streak,
          cause: 'task_missed',
        );
        break;
      }
    }

    if (!died) {
      character.gainEssence(essenceGained);
      if (essenceGained > 0) {
        character.streak += 1;
        if (character.streak > character.bestStreak) {
          character.bestStreak = character.streak;
        }
      }
    } else {
      character.currentHp = 0;
      character.streak = 0;
    }

    questDay.isSettled = true;

    return SettleDayResult(
      died: died,
      finalHp: hp <= 0 ? 0 : hp,
      essenceGained: essenceGained,
      ashMark: ashMark,
    );
  }
}
