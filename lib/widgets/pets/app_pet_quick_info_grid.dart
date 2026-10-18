import 'package:flutter/material.dart';

class QuickInfoItem {
  final IconData icon;
  final String label;
  final String value;

  const QuickInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class AppPetQuickInfoGrid extends StatelessWidget {
  final List<QuickInfoItem> items;

  const AppPetQuickInfoGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isSmallPhone = width < 360;
        final bool isMobile = width < 600;

        final double containerPadding = isSmallPhone
            ? 8
            : isMobile
                ? 10
                : 12;

        final double iconSize = isSmallPhone ? 17 : 20;
        final double labelFontSize = isSmallPhone ? 9 : 11;
        final double valueFontSize = isSmallPhone ? 10 : 12;
        final double tileSpacing = isSmallPhone ? 4 : 6;

        final bool useGrid = isSmallPhone && items.length > 2;
        final int columns = useGrid ? 2 : items.length;
        
        return Container(
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: items.isEmpty
            ? const SizedBox.shrink()
            : useGrid
              ? _buildGrid(
                  columns: columns,
                  iconSize: iconSize,
                  labelFontSize: labelFontSize,
                  valueFontSize: valueFontSize,
                  tileSpacing: tileSpacing,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      Expanded(
                        child: _buildTile(
                          items[i],
                          iconSize: iconSize,
                          labelFontSize: labelFontSize,
                          valueFontSize: valueFontSize,
                          tileSpacing: tileSpacing,
                        ),
                      ),
                      if (i < items.length - 1)
                        Container(
                          height: 45,
                          width: 1,
                          margin: EdgeInsets.symmetric(
                            horizontal: isSmallPhone ? 2 : 4,
                          ),
                          color: Colors.grey.shade200,
                        ),
                    ],
                  ],
                ),
        );  
      }
    );
  }

  Widget _buildGrid({
    required int columns,
    required double iconSize,
    required double labelFontSize,
    required double valueFontSize,
    required double tileSpacing,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        mainAxisExtent: 76,
      ),
      itemBuilder: (context, index) {
        return _buildTile(
          items[index],
          iconSize: iconSize,
          labelFontSize: labelFontSize,
          valueFontSize: valueFontSize,
          tileSpacing: tileSpacing,
        );
      },
    );
  }

  Widget _buildTile(
    QuickInfoItem item, {
    required double iconSize,
    required double labelFontSize,
    required double valueFontSize,
    required double tileSpacing,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          item.icon,
          size: iconSize,
          color: Colors.teal,
        ),
        
        SizedBox(height: tileSpacing),

        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: labelFontSize,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}