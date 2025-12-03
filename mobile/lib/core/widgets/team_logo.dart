import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final String code;
  final double size;

  const TeamLogo({super.key, this.logoUrl, required this.code, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: logoUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: logoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        code.isNotEmpty ? code[0].toUpperCase() : '?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: size * 0.4),
      ),
    );
  }
}

