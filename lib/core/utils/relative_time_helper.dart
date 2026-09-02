String formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inSeconds < 60) return 'ahora';
  if (diff.inMinutes < 2) return 'hace 1 min';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 2) return 'hace 1 h';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 2) return 'hace 1 día';
  if (diff.inDays < 7) return 'hace ${diff.inDays} días';
  if (diff.inDays < 31) return 'hace ${(diff.inDays / 7).floor()} sem';
  return 'hace ${(diff.inDays / 30).floor()} meses';
}