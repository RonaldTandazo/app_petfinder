enum MetricAction {
  openPublished,
  openRescued,
  openFollowed,
  unknown;

  static MetricAction fromString(String? action) {
    switch (action) {
      case 'open_published':
        return MetricAction.openPublished;
      case 'open_rescued':
        return MetricAction.openRescued;
      case 'open_followed':
        return MetricAction.openFollowed;
      default:
        return MetricAction.unknown;
    }
  }
}