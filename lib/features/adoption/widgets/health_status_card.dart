import 'package:flutter/material.dart';
import 'package:app_petfinder/models/catalog/health_condition_model.dart';

class HealthStatusCard extends StatelessWidget {
  final List<HealthConditionModel> healthConditions;
  final Set<int> selectedConditionIds;
  final ValueChanged<int> onConditionToggled;

  const HealthStatusCard({
    super.key,
    required this.healthConditions,
    required this.selectedConditionIds,
    required this.onConditionToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (healthConditions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: List.generate(healthConditions.length, (index) {
          final condition = healthConditions[index];
          final isSelected = selectedConditionIds.contains(condition.id);
          final isLast = index == healthConditions.length - 1;

          return Column(
            children: [
              CheckboxListTile(
                title: Text(
                  condition.name,
                  style: theme.textTheme.bodyMedium,
                ),
                value: isSelected,
                activeColor: colorScheme.primary,
                onChanged: (_) => onConditionToggled(condition.id),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }),
      ),
    );
  }
}