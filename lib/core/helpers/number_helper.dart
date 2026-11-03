double truncateDecimals(double value, int decimals) {
  return double.parse(value.toStringAsFixed(decimals));
}