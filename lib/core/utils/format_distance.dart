/// 350 → '350m', 1240 → '1.2km'
String formatDistance(int meters) {
  if (meters < 1000) return '${meters}m';
  return '${(meters / 1000).toStringAsFixed(1)}km';
}
