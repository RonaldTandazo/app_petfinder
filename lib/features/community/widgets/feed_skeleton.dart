import 'package:flutter/material.dart';

class FeedSkeleton extends StatefulWidget {
  final int itemCount;

  const FeedSkeleton({super.key, this.itemCount = 4});

  @override
  State<FeedSkeleton> createState() => _FeedSkeletonState();
}

class _FeedSkeletonState extends State<FeedSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPlaceholderBox({required double height, double? width, double radius = 8}) {
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPlaceholderBox(height: 40, width: 40, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlaceholderBox(height: 14, width: 140),
                        const SizedBox(height: 6),
                        _buildPlaceholderBox(height: 12, width: 80),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPlaceholderBox(height: 180, radius: 12),
              const SizedBox(height: 12),
              _buildPlaceholderBox(height: 16, width: 200),
              const SizedBox(height: 8),
              _buildPlaceholderBox(height: 12, width: double.infinity),
              const SizedBox(height: 12),
              _buildPlaceholderBox(height: 24, width: 120, radius: 12),
            ],
          ),
        );
      },
    );
  }
}