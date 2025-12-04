import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays either an SVG or bitmap image automatically based on the file
/// extension. Supports both asset and network sources and falls back to a
/// placeholder when loading fails.
class AutoSvgImage extends StatelessWidget {
  const AutoSvgImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.placeholder,
    this.borderRadius,
  });

  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;
  final BorderRadiusGeometry? borderRadius;

  bool get _isSvg => source?.toLowerCase().endsWith('.svg') ?? false;
  bool get _isNetwork => source != null && source!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _buildContent() {
    if (source == null || source!.isEmpty) {
      return placeholder ?? _defaultPlaceholder();
    }

    return _isNetwork ? _buildNetworkImage() : _buildAssetImage();
  }

  Widget _buildNetworkImage() {
    if (_isSvg) {
      return SvgPicture.network(
        source!,
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (_) => placeholder ?? _defaultPlaceholder(),
      );
    }

    return Image.network(
      source!,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (_, __, ___) => placeholder ?? _defaultPlaceholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder ?? _defaultPlaceholder();
      },
    );
  }

  Widget _buildAssetImage() {
    if (_isSvg) {
      return SvgPicture.asset(
        source!,
        width: width,
        height: height,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }

    return Image.asset(
      source!,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (_, __, ___) => placeholder ?? _defaultPlaceholder(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(26),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.withAlpha(128),
        size: (width ?? height ?? 24) * 0.6,
      ),
    );
  }
}
