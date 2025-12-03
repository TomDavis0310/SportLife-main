import 'package:dio/dio.dart';
import '../models/news.dart';

class NewsApi {
  final Dio dio;

  NewsApi(this.dio);

  Future<List<News>> getNews({
    String? category,
    int? teamId,
    bool? featured,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/news',
      queryParameters: {
        if (category != null) 'category': category,
        if (teamId != null) 'team_id': teamId,
        if (featured != null) 'featured': featured,
        'page': page,
      },
    );
    final List data = response.data['data'];
    return data.map((e) => News.fromJson(e)).toList();
  }

  Future<News> getNewsDetail(int id) async {
    final response = await dio.get('/news/$id');
    return News.fromJson(response.data['data']);
  }

  Future<void> likeNews(int newsId) async {
    await dio.post('/news/$newsId/like');
  }

  Future<void> unlikeNews(int newsId) async {
    await dio.delete('/news/$newsId/like');
  }

  Future<List<dynamic>> getComments(int newsId, {int page = 1}) async {
    final response = await dio.get(
      '/news/$newsId/comments',
      queryParameters: {'page': page},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> addComment(int newsId, String content) async {
    final response = await dio.post(
      '/news/$newsId/comments',
      data: {'content': content},
    );
    return response.data['data'];
  }
}

