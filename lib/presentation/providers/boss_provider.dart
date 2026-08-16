import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/boss_repository.dart';
import 'package:bonfire/domain/models/boss.dart';
import 'package:bonfire/domain/services/boss_service.dart';
import 'package:bonfire/presentation/providers/user_provider.dart';

final bossRepositoryProvider = Provider<BossRepository>((ref) {
  throw UnimplementedError('A boss repository instance must be provided');
});

final bossControllerProvider =
    NotifierProvider<BossController, Boss?>(BossController.new);

class BossController extends Notifier<Boss?> {
  BossRepository get _repository => ref.read(bossRepositoryProvider);

  @override
  Boss? build() {
    _loadBoss();
    return null;
  }

  Future<void> _loadBoss() async {
    state = await _repository.loadBoss();
  }

  Future<void> setBoss(Boss boss) async {
    await _repository.saveBoss(boss);
    state = boss;
  }

  Future<void> createBoss({
    required String title,
    int? initialHp,
  }) async {
    final boss = BossService.createBoss(
      title: title,
      initialHp: initialHp ?? Boss.maxHpForPhase(1),
    );
    await setBoss(boss);
  }

  Future<BossInteractionResult?> resist({DateTime? now}) async {
    final currentBoss = state;
    final user = ref.read(userControllerProvider);
    if (currentBoss == null || user == null) return null;

    try {
      final result = BossService.resist(
        boss: currentBoss,
        user: user,
        now: now,
      );

      await setBoss(result.boss);
      await ref.read(userControllerProvider.notifier).saveUser(result.user);
      return result;
    } on BossAlreadyInteractedException {
      return null;
    }
  }

  Future<BossInteractionResult?> fail({DateTime? now}) async {
    final currentBoss = state;
    final user = ref.read(userControllerProvider);
    if (currentBoss == null || user == null) return null;

    try {
      final result = BossService.fail(
        boss: currentBoss,
        user: user,
        now: now,
      );

      await setBoss(result.boss);
      await ref.read(userControllerProvider.notifier).saveUser(result.user);
      await ref
          .read(userControllerProvider.notifier)
          .resolveDeathIfNeeded(now: now);
      return result;
    } on BossAlreadyInteractedException {
      return null;
    }
  }

  Future<void> abandonBoss() async {
    await _repository.clearBoss();
    state = null;
  }
}
