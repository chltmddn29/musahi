/// 45분 → '45분', 150분 → '2시간 30분', 120분 → '2시간'. 초는 분 단위로 올림한다.
String formatDuration(Duration duration) {
  final minutes = (duration.inSeconds / 60).ceil();
  if (minutes < 60) return '$minutes분';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours시간' : '$hours시간 $rest분';
}
