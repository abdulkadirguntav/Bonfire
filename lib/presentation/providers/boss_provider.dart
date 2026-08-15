import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/domain/models/boss.dart';
import 'package:bonfire/domain/models/user.dart';

final bossControllerProvider =
    NotifierProvider<BossController, Boss?>(BossController.new);

class BossController extends Notifier<Boss?> {
  @override
  Boss? build() {
    return null;
  }

  void createBoss(String title) {
    state = Boss(
      id: 'boss_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      currentHp: 30,
      maxHp: 30,
      phase: 1,
    );
  }

  void applyResisted() {
    final boss = state;
    if (boss == null) return;
    final newHp = (boss.currentHp - 1).clamp(0, boss.maxHp);
    final updatedBoss = boss.copyWith(currentHp: newHp);
    if (newHp == 0) {
      // Phase mutation: massive essence reward handled in UI/controller interaction
      state = updatedBoss.copyWith(
        phase: boss.phase + 1,
        maxHp: 90,
        currentHp: 90,
      );
    } else {
      state = updatedBoss;
    }
  }

  void applyFailed(User user) {
    final boss = state;
    if (boss == null) return;
    final healedHp = (boss.currentHp + 1).clamp(0, boss.maxHp);
    state = boss.copyWith(currentHp: healedHp);
  }
}
