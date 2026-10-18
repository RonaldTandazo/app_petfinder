import 'package:flutter/material.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';
import 'package:app_petfinder/models/pictures/picture_model.dart';
import 'package:app_petfinder/widgets/images/app_full_screen_gallery.dart';

class AppBarImageCarousel extends StatefulWidget {
  final List<PictureModel> pictures;
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
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isMobile = screenSize.width < 600;
    final bool isShortScreen = screenSize.height < 650;

    final double expandedHeight = isMobile
        ? (isShortScreen ? 220 : 260)
        : 360;

    final double actionIconSize = isSmallPhone ? 23 : 28;
    final double actionButtonSize = isSmallPhone ? 44 : 48;
    final double controlPadding = isSmallPhone ? 5 : 6;
    final double controlIconSize = isSmallPhone ? 19 : 22;
    final double horizontalPosition = isSmallPhone ? 8 : 12;
    final double bottomPosition = isSmallPhone ? 8 : 12;
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: Colors.teal,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isSmallPhone ? 8 : 12),
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              constraints: BoxConstraints.tightFor(
                width: actionButtonSize,
                height: actionButtonSize,
              ),
              padding: EdgeInsets.zero,
              icon: Icon(
                widget.isFollowing
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: widget.isFollowing ? Colors.amber : Colors.white,
                size: actionIconSize,
              ),
              tooltip: widget.isFollowing
                  ? 'Dejar de seguir'
                  : 'Seguir caso',
              onPressed: widget.onToggleFollow,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.pictures.isNotEmpty
          ? Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                itemCount: widget.pictures.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.pictures[index].url,
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
                bottom: bottomPosition,
                left: horizontalPosition,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openFullScreenViewer(context, _currentImageIndex),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(controlPadding),
                      child: Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: controlIconSize,
                      ),
                    ),
                  ),
                ),
              ),

              // Contador de imágenes en la esquina inferior derecha
              if (widget.pictures.length > 1)
                Positioned(
                  bottom: bottomPosition,
                  right: horizontalPosition,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 8 : 10,
                      vertical: isSmallPhone ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${widget.pictures.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallPhone ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
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