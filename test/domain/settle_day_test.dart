import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/domain/entities/character_class.dart';
import 'package:bonfire/domain/entities/character.dart';
import 'package:bonfire/domain/entities/task.dart';
import 'package:bonfire/domain/entities/quest_day.dart';
import 'package:bonfire/domain/usecases/settle_day.dart';

void main() {
  test('SettleDay awards essence for completed tasks and preserves HP when no misses', () {
    final char = Character(id: '1', name: 'Player', characterClass: CharacterClass.wizard);
    final task = Task(
      id: 'task1',
      title: 'Complete quest',
      scheduledDate: DateTime.now(),
      essenceReward: char.characterClass.essencePerTask,
      hpPenalty: char.characterClass.hpPenaltyPerMiss,
    );
    task.complete();

    final questDay = QuestDay(date: DateTime.now(), tasks: [task]);
    final result = SettleDay(character: char, questDay: questDay)();

    expect(result.died, isFalse);
    expect(result.essenceGained, task.essenceReward);
    expect(char.essence, task.essenceReward);
    expect(char.streak, 1);
    expect(char.currentHp, char.characterClass.maxHp);
  });

  test('SettleDay kills the character on missed boss and creates AshMark', () {
    final char = Character(id: '1', name: 'Player', characterClass: CharacterClass.warrior);
    final bossTask = Task(
      id: 'boss1',
      title: 'Boss task',
      scheduledDate: DateTime.now(),
      essenceReward: char.characterClass.essencePerTask,
      hpPenalty: char.characterClass.hpPenaltyPerMiss,
      isBoss: true,
    );

    final questDay = QuestDay(date: DateTime.now(), tasks: [bossTask]);
    final result = SettleDay(character: char, questDay: questDay)();

    expect(result.died, isTrue);
    expect(result.ashMark, isNotNull);
    expect(char.currentHp, 0);
    expect(char.streak, 0);
  });
}
