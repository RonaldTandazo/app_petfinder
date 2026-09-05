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
    if (healthConditions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(healthConditions.length, (index) {
          final condition = healthConditions[index];
          final isSelected = selectedConditionIds.contains(condition.id);
          final isLast = index == healthConditions.length - 1;

          return Column(
            children: [
              CheckboxListTile(
                title: Text(condition.name, style: const TextStyle(fontSize: 14)),
                value: isSelected,
                activeColor: Colors.teal,
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