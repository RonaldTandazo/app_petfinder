import 'package:flutter/material.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';
import 'package:app_petfinder/models/pictures/picture_model.dart';

class AppFullScreenGallery extends StatefulWidget {
  final List<PictureModel> pictures;
  final int initialIndex;

  const AppFullScreenGallery({
    super.key,
    required this.pictures,
    required this.initialIndex,
  });

  @override
  State<AppFullScreenGallery> createState() =>
      _AppFullScreenGalleryState();
}

class _AppFullScreenGalleryState extends State<AppFullScreenGallery> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.pictures.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.pictures.length - 1);

    _pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bool isSmallPhone = screenWidth < 360;

    if (widget.pictures.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.pictures.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: SizedBox(
                  width: screenWidth,
                  child: Center(
                    child: Image.network(
                      widget.pictures[index].url,
                      fit: BoxFit.contain,
                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) return child;

                        return Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                              value: loadingProgress.expectedTotalBytes !=
                                      null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return AppImagePlaceholders.swipe(
                          icon: Icons.broken_image_outlined,
                          message: 'No se pudo obtener\nla imagen',
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Botón para cerrar
          Positioned(
            top: mediaQuery.padding.top + (isSmallPhone ? 8 : 12),
            left: isSmallPhone ? 12 : 16,
            child: CircleAvatar(
              radius: isSmallPhone ? 20 : 23,
              backgroundColor: Colors.black54,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: isSmallPhone ? 22 : 26,
                tooltip: 'Cerrar galería',
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Indicador de posición
          if (widget.pictures.length > 1)
            Positioned(
              bottom: mediaQuery.padding.bottom + (isSmallPhone ? 16 : 20),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallPhone ? 12 : 14,
                    vertical: isSmallPhone ? 5 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.pictures.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallPhone ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}