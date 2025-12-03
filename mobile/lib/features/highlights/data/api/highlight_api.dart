import 'package:dio/dio.dart';

import '../models/match_highlight.dart';

class HighlightApi {
  final Dio dio;

  HighlightApi(this.dio);

  Future<List<MatchHighlight>> getHighlights({
    int? matchId,
    bool featured = false,
    int? competitionId,
    int limit = 10,
  }) async {
    final response = await dio.get(
      '/highlights',
      queryParameters: {
        if (matchId != null) 'match_id': matchId,
        if (competitionId != null) 'competition_id': competitionId,
        if (featured) 'featured': 1,
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data.map((e) => MatchHighlight.fromJson(e)).toList();
  }

  Future<List<MatchHighlight>> getMatchHighlights(int matchId, {int limit = 10}) async {
    final response = await dio.get(
      '/matches/$matchId/highlights',
      queryParameters: {
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data.map((e) => MatchHighlight.fromJson(e)).toList();
  }
}
