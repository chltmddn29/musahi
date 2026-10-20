import 'package:musahi/l10n/app_localizations.dart';

// 서버 데이터와 저장된 연락처는 한국어 값을 그대로 키로 쓰므로 화면에 보일 때만 번역한다.
// 번역이 없는 값(서버가 새로 보낸 재난 유형 등)은 원문을 그대로 보여준다.

String severityLabel(AppLocalizations l10n, String severity) =>
    switch (severity) {
      '위급' => l10n.severityCritical,
      '긴급' => l10n.severityUrgent,
      '안전안내' => l10n.severitySafety,
      _ => severity,
    };

String disasterCategoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      '전체' => l10n.all,
      '기타' => l10n.etc,
      '폭염' => l10n.categoryHeatWave,
      '지진' => l10n.categoryEarthquake,
      '태풍' => l10n.categoryTyphoon,
      '호우' => l10n.categoryHeavyRain,
      _ => category,
    };

String relationLabel(AppLocalizations l10n, String relation) =>
    switch (relation) {
      '전체' => l10n.all,
      '가족' => l10n.relationFamily,
      '친구' => l10n.relationFriend,
      '지인' => l10n.relationAcquaintance,
      '기타' => l10n.etc,
      _ => relation,
    };
