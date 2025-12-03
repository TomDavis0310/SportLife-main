import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/highlight_provider.dart';
import '../../../highlights/data/models/match_highlight.dart';

class MatchHighlightsTab extends ConsumerWidget {
  final int matchId;

  const MatchHighlightsTab({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightsAsync = ref.watch(matchHighlightsProvider(matchId));

    return highlightsAsync.when(
      data: (highlights) {
        if (highlights.isEmpty) {
          return const Center(
            child: Text('Chưa có video highlight cho trận đấu này.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: highlights.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final highlight = highlights[index];
            return _MatchHighlightTile(
              highlight: highlight,
              onTap: () => _openHighlight(context, highlight.videoUrl),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Không tải được highlights: $error'),
        ),
      ),
    );
  }

  Future<void> _openHighlight(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showError(context, 'Liên kết video không hợp lệ');
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) return;
    if (!launched) {
      _showError(context, 'Không thể mở video highlight');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _MatchHighlightTile extends StatelessWidget {
  final MatchHighlight highlight;
  final VoidCallback onTap;

  const _MatchHighlightTile({required this.highlight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final infoLabel = _buildInfoLabel();
    final duration = _formatDuration(highlight.durationSeconds);
    final contextLabel =
        highlight.match?.competitionName ?? highlight.provider;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: highlight.thumbnailUrl ?? '',
                    width: 140,
                    height: 100,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 140,
                      height: 100,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.play_circle_outline, size: 32),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      highlight.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (contextLabel != null)
                      Text(
                        contextLabel,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      infoLabel,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 18, color: Colors.redAccent),
                        SizedBox(width: 4),
                        Text(
                          'Xem nhanh',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildInfoLabel() {
    final publishedAt = highlight.publishedAt;
    final timeText = publishedAt != null
        ? DateFormat('HH:mm dd/MM').format(DateTime.parse(publishedAt).toLocal())
        : null;
    final views = highlight.viewCount;
    if (timeText != null && views != null) {
      return '$timeText • ${_formatViews(views)} lượt xem';
    }
    if (timeText != null) return timeText;
    if (views != null) return '${_formatViews(views)} lượt xem';
    return 'Video highlight trận đấu';
  }

  String _formatDuration(int? seconds) {
    final total = seconds ?? 120;
    final minutes = total ~/ 60;
    final remain = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }
}
