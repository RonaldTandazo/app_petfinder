

import 'package:app_petfinder/enums/account/metric_action.dart';

class MetricModel {
  final String label;
  final int count;
  final MetricAction action;

  MetricModel({
    required this.label,
    required this.count,
    required this.action,
  });

  factory MetricModel.fromJson(Map<String, dynamic> json) {
    return MetricModel(
      label: json['label'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      action: MetricAction.fromString(json['action'] as String?),
    );
  }
}