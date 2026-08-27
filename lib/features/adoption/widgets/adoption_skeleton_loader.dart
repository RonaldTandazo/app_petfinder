import 'package:flutter/material.dart';

class AdoptionSkeletonLoader extends StatefulWidget {
  final bool isGrid;
  const AdoptionSkeletonLoader({super.key, this.isGrid = true});

  @override
  State<AdoptionSkeletonLoader> createState() => _AdoptionSkeletonLoaderState();
}

class _AdoptionSkeletonLoaderState extends State<AdoptionSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPlaceholderBox({required double height, double? width, double radius = 16}) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isGrid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildPlaceholderBox(height: 480, radius: 28),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPlaceholderBox(height: double.infinity, radius: 20)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceholderBox(height: 16, width: 90, radius: 4),
                    const SizedBox(height: 8),
                    _buildPlaceholderBox(height: 12, width: 60, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}