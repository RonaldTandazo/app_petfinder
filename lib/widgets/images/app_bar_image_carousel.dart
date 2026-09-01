import 'package:app_petfinder/widgets/images/app_full_screen_gallery.dart';
import 'package:flutter/material.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';

class AppBarImageCarousel extends StatefulWidget {
  final List<String> pictures;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final String title;

  const AppBarImageCarousel({
    super.key,
    required this.pictures,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.title,
  });

  @override
  State<AppBarImageCarousel> createState() => _AppBarImageCarouselState();
}

class _AppBarImageCarouselState extends State<AppBarImageCarousel> {
  int _currentImageIndex = 0;

  void _openFullScreenViewer(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return AppFullScreenGallery(
          pictures: widget.pictures,
          initialIndex: initialIndex,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.teal,
      actions: [
        IconButton(
          icon: Icon(
            widget.isFollowing ? Icons.bookmark : Icons.bookmark_border,
            color: widget.isFollowing ? Colors.amber : Colors.white,
            size: 28,
          ),
          tooltip: widget.isFollowing ? 'Dejar de seguir' : 'Seguir caso',
          onPressed: widget.onToggleFollow,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.pictures.isNotEmpty
            ? Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.pictures.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.pictures[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return AppImagePlaceholders.card(
                            icon: Icons.broken_image_outlined,
                            message: 'No se pudo obtener\nla imagen',
                          );
                        },
                      );
                    },
                  ),
                  // Botón de pantalla completa en la esquina inferior izquierda
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openFullScreenViewer(context, _currentImageIndex),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Contador de imágenes en la esquina inferior derecha
                  if (widget.pictures.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.pictures.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              )
            : AppImagePlaceholders.card(
                icon: Icons.pets,
                message: 'Sin imágenes disponibles',
              ),
      ),
    );
  }
}