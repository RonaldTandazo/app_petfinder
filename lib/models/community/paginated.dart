class Paginated<T> {
  final List<T> items;
  final bool hasMore;

  const Paginated({required this.items, required this.hasMore});

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) fromJson,
  ) {
    final items = (json['items'] as List?) ?? const [];

    return Paginated(
      items: items.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}