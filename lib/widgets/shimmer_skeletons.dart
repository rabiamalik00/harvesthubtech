import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_colors.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EFE8),
      highlightColor: const Color(0xFFF7FAF7),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 110, height: 14, borderRadius: 4),
                  SizedBox(height: 6),
                  ShimmerBox(width: 70, height: 10, borderRadius: 4),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 60, height: 16, borderRadius: 4),
                      ShimmerBox(width: 32, height: 32, borderRadius: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerProductGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerProductGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double childAspectRatio = 0.72;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 5;
          childAspectRatio = 0.76;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.73;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: itemCount,
          itemBuilder: (_, index) => const ShimmerProductCard(),
        );
      },
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EFE8),
      highlightColor: const Color(0xFFF7FAF7),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 50, height: 50, borderRadius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 140, height: 14, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerBox(width: 90, height: 11, borderRadius: 4),
                ],
              ),
            ),
            const ShimmerBox(width: 60, height: 24, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
