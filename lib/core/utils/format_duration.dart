import 'package:musahi/l10n/app_localizations.dart';

/// 45분 → '45분', 150분 → '2시간 30분', 120분 → '2시간'. 초는 분 단위로 올림한다.
String formatDuration(AppLocalizations l10n, Duration duration) {
  final minutes = (duration.inSeconds / 60).ceil();
  if (minutes < 60) return l10n.durationMinutes(minutes);
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0
      ? l10n.durationHours(hours)
      : l10n.durationHoursMinutes(hours, rest);
}
