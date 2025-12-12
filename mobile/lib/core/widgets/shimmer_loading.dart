import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);

    return Shimmer.fromColors(
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerMatchCard extends StatelessWidget {
  const ShimmerMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home team
                Expanded(
                  child: Column(
                    children: const [
                      ShimmerLoading(width: 50, height: 50, borderRadius: 25),
                      SizedBox(height: 8),
                      ShimmerLoading(width: 80, height: 14),
                    ],
                  ),
                ),
                // Score
                Column(
                  children: const [
                    ShimmerLoading(width: 60, height: 12),
                    SizedBox(height: 8),
                    ShimmerLoading(width: 80, height: 28),
                    SizedBox(height: 8),
                    ShimmerLoading(width: 50, height: 12),
                  ],
                ),
                // Away team
                Expanded(
                  child: Column(
                    children: const [
                      ShimmerLoading(width: 50, height: 50, borderRadius: 25),
                      SizedBox(height: 8),
                      ShimmerLoading(width: 80, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerNewsList extends StatelessWidget {
  final int itemCount;

  const ShimmerNewsList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerNewsCard(),
    );
  }
}

class ShimmerNewsCard extends StatelessWidget {
  const ShimmerNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const ShimmerLoading(width: 100, height: 80, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(height: 16),
                  SizedBox(height: 8),
                  ShimmerLoading(height: 14),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerLeaderboardList extends StatelessWidget {
  final int itemCount;

  const ShimmerLeaderboardList({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerLeaderboardItem(),
    );
  }
}

class ShimmerLeaderboardItem extends StatelessWidget {
  const ShimmerLeaderboardItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const ShimmerLoading(width: 30, height: 20),
          const SizedBox(width: 12),
          const ShimmerLoading(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(width: 120, height: 14),
                SizedBox(height: 4),
                ShimmerLoading(width: 80, height: 12),
              ],
            ),
          ),
          const ShimmerLoading(width: 60, height: 16),
        ],
      ),
    );
  }
}

class ShimmerRewardGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerRewardGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerRewardCard(),
    );
  }
}

class ShimmerRewardCard extends StatelessWidget {
  const ShimmerRewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: ShimmerLoading(borderRadius: 8)),
            SizedBox(height: 12),
            ShimmerLoading(height: 16),
            SizedBox(height: 8),
            ShimmerLoading(width: 80, height: 14),
          ],
        ),
      ),
    );
  }
}

class ShimmerProfileHeader extends StatelessWidget {
  const ShimmerProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShimmerLoading(width: 100, height: 100, borderRadius: 50),
        const SizedBox(height: 16),
        const ShimmerLoading(width: 150, height: 20),
        const SizedBox(height: 8),
        const ShimmerLoading(width: 200, height: 14),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) => Column(
              children: const [
                ShimmerLoading(width: 50, height: 24),
                SizedBox(height: 4),
                ShimmerLoading(width: 60, height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

