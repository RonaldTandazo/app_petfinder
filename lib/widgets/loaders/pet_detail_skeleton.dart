import 'package:flutter/material.dart';

class PetDetailSkeleton extends StatefulWidget {
  const PetDetailSkeleton({
    super.key,
  });

  @override
  State<PetDetailSkeleton> createState() => _PetDetailSkeletonState();
}

class _PetDetailSkeletonState extends State<PetDetailSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({
    required Color placeholderColor,
    required double height,
    double? width,
    double radius = 8,
  }) {
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return CustomScrollView(
      slivers: [
        _buildImageCarouselSkeleton(),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSkeleton(colorScheme),
                const SizedBox(height: 16),

                _buildQuickInfoSkeleton(colorScheme),
                const SizedBox(height: 16),

                _buildDescriptionSkeleton(colorScheme),
                const SizedBox(height: 20),

                _buildContactSkeleton(colorScheme),
                const SizedBox(height: 24),

                _buildSightingsSkeleton(colorScheme),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarouselSkeleton() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.grey.shade300,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _animation,
          child: Container(
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado + recompensa
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _box(
              height: 28,
              width: 80,
              radius: 20,
              placeholderColor: colorScheme.surfaceContainerHighest,
            ),
            _box(
              height: 30,
              width: 130,
              radius: 20,
              placeholderColor: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Nombre + género
        Row(
          children: [
            Expanded(
              child: _box(
                height: 28,
                width: 180,
                radius: 6,
                placeholderColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(width: 8),
            _box(
              height: 26,
              width: 26,
              radius: 13,
              placeholderColor: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Especie / raza / tamaño
        _box(
          height: 14,
          width: 230,
          radius: 4,
          placeholderColor: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildQuickInfoSkeleton(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildQuickInfoItemSkeleton(colorScheme)),
          Container(
            height: 45,
            width: 1,
            color: Colors.grey.shade200,
          ),
          Expanded(child: _buildQuickInfoItemSkeleton(colorScheme)),
          Container(
            height: 45,
            width: 1,
            color: Colors.grey.shade200,
          ),
          Expanded(child: _buildQuickInfoItemSkeleton(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItemSkeleton(ColorScheme colorScheme) {
    return Column(
      children: [
        _box(
          height: 20,
          width: 20,
          radius: 10,
          placeholderColor: colorScheme.surfaceContainerHighest
        ),
        const SizedBox(height: 6),
        _box(
          height: 10,
          width: 45,
          radius: 4,
          placeholderColor: colorScheme.surfaceContainerHighest
        ),
        const SizedBox(height: 5),
        _box(
          height: 12,
          width: 65,
          radius: 4,
          placeholderColor: colorScheme.surfaceContainerHighest
        ),
      ],
    );
  }

  Widget _buildDescriptionSkeleton(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(
          height: 18,
          width: 110,
          radius: 4,
          placeholderColor: colorScheme.surfaceContainerHighest
        ),
        const SizedBox(height: 10),
        _box(height: 12, placeholderColor: colorScheme.surfaceContainerHighest),
        const SizedBox(height: 7),
        _box(height: 12, placeholderColor: colorScheme.surfaceContainerHighest),
        const SizedBox(height: 7),
        _box(
          height: 12,
          width: 260,
          placeholderColor: colorScheme.surfaceContainerHighest
        ),
      ],
    );
  }

  Widget _buildContactSkeleton(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 600;

        if (isSmall) {
          return Column(
            children: [
              _box(
                height: 48,
                radius: 10,
                placeholderColor: colorScheme.surfaceContainerHighest
              ),
              const SizedBox(height: 10),
              _box(
                height: 48,
                radius: 10,
                placeholderColor: colorScheme.surfaceContainerHighest
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _box(
                height: 48,
                radius: 10,
                placeholderColor: colorScheme.surfaceContainerHighest
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                height: 48,
                radius: 10,
                placeholderColor: colorScheme.surfaceContainerHighest
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSightingsSkeleton(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _box(
              height: 20,
              width: 180,
              radius: 4,
              placeholderColor: colorScheme.surfaceContainerHighest
            ),
            _box(
              height: 14,
              width: 70,
              radius: 4,
              placeholderColor: colorScheme.surfaceContainerHighest
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Mapa
        _box(
          height: 280,
          radius: 16,
          placeholderColor: colorScheme.surfaceContainerHighest
        ),

        const SizedBox(height: 16),

        _box(
          height: 18,
          width: 190,
          radius: 4,
          placeholderColor: colorScheme.surfaceContainerHighest
        ),

        const SizedBox(height: 10),

        // Items del historial
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _box(
                    height: 40,
                    width: 40,
                    radius: 20,
                    placeholderColor: colorScheme.surfaceContainerHighest
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(
                          height: 13,
                          width: 160,
                          radius: 4,
                          placeholderColor: colorScheme.surfaceContainerHighest
                        ),
                        const SizedBox(height: 7),
                        _box(
                          height: 11,
                          width: 220,
                          radius: 4,
                          placeholderColor: colorScheme.surfaceContainerHighest
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}