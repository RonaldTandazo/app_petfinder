import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';
import 'package:flutter/material.dart';

class AppFullScreenGallery extends StatefulWidget {
  final List<String> pictures;
  final int initialIndex;

  const AppFullScreenGallery({
    super.key,
    required this.pictures,
    required this.initialIndex,
  });

  @override
  State<AppFullScreenGallery> createState() => _AppFullScreenGalleryState();
}

class _AppFullScreenGalleryState extends State<AppFullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
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
                child: Center(
                  child: Image.network(
                    widget.pictures[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
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
              );
            },
          ),
          // Botón para cerrar en la parte superior izquierda
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Indicador de posición en la parte inferior
          if (widget.pictures.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.pictures.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}