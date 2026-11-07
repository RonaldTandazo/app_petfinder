enum MetricAction {
  open,
  filter,
  unknown;

  static MetricAction fromString(String? action) {
    switch (action) {
      case 'open':
        return MetricAction.open;
      case 'filter':
        return MetricAction.filter;
      default:
        return MetricAction.unknown;
    }
  }
}