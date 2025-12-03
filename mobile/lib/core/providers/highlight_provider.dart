import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import '../../features/highlights/data/api/highlight_api.dart';
import '../../features/highlights/data/models/match_highlight.dart';

final highlightApiProvider = Provider<HighlightApi>((ref) {
  return HighlightApi(ref.watch(dioProvider));
});

final featuredHighlightsProvider = FutureProvider.autoDispose<List<MatchHighlight>>((ref) async {
  return ref.watch(highlightApiProvider).getHighlights(featured: true, limit: 8);
});

final latestHighlightsProvider = FutureProvider.autoDispose<List<MatchHighlight>>((ref) async {
  return ref.watch(highlightApiProvider).getHighlights(limit: 12);
});

final matchHighlightsProvider = FutureProvider.autoDispose.family<List<MatchHighlight>, int>((ref, matchId) async {
  return ref.watch(highlightApiProvider).getMatchHighlights(matchId);
});
