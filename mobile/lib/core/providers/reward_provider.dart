import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/rewards/data/models/reward.dart';
import '../../features/rewards/data/models/redemption.dart';
import '../../features/rewards/data/api/reward_api.dart';
import '../network/dio_client.dart';

// Reward API Provider
final rewardApiProvider = Provider<RewardApi>((ref) {
  return RewardApi(ref.watch(dioProvider));
});

// Rewards List Provider
final rewardsListProvider =
    FutureProvider.family<List<Reward>, Map<String, dynamic>>((
  ref,
  params,
) async {
  return ref
      .watch(rewardApiProvider)
      .getRewards(type: params['type'], page: params['page'] ?? 1);
});

// Reward Detail Provider
final rewardDetailProvider = FutureProvider.family<Reward, int>((
  ref,
  rewardId,
) async {
  return ref.watch(rewardApiProvider).getRewardDetail(rewardId);
});

// My Redemptions Provider
final myRedemptionsProvider = FutureProvider<List<Redemption>>((ref) async {
  return ref.watch(rewardApiProvider).getMyRedemptions();
});

// User Rewards Provider (alias for my redemptions)
final userRewardsProvider = FutureProvider<List<Redemption>>((ref) async {
  return ref.watch(rewardApiProvider).getMyRedemptions();
});

// Selected Reward Type Provider
final selectedRewardTypeProvider = StateProvider<String?>((ref) => null);

// Simple Rewards Provider (all rewards)
final rewardsProvider = FutureProvider<List<Reward>>((ref) async {
  return ref.watch(rewardApiProvider).getRewards();
});

// User Points Provider
final userPointsProvider = Provider<int>((ref) {
  // Get from auth state
  return 0; // This will be updated when user is logged in
});

// Redemption History Provider
final redemptionHistoryProvider = FutureProvider<List<Redemption>>((ref) async {
  return ref.watch(rewardApiProvider).getMyRedemptions();
});

