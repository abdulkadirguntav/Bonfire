import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bonfire/data/repositories/user_repository.dart';
import 'package:bonfire/domain/models/character_class.dart';
import 'package:bonfire/domain/models/shop_item.dart';
import 'package:bonfire/domain/models/user.dart';
import 'package:bonfire/domain/services/death_service.dart';
import 'package:bonfire/domain/services/shop_service.dart';
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

  Future<void> selectClass(CharacterClass characterClass) async {
    final now = DateTime.now();
    final user = User.create(
      id: 'user_${now.millisecondsSinceEpoch}',
      selectedClass: characterClass,
      now: now,
    );
    await saveUser(user);
  }

  Future<void> saveUser(User user) async {
    await _repository.saveUser(user);
    state = user;
  }

  // Phase 3 Shop & Item Actions
  Future<void> buyItem(ItemType item, {int quantity = 1}) async {
    final user = state;
    if (user == null) return;
    final updated = ShopService.buyItem(user, item, quantity: quantity);
    await saveUser(updated);
  }

  Future<void> useItem(ItemType item, {DateTime? now}) async {
    final user = state;
    if (user == null) return;
    final updated = ShopService.useItem(user, item, now: now);
    await saveUser(updated);
  }

  // Phase 3 Bonfire Milestone Kindling (Streaks 3, 7, 14, 30)
  Future<void> kindleMilestone({required bool upgradeHp}) async {
    final user = state;
    if (user == null) return;

    final streak = user.currentStreak;
    final updatedMilestones = Set<int>.from(user.claimedMilestones)..add(streak);

    if (upgradeHp) {
      final newMaxHp = user.maxHp + 20;
      final updated = user.copyWith(
        maxHp: newMaxHp,
        currentHp: newMaxHp,
        claimedMilestones: updatedMilestones,
      );
      await saveUser(updated);
    } else {
      final newMaxStam = user.maxStamina + 15;
      final updated = user.copyWith(
        maxStamina: newMaxStam,
        currentStamina: newMaxStam,
        currentHp: user.maxHp, // Also restores HP to full at bonfire
        claimedMilestones: updatedMilestones,
      );
      await saveUser(updated);
    }
  }

  /// Replaces an earlier Ash Mark when the player dies without Ring of Sacrifice.
  Future<void> resolveDeathIfNeeded({DateTime? now}) async {
    final user = state;
    if (user == null || !DeathService.shouldDie(user)) return;

    final diedAt = now ?? DateTime.now();
    final ashMark = DeathService.createAshMark(user, createdAt: diedAt);

    if (ashMark != null) {
      await ref.read(ashMarkControllerProvider.notifier).setAshMark(ashMark);
    }

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
