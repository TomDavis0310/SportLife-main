import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/providers/news_provider.dart';
import '../../data/models/news.dart';

class CreateNewsScreen extends ConsumerStatefulWidget {
  final News? editNews; // Nếu có thì là edit mode

  const CreateNewsScreen({super.key, this.editNews});

  @override
  ConsumerState<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends ConsumerState<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _excerptController = TextEditingController();
  final _videoUrlController = TextEditingController();

  String _selectedCategory = 'hot_news';
  bool _isPublished = false;
  bool _isLoading = false;
  
  // Dùng XFile và bytes thay vì File để hỗ trợ web
  XFile? _thumbnailXFile;
  Uint8List? _thumbnailBytes;
  
  List<String> _tags = [];
  final _tagController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'key': 'hot_news', 'label': 'Tin nóng'},
    {'key': 'highlight', 'label': 'Tường thuật'},
    {'key': 'transfer', 'label': 'Chuyển nhượng'},
    {'key': 'interview', 'label': 'Phỏng vấn'},
    {'key': 'team_news', 'label': 'Tin đội bóng'},
  ];

  bool get isEditMode => widget.editNews != null;
  
  // Lưu URL ảnh cũ khi edit
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _titleController.text = widget.editNews!.title;
      _contentController.text = widget.editNews!.content ?? '';
      _excerptController.text = widget.editNews!.excerpt ?? '';
      _videoUrlController.text = widget.editNews!.videoUrl ?? '';
      _selectedCategory = widget.editNews!.category;
      _isPublished = widget.editNews!.isPublished;
      _tags = List<String>.from(widget.editNews!.tags ?? []);
      _existingImageUrl = widget.editNews!.image;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _excerptController.dispose();
    _videoUrlController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // Đọc bytes để hỗ trợ cả web và mobile
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _thumbnailXFile = pickedFile;
        _thumbnailBytes = bytes;
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newsApi = ref.read(newsApiProvider);

      if (isEditMode) {
        await newsApi.updateArticle(
          id: widget.editNews!.id,
          title: _titleController.text,
          content: _contentController.text,
          category: _selectedCategory,
          excerpt: _excerptController.text.isNotEmpty ? _excerptController.text : null,
          videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
          thumbnailBytes: _thumbnailBytes?.toList(),
          thumbnailName: _thumbnailXFile?.name,
          isPublished: _isPublished,
          tags: _tags.isNotEmpty ? _tags : null,
        );
        _showSnackBar('Cập nhật bài viết thành công!', Colors.green);
      } else {
        await newsApi.createArticle(
          title: _titleController.text,
          content: _contentController.text,
          category: _selectedCategory,
          excerpt: _excerptController.text.isNotEmpty ? _excerptController.text : null,
          videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
          thumbnailBytes: _thumbnailBytes?.toList(),
          thumbnailName: _thumbnailXFile?.name,
          isPublished: _isPublished,
          tags: _tags.isNotEmpty ? _tags : null,
        );
        _showSnackBar('Tạo bài viết thành công!', Colors.green);
      }

      // Refresh danh sách và quay lại
      ref.invalidate(journalistArticlesProvider);
      ref.invalidate(newsProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Lỗi: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa bài viết' : 'Tạo bài viết mới'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveArticle,
              icon: const Icon(Icons.save),
              label: const Text('Lưu'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thumbnail
            _buildThumbnailSection(),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                hintText: 'Nhập tiêu đề bài viết',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
              maxLength: 255,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat['key'],
                  child: Text(cat['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),

            // Excerpt
            TextFormField(
              controller: _excerptController,
              decoration: const InputDecoration(
                labelText: 'Tóm tắt',
                hintText: 'Mô tả ngắn về bài viết',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.short_text),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung *',
                hintText: 'Nhập nội dung bài viết',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập nội dung';
                }
                return null;
              },
              maxLines: 10,
            ),
            const SizedBox(height: 16),

            // Video URL
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Video URL',
                hintText: 'Nhập link video (YouTube, v.v.)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.video_library),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Tags
            _buildTagsSection(),
            const SizedBox(height: 16),

            // Publish toggle
            SwitchListTile(
              title: const Text('Xuất bản ngay'),
              subtitle: Text(
                _isPublished
                    ? 'Bài viết sẽ được công khai'
                    : 'Lưu làm bản nháp',
              ),
              value: _isPublished,
              onChanged: (value) {
                setState(() => _isPublished = value);
              },
              secondary: Icon(
                _isPublished ? Icons.public : Icons.drafts,
                color: _isPublished ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh đại diện',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _thumbnailBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _thumbnailBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : _existingImageUrl != null && !_existingImageUrl!.contains('default')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _existingImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
          ),
        ),
        if (_thumbnailBytes != null || (_existingImageUrl != null && !_existingImageUrl!.contains('default')))
          TextButton.icon(
            onPressed: () {
              setState(() {
                _thumbnailXFile = null;
                _thumbnailBytes = null;
                _existingImageUrl = null;
              });
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Nhấn để chọn ảnh',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tag và nhấn +',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addTag,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
