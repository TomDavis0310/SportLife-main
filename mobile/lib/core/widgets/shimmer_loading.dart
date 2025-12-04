import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
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
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home team
                Expanded(
                  child: Column(
                    children: [
                      ShimmerLoading(width: 50, height: 50, borderRadius: 25),
                      SizedBox(height: 8),
                      ShimmerLoading(width: 80, height: 14),
                    ],
                  ),
                ),
                // Score
                Column(
                  children: [
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
                    children: [
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
    return const Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ShimmerLoading(width: 100, height: 80, borderRadius: 8),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ShimmerLoading(width: 30, height: 20),
          SizedBox(width: 12),
          ShimmerLoading(width: 40, height: 40, borderRadius: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: 120, height: 14),
                SizedBox(height: 4),
                ShimmerLoading(width: 80, height: 12),
              ],
            ),
          ),
          ShimmerLoading(width: 60, height: 16),
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
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            (index) => const Column(
              children: [
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

