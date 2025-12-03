import 'package:dio/dio.dart';
import '../models/reward.dart';
import '../models/redemption.dart';

class RewardApi {
  final Dio dio;

  RewardApi(this.dio);

  Future<List<Reward>> getRewards({String? type, int page = 1}) async {
    final response = await dio.get(
      '/rewards',
      queryParameters: {if (type != null) 'type': type, 'page': page},
    );
    final List data = response.data['data'];
    return data.map((e) => Reward.fromJson(e)).toList();
  }

  Future<Reward> getRewardDetail(int id) async {
    final response = await dio.get('/rewards/$id');
    return Reward.fromJson(response.data['data']);
  }

  Future<Redemption> redeemReward({
    required int rewardId,
    String? shippingAddress,
  }) async {
    final response = await dio.post(
      '/rewards/$rewardId/redeem',
      data: {if (shippingAddress != null) 'shipping_address': shippingAddress},
    );
    final data = response.data['data'];
    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return Redemption.fromJson(Map<String, dynamic>.from(data['data']));
    }
    return Redemption.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<Redemption>> getMyRedemptions({int page = 1}) async {
    final response = await dio.get(
      '/redemptions',
      queryParameters: {'page': page},
    );
    final payload = response.data['data'];
    final List listData;

    if (payload is Map<String, dynamic> && payload['data'] is List) {
      listData = List.castFrom(payload['data']);
    } else if (payload is List) {
      listData = List.castFrom(payload);
    } else {
      listData = const [];
    }

    return listData
        .map((e) => Redemption.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

