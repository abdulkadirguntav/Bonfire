import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/user_repository.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/presentation/providers/ash_mark_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('A repository instance must be provided');
});

final userControllerProvider = NotifierProvider<UserController, User?>(UserController.new);

class UserController extends Notifier<User?> {
  UserRepository get _repository => ref.read(userRepositoryProvider);

  @override
  User? build() {
    _loadUser();
    return null;
  }

  Future<void> _loadUser() async {
    final user = await _repository.loadUser();
    state = user;
  }

  Future<void> selectClass(CharacterClass characterClass) async {
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      selectedClass: characterClass,
      currentHp: characterClass.baseHp,
      maxHp: characterClass.baseHp,
      totalEssence: 0,
      currentStreak: 0,
      hasDefeatedFirstBoss: false,
    );

    await _repository.saveUser(user);
    state = user;
  }

  Future<void> markFirstBossDefeated() async {
    final user = state;
    if (user == null) return;

    final updated = user.copyWith(hasDefeatedFirstBoss: true);
    await _repository.saveUser(updated);
    state = updated;
  }

  Future<void> saveUser(User user) async {
    await _repository.saveUser(user);
    state = user;
  }

  Future<void> triggerDeath() async {
    final user = state;
    if (user == null || !DeathService.shouldDie(user)) {
      return;
    }

    final ashMark = DeathService.createAshMark(user);
    final revived = DeathService.applyDeath(user);

    await _repository.saveUser(revived);
    state = revived;

    await ref.read(ashMarkControllerProvider.notifier).setAshMark(ashMark);
  }

  Future<void> reclaimAshMark() async {
    final user = state;
    final ashMark = ref.read(ashMarkControllerProvider);
    if (user == null || ashMark == null) {
      return;
    }

    if (!DeathService.canReclaim(user, ashMark)) {
      return;
    }

    final reclaimed = DeathService.reclaim(user, ashMark);
    await _repository.saveUser(reclaimed);
    state = reclaimed;
    await ref.read(ashMarkControllerProvider.notifier).clearAshMark();
  }

  Future<void> clearUser() async {
    await _repository.clearUser();
    state = null;
  }
}
