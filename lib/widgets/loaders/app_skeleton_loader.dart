import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/skeleton/skeleton_view_mode.dart';

class AppSkeletonLoader extends StatefulWidget {
  final SkeletonViewMode mode;
  final int itemCount;

  const AppSkeletonLoader({
    super.key,
    this.mode = SkeletonViewMode.grid,
    this.itemCount = 10,
  });

  @override
  State<AppSkeletonLoader> createState() => _AppSkeletonLoaderState();
}

class _AppSkeletonLoaderState extends State<AppSkeletonLoader> with SingleTickerProviderStateMixin {
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

  Widget _buildPlaceholderBox({
    required double height,
    double? width,
    double radius = 16,
    required Color placeholderColor,
  }) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: placeholderColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.mode) {
      case SkeletonViewMode.swipe:
        return _buildSwipeSkeleton(colorScheme);
      case SkeletonViewMode.list:
        return _buildListSkeleton(colorScheme);
      case SkeletonViewMode.grid:
        return _buildGridSkeleton(colorScheme);
    }
  }

  /// Modo Swipe / Tinder Card
  Widget _buildSwipeSkeleton(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildPlaceholderBox(
          height: 480,
          radius: 28,
          placeholderColor: colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  /// Modo Lista (Horizontal Image + Details)
  Widget _buildListSkeleton(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (_, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Placeholder de la imagen (100x100)
              _buildPlaceholderBox(height: 100, width: 100, radius: 12, placeholderColor: colorScheme.surfaceContainerHighest),
              const SizedBox(width: 12),

              // Placeholder de los textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPlaceholderBox(height: 16, width: 110, radius: 4, placeholderColor: colorScheme.surfaceContainerHighest),
                        _buildPlaceholderBox(height: 12, width: 75, radius: 4, placeholderColor: colorScheme.surfaceContainerHighest),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildPlaceholderBox(height: 12, width: 90, radius: 4, placeholderColor: colorScheme.surfaceContainerHighest),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPlaceholderBox(height: 12, width: 130, radius: 4, placeholderColor: colorScheme.surfaceContainerHighest),
                        _buildPlaceholderBox(height: 12, width: 50, radius: 4, placeholderColor: colorScheme.surfaceContainerHighest),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Modo Grid (2 Columnas)
  Widget _buildGridSkeleton(ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (_, _) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPlaceholderBox(
                  height: double.infinity,
                  radius: 20,
                  placeholderColor: colorScheme.surfaceContainerHighest
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceholderBox(height: 16, width: 90, radius: 4, placeholderColor: colorScheme.surfaceContainerHighest),
                    const SizedBox(height: 8),
                    _buildPlaceholderBox(height: 12, width: 60, radius: 4, placeholderColor: colorScheme.surfaceContainerHighest),
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