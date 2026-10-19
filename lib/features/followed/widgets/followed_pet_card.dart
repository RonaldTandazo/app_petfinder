import 'package:flutter/material.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/enums/followed/followed_pet_type.dart';
import 'package:app_petfinder/models/followed/followed_pet_model.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';

class FollowedPetCard extends StatelessWidget {
  final FollowedPetModel pet;
  final bool compact;
  final VoidCallback onTap;
  final String? distance;

  const FollowedPetCard({
    super.key,
    required this.pet,
    required this.compact,
    required this.onTap,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallPhone = screenWidth < 360;
    final bool isMobile = screenWidth < 600;

    final bool isMale = pet.gender.toUpperCase() == 'MALE' || pet.gender.toUpperCase() == 'MACHO';

    final cardRadius = isMobile ? 12.0 : 20.0;
    final contentPadding = isSmallPhone ? 6.0 : isMobile ? 8.0 : 12.0;
    final nameFontSize = isSmallPhone ? 10.0 : isMobile ? 12.0 : 16.0;
    final detailFontSize = isSmallPhone ? 9.0 : isMobile ? 10.0 : 11.0;
    final genderIconSize = isSmallPhone ? 16.0 : isMobile ? 18.0 : 20.0;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: compact
              ? _buildCompactCard(
                  context,
                  contentPadding,
                  isSmallPhone,
                  nameFontSize,
                  detailFontSize,
                  genderIconSize,
                  isMale,
                )
              : _buildGridCard(
                  context,
                  contentPadding,
                  isSmallPhone,
                  nameFontSize,
                  detailFontSize,
                  genderIconSize,
                  isMale,
                ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    double padding,
    bool isSmallPhone,
    double nameFontSize,
    double detailFontSize,
    double genderIconSize,
    bool isMale,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: isSmallPhone ? 100 : 116,
          child: _buildImage(isSmallPhone),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: _buildInformation(
              context,
              isSmallPhone: isSmallPhone,
              nameFontSize: nameFontSize,
              detailFontSize: detailFontSize,
              genderIconSize: genderIconSize,
              isMale: isMale,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    double padding,
    bool isSmallPhone,
    double nameFontSize,
    double detailFontSize,
    double genderIconSize,
    bool isMale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: _buildImage(isSmallPhone),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(padding),
          child: _buildInformation(
            context,
            isSmallPhone: isSmallPhone,
            nameFontSize: nameFontSize,
            detailFontSize: detailFontSize,
            genderIconSize: genderIconSize,
            isMale: isMale,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(bool isSmallPhone) {
    final bool hasImage = pet.imageUrl.trim().isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage)
          Image.network(
            pet.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return Container(
                color: Colors.grey.shade100,
                alignment: Alignment.center,
                child: SizedBox(
                  width: isSmallPhone ? 18 : 24,
                  height: isSmallPhone ? 18 : 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return AppImagePlaceholders.card(
                icon: Icons.broken_image_outlined,
                message: 'No se pudo obtener\nla imagen',
              );
            },
          )
        else
          AppImagePlaceholders.card(
            icon: Icons.pets,
            message: 'Sin imagen disponible',
          ),
      ],
    );
  }

  Widget _buildTypeBadge() {
    final isAdoption = pet.type == FollowedPetType.adoption;
    final color = isAdoption
        ? const Color(0xFF16866B)
        : const Color(0xFFE58B35);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdoption ? Icons.home_rounded : Icons.search_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isAdoption ? 'En adopción' : 'Mascota perdida',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformation(
    BuildContext context, {
    required bool isSmallPhone,
    required double nameFontSize,
    required double detailFontSize,
    required double genderIconSize,
    required bool isMale,
  }) {
    final theme = Theme.of(context);
    final detailColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: nameFontSize,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              getGenderIcon(isMale),
              size: genderIconSize,
              color: getGenderColor(isMale),
            ),
          ],
        ),
        SizedBox(height: isSmallPhone ? 4 : 6),
        _buildDetail(
          icon: Icons.pets_outlined,
          text: pet.species,
          color: detailColor,
          fontSize: detailFontSize,
        ),
        SizedBox(height: isSmallPhone ? 3 : 4),
        _buildDetail(
          icon: Icons.location_city_outlined,
          text: pet.location,
          color: detailColor,
          fontSize: detailFontSize,
        ),
        if (distance != null && distance!.trim().isNotEmpty) ...[
          SizedBox(height: isSmallPhone ? 4 : 6),
          _buildDistance(detailFontSize, isSmallPhone),
        ],
        SizedBox(height: isSmallPhone ? 4 : 6),
        _buildTypeBadge(),
      ],
    );
  }

  Widget _buildDetail({
    required IconData icon,
    required String text,
    required Color color,
    required double fontSize,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: fontSize + 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text.trim().isEmpty ? 'No especificado' : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistance(double fontSize, bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 4 : 6,
        vertical: isSmallPhone ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.near_me_outlined,
            size: fontSize + 2,
            color: Colors.teal.shade700,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              distance!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}