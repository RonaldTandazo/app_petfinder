import 'package:flutter/material.dart';

class PublishPetSkeleton extends StatefulWidget {
  const PublishPetSkeleton({super.key});

  @override
  State<PublishPetSkeleton> createState() => _PublishPetSkeletonState();
}

class _PublishPetSkeletonState extends State<PublishPetSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _box({
    double? width,
    double height = 48,
    double radius = 12,
    required Color placeholderColor,
  }) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: placeholderColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required double titleWidth,
    required double subtitleWidth,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(width: titleWidth, height: 20, radius: 6, placeholderColor: colorScheme.surfaceContainerHighest),
        const SizedBox(height: 7),
        _box(width: subtitleWidth, height: 14, radius: 5, placeholderColor: colorScheme.surfaceContainerHighest),
      ],
    );
  }

  Widget _fieldSkeleton({
    required ColorScheme colorScheme,
  }) {
    return _box(height: 52, radius: 12, placeholderColor: colorScheme.surfaceContainerHighest);
  }

  Widget _toggleSkeleton({
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12,),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          _box(width: 42, height: 42, radius: 21, placeholderColor: colorScheme.surfaceContainerHighest),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 150, height: 16, radius: 5, placeholderColor: colorScheme.surfaceContainerHighest),
                const SizedBox(height: 7),
                _box(width: double.infinity, height: 13, radius: 5, placeholderColor: colorScheme.surfaceContainerHighest),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _box(width: 42, height: 24, radius: 20, placeholderColor: colorScheme.surfaceContainerHighest),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _box(width: 210, height: 20, radius: 6, placeholderColor: colorScheme.surfaceContainerHighest),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _sectionHeader(titleWidth: 110, subtitleWidth: 270, colorScheme: colorScheme),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _box(height: 110, radius: 14, placeholderColor: colorScheme.surfaceContainerHighest),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _box(height: 110, radius: 14, placeholderColor: colorScheme.surfaceContainerHighest),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _box(height: 110, radius: 14, placeholderColor: colorScheme.surfaceContainerHighest),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionHeader(titleWidth: 205, subtitleWidth: 145, colorScheme: colorScheme),

          const SizedBox(height: 12),

          _fieldSkeleton(colorScheme: colorScheme),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _fieldSkeleton(colorScheme: colorScheme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fieldSkeleton(colorScheme: colorScheme),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _fieldSkeleton(colorScheme: colorScheme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fieldSkeleton(colorScheme: colorScheme),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _fieldSkeleton(colorScheme: colorScheme),

          const SizedBox(height: 24),

          _sectionHeader(titleWidth: 155, subtitleWidth: 180, colorScheme: colorScheme),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _fieldSkeleton(colorScheme: colorScheme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fieldSkeleton(colorScheme: colorScheme),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _fieldSkeleton(colorScheme: colorScheme),

          const SizedBox(height: 12),

          Container(
            height: 78,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _box(width: 42, height: 42, radius: 21, placeholderColor: colorScheme.surfaceContainerHighest),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _box(width: 180, height: 15, radius: 5, placeholderColor: colorScheme.surfaceContainerHighest),
                      const SizedBox(height: 7),
                      _box(width: 250, height: 12, radius: 5, placeholderColor: colorScheme.surfaceContainerHighest),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _fieldSkeleton(colorScheme: colorScheme),

          const SizedBox(height: 14),

          _fieldSkeleton(colorScheme: colorScheme),

          const SizedBox(height: 24),

          _sectionHeader(titleWidth: 110, subtitleWidth: 300, colorScheme: colorScheme),

          const SizedBox(height: 8),

          _toggleSkeleton(colorScheme: colorScheme),

          const SizedBox(height: 24),

          _sectionHeader(titleWidth: 180, subtitleWidth: 300, colorScheme: colorScheme),

          const SizedBox(height: 12),

          _box(height: 110, radius: 12, placeholderColor: colorScheme.surfaceContainerHighest),

          const SizedBox(height: 32),

          _box(height: 54, radius: 16, placeholderColor: colorScheme.surfaceContainerHighest),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}