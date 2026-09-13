

import 'package:app_petfinder/enums/account/metric_action.dart';

class MetricModel {
  final String label;
  final String tag;
  final int count;
  final MetricAction action;

  MetricModel({
    required this.label,
    required this.tag,
    required this.count,
    required this.action,
  });

  factory MetricModel.fromJson(Map<String, dynamic> json) {
    return MetricModel(
      label: json['label'] as String,
      tag: json['tag'] as String,
      count: json['count'] as int? ?? 0,
      action: MetricAction.fromString(json['action'] as String?),
    );
  }

  MetricModel copyWith({
    String? label,
    String? tag,
    int? count,
    MetricAction? action,
  }) {
    return MetricModel(
      label: label ?? this.label,
      tag: tag ?? this.tag,
      count: count ?? this.count,
      action: action ?? this.action,
    );
  }
}