import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/news/data/models/news.dart';
import '../../features/news/data/api/news_api.dart';
import '../network/dio_client.dart';

// News API Provider
final newsApiProvider = Provider<NewsApi>((ref) {
  return NewsApi(ref.watch(dioProvider));
});

// News List Provider
final newsListProvider =
    FutureProvider.family<List<News>, Map<String, dynamic>>((
  ref,
  params,
) async {
  return ref.watch(newsApiProvider).getNews(
        category: params['category'],
        teamId: params['team_id'],
        featured: params['featured'],
        page: params['page'] ?? 1,
      );
});

// Featured News Provider
final featuredNewsProvider = FutureProvider<List<News>>((ref) async {
  return ref.watch(newsApiProvider).getNews(featured: true);
});

// News Detail Provider
final newsDetailProvider = FutureProvider.family<News, int>((
  ref,
  newsId,
) async {
  return ref.watch(newsApiProvider).getNewsDetail(newsId);
});

// News Comments Provider
final newsCommentsProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  newsId,
) async {
  return ref.watch(newsApiProvider).getComments(newsId);
});

// Related News Provider
final relatedNewsProvider = FutureProvider.family<List<News>, int>((
  ref,
  newsId,
) async {
  return ref.watch(newsApiProvider).getRelatedNews(newsId);
});

// Selected Category Provider
final selectedNewsCategoryProvider = StateProvider<String?>((ref) => null);

// Simple News Provider (all news)
final newsProvider = FutureProvider<List<News>>((ref) async {
  return ref.watch(newsApiProvider).getNews();
});

// ==================== Journalist Providers ====================

// My Articles Provider (for journalists)
final myArticlesProvider = FutureProvider.family<List<News>, Map<String, dynamic>?>((
  ref,
  params,
) async {
  return ref.watch(newsApiProvider).getMyArticles(
        status: params?['status'],
        category: params?['category'],
        page: params?['page'] ?? 1,
      );
});

// Simple My Articles Provider
final journalistArticlesProvider = FutureProvider<List<News>>((ref) async {
  return ref.watch(newsApiProvider).getMyArticles();
});

// Journalist Statistics Provider
final journalistStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(newsApiProvider).getJournalistStatistics();
});

// News Sources Provider
final newsSourcesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(newsApiProvider).getNewsSources();
});

