import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/user_repository.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/domain/services/stamina_service.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

final userControllerProvider =
    NotifierProvider<UserController, User?>(UserController.new);

class UserController extends Notifier<User?> {
  UserRepository get _repository => ref.read(userRepositoryProvider);

  @override
  User? build() {
    _loadUser();
    return null;
  }

  Future<void> _loadUser() async {
    final user = await _repository.loadUser();
    if (user == null) return;

    final refreshed = StaminaService.refreshIfNeeded(user);
    if (refreshed != user) await _repository.saveUser(refreshed);
    state = refreshed;
  }

  Future<void> beginJourney() async {
    final now = DateTime.now();
    await saveUser(User(
      id: 'user_${now.millisecondsSinceEpoch}',
      currentHp: User.defaultMaxHp,
      maxHp: User.defaultMaxHp,
      essence: 0,
      currentStreak: 1,
      currentStamina: User.maxStamina,
      staminaUpdatedAt: now,
    ));
  }

  Future<void> saveUser(User user) async {
    await _repository.saveUser(user);
    state = user;
  }

  /// Replaces an earlier Ash Mark when the player dies before reclaiming it.
  Future<void> resolveDeathIfNeeded({DateTime? now}) async {
    final user = state;
    if (user == null || !DeathService.shouldDie(user)) return;

    final diedAt = now ?? DateTime.now();
    await ref
        .read(ashMarkControllerProvider.notifier)
        .setAshMark(DeathService.createAshMark(user, createdAt: diedAt));
    await saveUser(DeathService.applyDeath(user, now: diedAt));
  }

  Future<void> reclaimAshMarkIfEligible() async {
    final user = state;
    final ashMark = ref.read(ashMarkControllerProvider);
    if (user == null ||
        ashMark == null ||
        !DeathService.canReclaim(user, ashMark)) {
      return;
    }

    await saveUser(DeathService.reclaim(user, ashMark));
    await ref.read(ashMarkControllerProvider.notifier).clearAshMark();
  }

  Future<void> clearUser() async {
    await _repository.clearUser();
    state = null;
  }
}
