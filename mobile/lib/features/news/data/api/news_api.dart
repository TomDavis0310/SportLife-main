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

  Future<List<News>> getRelatedNews(int newsId) async {
    final response = await dio.get('/news/$newsId/related');
    final List data = response.data['data'];
    return data.map((e) => News.fromJson(e)).toList();
  }

  // ==================== Journalist APIs ====================

  /// Lấy danh sách bài viết của nhà báo
  Future<List<News>> getMyArticles({
    String? status,
    String? category,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/journalist/articles',
      queryParameters: {
        if (status != null) 'status': status,
        if (category != null) 'category': category,
        'page': page,
      },
    );
    
    // Handle different response structures
    final responseData = response.data;
    List data;
    
    if (responseData is Map) {
      data = responseData['data'] ?? [];
    } else if (responseData is List) {
      data = responseData;
    } else {
      data = [];
    }
    
    return data.map((e) => News.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Tạo bài viết mới
  Future<News> createArticle({
    required String title,
    required String content,
    required String category,
    String? excerpt,
    int? teamId,
    String? videoUrl,
    List<int>? thumbnailBytes,
    String? thumbnailName,
    bool isPublished = false,
    List<String>? tags,
  }) async {
    // Nếu có thumbnail, dùng FormData
    if (thumbnailBytes != null && thumbnailName != null) {
      final formData = FormData.fromMap({
        'title': title,
        'content': content,
        'category': category,
        if (excerpt != null) 'excerpt': excerpt,
        if (teamId != null) 'team_id': teamId,
        if (videoUrl != null) 'video_url': videoUrl,
        'is_published': isPublished ? '1' : '0', // FormData cần string
        if (tags != null) 'tags': tags,
        'thumbnail': MultipartFile.fromBytes(
          thumbnailBytes,
          filename: thumbnailName,
        ),
      });
      final response = await dio.post(
        '/journalist/articles',
        data: formData,
      );
      return News.fromJson(response.data['data']);
    }

    // Không có thumbnail, gửi JSON
    final response = await dio.post(
      '/journalist/articles',
      data: {
        'title': title,
        'content': content,
        'category': category,
        if (excerpt != null) 'excerpt': excerpt,
        if (teamId != null) 'team_id': teamId,
        if (videoUrl != null) 'video_url': videoUrl,
        'is_published': isPublished,
        if (tags != null) 'tags': tags,
      },
    );
    return News.fromJson(response.data['data']);
  }

  /// Cập nhật bài viết
  Future<News> updateArticle({
    required int id,
    String? title,
    String? content,
    String? category,
    String? excerpt,
    int? teamId,
    String? videoUrl,
    List<int>? thumbnailBytes,
    String? thumbnailName,
    bool? isPublished,
    List<String>? tags,
  }) async {
    // Nếu có thumbnail mới, dùng FormData với POST endpoint riêng
    if (thumbnailBytes != null && thumbnailName != null) {
      final formData = FormData.fromMap({
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (category != null) 'category': category,
        if (excerpt != null) 'excerpt': excerpt,
        if (teamId != null) 'team_id': teamId,
        if (videoUrl != null) 'video_url': videoUrl,
        if (isPublished != null) 'is_published': isPublished ? '1' : '0',
        if (tags != null) 'tags': tags,
        'thumbnail': MultipartFile.fromBytes(
          thumbnailBytes,
          filename: thumbnailName,
        ),
      });
      // Dùng route POST riêng cho update với file
      final response = await dio.post('/journalist/articles/$id/update', data: formData);
      return News.fromJson(response.data['data']);
    }

    // Không có thumbnail mới, gửi JSON với PUT
    final response = await dio.put(
      '/journalist/articles/$id',
      data: {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (category != null) 'category': category,
        if (excerpt != null) 'excerpt': excerpt,
        if (teamId != null) 'team_id': teamId,
        if (videoUrl != null) 'video_url': videoUrl,
        if (isPublished != null) 'is_published': isPublished,
        if (tags != null) 'tags': tags,
      },
    );
    return News.fromJson(response.data['data']);
  }

  /// Xóa bài viết
  Future<void> deleteArticle(int id) async {
    await dio.delete('/journalist/articles/$id');
  }

  /// Toggle xuất bản bài viết
  Future<News> togglePublishArticle(int id) async {
    final response = await dio.post('/journalist/articles/$id/toggle-publish');
    return News.fromJson(response.data['data']);
  }

  /// Lấy thống kê của nhà báo
  Future<Map<String, dynamic>> getJournalistStatistics() async {
    final response = await dio.get('/journalist/statistics');
    return response.data['data'];
  }

  /// Lấy danh sách nguồn tin
  Future<List<Map<String, dynamic>>> getNewsSources() async {
    final response = await dio.get('/journalist/sources');
    final List data = response.data['data'];
    return data.cast<Map<String, dynamic>>();
  }

  /// Fetch tin tức tự động
  Future<Map<String, dynamic>> fetchAutoNews({String? source}) async {
    final response = await dio.post(
      '/journalist/fetch-news',
      data: {if (source != null) 'source': source},
    );
    return response.data;
  }
}

