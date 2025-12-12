import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/news_provider.dart';
import '../../data/models/news.dart';
import 'create_news_screen.dart';

class JournalistNewsScreen extends ConsumerStatefulWidget {
  const JournalistNewsScreen({super.key});

  @override
  ConsumerState<JournalistNewsScreen> createState() =>
      _JournalistNewsScreenState();
}

class _JournalistNewsScreenState extends ConsumerState<JournalistNewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStatus;
  Map<String, dynamic>? _currentParams;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateParams();
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    
    switch (_tabController.index) {
      case 0:
        _selectedStatus = null; // Tất cả
        break;
      case 1:
        _selectedStatus = 'published';
        break;
      case 2:
        _selectedStatus = 'draft';
        break;
    }
    _updateParams();
    setState(() {});
  }

  void _updateParams() {
    _currentParams = {'status': _selectedStatus};
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(
      myArticlesProvider(_currentParams),
    );
    final statsAsync = ref.watch(journalistStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tin tức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Fetch tin tự động',
            onPressed: _showFetchNewsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Thống kê',
            onPressed: () => _showStatisticsDialog(statsAsync),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đã xuất bản'),
            Tab(text: 'Bản nháp'),
          ],
        ),
      ),
      body: articlesAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myArticlesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) =>
                  _buildArticleItem(articles[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(myArticlesProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateNews,
        icon: const Icon(Icons.add),
        label: const Text('Tạo bài viết'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có bài viết nào',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để tạo bài viết mới',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(News article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEditNews(article),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: article.image != null && !article.image!.contains('default')
                    ? Image.network(
                        article.image!,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.article),
                      ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildCategoryChip(article.category),
                        const SizedBox(width: 8),
                        if (article.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '⭐ Nổi bật',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.visibility,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${article.views}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          article.isPublished
                              ? (article.publishedAt != null
                                  ? DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(article.publishedAt!),
                                    )
                                  : 'Đã xuất bản')
                              : 'Bản nháp',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleArticleAction(value, article),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_publish',
                    child: Row(
                      children: [
                        Icon(
                          article.isPublished
                              ? Icons.unpublished
                              : Icons.publish,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          article.isPublished
                              ? 'Gỡ xuống'
                              : 'Xuất bản',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final categoryLabels = {
      'hot_news': 'Tin nóng',
      'highlight': 'Tường thuật',
      'transfer': 'Chuyển nhượng',
      'interview': 'Phỏng vấn',
      'team_news': 'Tin đội bóng',
    };

    final categoryColors = {
      'hot_news': Colors.red,
      'highlight': Colors.blue,
      'transfer': Colors.green,
      'interview': Colors.purple,
      'team_news': Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (categoryColors[category] ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: (categoryColors[category] ?? Colors.grey).withOpacity(0.3),
        ),
      ),
      child: Text(
        categoryLabels[category] ?? category,
        style: TextStyle(
          fontSize: 10,
          color: categoryColors[category] ?? Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToCreateNews() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateNewsScreen(),
      ),
    );
    if (result == true) {
      ref.invalidate(myArticlesProvider);
    }
  }

  void _navigateToEditNews(News article) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewsScreen(editNews: article),
      ),
    );
    if (result == true) {
      ref.invalidate(myArticlesProvider);
    }
  }

  void _handleArticleAction(String action, News article) async {
    switch (action) {
      case 'edit':
        _navigateToEditNews(article);
        break;
      case 'toggle_publish':
        await _togglePublish(article);
        break;
      case 'delete':
        await _confirmDelete(article);
        break;
    }
  }

  Future<void> _togglePublish(News article) async {
    try {
      await ref.read(newsApiProvider).togglePublishArticle(article.id);
      ref.invalidate(myArticlesProvider);
      _showSnackBar(
        article.isPublished
            ? 'Đã gỡ bài viết xuống'
            : 'Đã xuất bản bài viết',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('Lỗi: $e', Colors.red);
    }
  }

  Future<void> _confirmDelete(News article) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa bài viết "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(newsApiProvider).deleteArticle(article.id);
        ref.invalidate(myArticlesProvider);
        _showSnackBar('Đã xóa bài viết', Colors.green);
      } catch (e) {
        _showSnackBar('Lỗi: $e', Colors.red);
      }
    }
  }

  void _showFetchNewsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fetch tin tức tự động'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hệ thống sẽ tự động lấy tin tức thể thao mới nhất từ các nguồn chính thống.',
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Tất cả nguồn'),
              onTap: () {
                Navigator.pop(context);
                _fetchNews(null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('VnExpress'),
              onTap: () {
                Navigator.pop(context);
                _fetchNews('vnexpress');
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Thanh Niên'),
              onTap: () {
                Navigator.pop(context);
                _fetchNews('thanhnien');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchNews(String? source) async {
    _showSnackBar('Đang fetch tin tức...', Colors.blue);
    try {
      final result = await ref.read(newsApiProvider).fetchAutoNews(source: source);
      ref.invalidate(myArticlesProvider);
      ref.invalidate(newsProvider);
      _showSnackBar(result['message'] ?? 'Fetch thành công!', Colors.green);
    } catch (e) {
      _showSnackBar('Lỗi: $e', Colors.red);
    }
  }

  void _showStatisticsDialog(AsyncValue<Map<String, dynamic>> statsAsync) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê'),
        content: statsAsync.when(
          data: (stats) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Tổng bài viết', '${stats['total_articles'] ?? 0}'),
              _buildStatRow('Đã xuất bản', '${stats['published_articles'] ?? 0}'),
              _buildStatRow('Bản nháp', '${stats['draft_articles'] ?? 0}'),
              _buildStatRow('Nổi bật', '${stats['featured_articles'] ?? 0}'),
              _buildStatRow('Tổng lượt xem', '${stats['total_views'] ?? 0}'),
              _buildStatRow('Hôm nay', '${stats['articles_today'] ?? 0}'),
              _buildStatRow('Tuần này', '${stats['articles_this_week'] ?? 0}'),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Lỗi: $e'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
