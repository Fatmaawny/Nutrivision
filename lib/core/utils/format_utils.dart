/// 0 -> "0.0" | 1200 -> "1.2" | 1250 -> "1.25" | 2500 -> "2.5"
String formatLiters(int ml) {
  final s = (ml / 1000).toStringAsFixed(2);
  return s.endsWith('0') ? s.substring(0, s.length - 1) : s;
}

/// 1250 -> "1,250"
String formatMl(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
