// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get retry => '다시 시도';

  @override
  String get add => '추가';

  @override
  String get edit => '수정';

  @override
  String get save => '저장';

  @override
  String get select => '선택';

  @override
  String get all => '전체';

  @override
  String get etc => '기타';

  @override
  String deleteTooltip(Object name) {
    return '$name 삭제';
  }

  @override
  String editTooltip(Object name) {
    return '$name 수정';
  }

  @override
  String get navAlerts => '알림';

  @override
  String get navLocation => '위치';

  @override
  String get navGuide => '행동요령';

  @override
  String get navShare => '공유';

  @override
  String get navSettings => '설정';

  @override
  String get notificationSyncFailed => '알림 설정을 서버에 반영하지 못했습니다. 연결 후 다시 시도해주세요.';

  @override
  String get severityCritical => '위급';

  @override
  String get severityUrgent => '긴급';

  @override
  String get severitySafety => '안전안내';

  @override
  String get categoryHeatWave => '폭염';

  @override
  String get categoryEarthquake => '지진';

  @override
  String get categoryTyphoon => '태풍';

  @override
  String get categoryHeavyRain => '호우';

  @override
  String get relationFamily => '가족';

  @override
  String get relationFriend => '친구';

  @override
  String get relationAcquaintance => '지인';

  @override
  String durationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String durationHours(int hours) {
    return '$hours시간';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String get infoTitle => '재난 정보';

  @override
  String get infoLoadFailed => '재난 정보를 불러오지 못했습니다.\n네트워크 상태를 확인해 주세요.';

  @override
  String get infoEmpty => '해당 카테고리의 정보가 없습니다.';

  @override
  String get disasterDetailTitle => '재난문자 상세';

  @override
  String get disasterShowGuide => '행동요령 보기';

  @override
  String get disasterShowShelters => '대피소 보기';

  @override
  String get disasterAreaUnavailable => '재난 지역 위치를 표시할 수 없습니다.';

  @override
  String guideTitle(Object category) {
    return '$category 행동요령';
  }

  @override
  String get guideShowNearbyShelters => '가까운 대피소 보기';

  @override
  String guideStepTitle(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'earthquake1': '탁자 아래로 몸을 보호하세요',
      'earthquake2': '흔들림이 멈추면 전기와 가스를 차단하세요',
      'earthquake3': '계단을 이용해 밖으로 나가세요',
      'earthquake4': '넓은 공간으로 대피하세요',
      'earthquake5': '공식 정보를 따르세요',
      'heavyRain1': '기상 정보를 수시로 확인하세요',
      'heavyRain2': '하천과 저지대에 가까이 가지 마세요',
      'heavyRain3': '지하 공간에서 바로 나오세요',
      'heavyRain4': '물에 잠긴 도로는 건너지 마세요',
      'heavyRain5': '대피 권고가 내려지면 즉시 대피하세요',
      'typhoon1': '외출을 자제하세요',
      'typhoon2': '창문을 단단히 고정하세요',
      'typhoon3': '바람에 날릴 물건을 치우세요',
      'typhoon4': '해안가와 공사장 근처에 가지 마세요',
      'typhoon5': '정전에 대비하세요',
      'heatWave1': '물을 자주 마시세요',
      'heatWave2': '한낮에는 야외 활동을 피하세요',
      'heatWave3': '시원한 곳에 머무르세요',
      'heatWave4': '어지러우면 바로 쉬세요',
      'heatWave5': '주변 사람을 살펴주세요',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideStepDescription(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'earthquake1': '흔들리는 동안 탁자 아래로 들어가 다리를 꽉 잡고 머리를 보호합니다.',
      'earthquake2': '가스 밸브와 전기를 잠그고, 문을 열어 출구를 확보합니다.',
      'earthquake3': '엘리베이터는 타지 말고, 건물과 담장에서 떨어져 이동합니다.',
      'earthquake4': '가방 등으로 머리를 보호하며 운동장이나 공원처럼 넓은 곳으로 이동합니다.',
      'earthquake5': '재난문자·라디오 등으로 정보를 확인하고, 확인되지 않은 소문은 믿지 않습니다.',
      'heavyRain1': '재난문자·TV·라디오로 호우 특보와 대피 안내를 확인합니다.',
      'heavyRain2': '하천변 산책로, 계곡, 방파제에서는 즉시 벗어납니다.',
      'heavyRain3': '지하주차장·반지하에 물이 차기 시작하면 문이 열리지 않을 수 있으니 곧바로 지상으로 올라갑니다.',
      'heavyRain4': '물살이 약해 보여도 걸어서나 차로 지나가지 않습니다.',
      'heavyRain5': '전기와 가스를 차단하고 가까운 대피소로 이동합니다.',
      'typhoon1': '태풍 특보 중에는 실내에 머물며 기상 정보를 확인합니다.',
      'typhoon2': '창틀을 고정하고, 깨질 수 있는 유리창에서 떨어져 지냅니다.',
      'typhoon3': '화분·간판 등 날아갈 수 있는 물건을 실내로 옮기거나 단단히 묶습니다.',
      'typhoon4': '높은 파도에 휩쓸리거나 떨어지는 물체에 다칠 수 있습니다.',
      'typhoon5': '손전등, 보조배터리, 식수를 미리 챙겨 둡니다.',
      'heatWave1': '목이 마르지 않아도 규칙적으로 물을 마십니다.',
      'heatWave2': '가장 더운 오후 2시~5시에는 외출과 야외 작업을 줄입니다.',
      'heatWave3': '헐렁하고 밝은 옷을 입고, 가까운 무더위쉼터를 이용합니다.',
      'heatWave4': '두통·어지러움·메스꺼움이 느껴지면 시원한 곳에서 쉬고, 증상이 계속되면 119에 연락합니다.',
      'heatWave5': '어르신과 어린이 등 더위에 약한 이웃의 안부를 확인합니다.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get shelterLoadFailed => '대피소 정보를 불러오지 못했습니다.\n네트워크 상태를 확인해 주세요.';

  @override
  String get locationTimeout => '현재 위치를 확인하지 못했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get locationServiceDisabled => '위치 서비스가 꺼져 있습니다. 설정에서 켜 주세요.';

  @override
  String get locationPermissionDenied => '가까운 대피소를 찾으려면 위치 권한이 필요합니다.';

  @override
  String get locationPermissionDeniedForever => '설정에서 위치 권한을 허용해 주세요.';

  @override
  String get nearbyShelters => '가까운 대피소';

  @override
  String get disasterAreaShelters => '재난 지역 대피소';

  @override
  String get shelterOutsideArea => '현재 위치가 재난 지역 밖이라 지역 안의 대피소를 보여줍니다.';

  @override
  String shelterCount(int count) {
    return '$count곳';
  }

  @override
  String get routeLoadFailed => '경로를 불러오지 못했습니다.';

  @override
  String get routeHeadToShelter => '대피소 방향으로 이동하세요';

  @override
  String routeFarWarning(Object distance) {
    return '도보로 가기엔 먼 거리입니다($distance). 한 번 더 누르면 경로 안내를 시작합니다.';
  }

  @override
  String get routeStart => '경로 안내 시작';

  @override
  String get routeStartConfirm => '한 번 더 눌러 경로 안내 시작';

  @override
  String routeDistanceTo(Object destination, Object distance) {
    return '$destination까지 $distance';
  }

  @override
  String get routeEnd => '안내 종료';

  @override
  String routeSummary(Object distance, Object duration) {
    return '도보 $duration · $distance 남음';
  }

  @override
  String routeSummaryEstimated(Object distance, Object duration) {
    return '직선 약 $distance · 도보 $duration (추정)';
  }

  @override
  String get shareTitle => '안전 상태 공유';

  @override
  String get shareDefaultMessage => '저는 지금 안전합니다. 걱정하지 마세요.';

  @override
  String get sharePreviewNotice => '현재는 미리보기이며 실제 메시지는 전송되지 않습니다.';

  @override
  String get shareButton => '저는 안전합니다 (공유하기)';

  @override
  String get shareContactsTitle => '등록된 안전 연락처';

  @override
  String get shareContactsEmpty => '등록된 안전 연락처가 없습니다';

  @override
  String get shareContactsEmptyCaption => '연락처를 추가해 안전 상태를 공유할 준비를 해 주세요.';

  @override
  String get shareMessageTitle => '자동 생성 메시지';

  @override
  String get shareEditMessage => '메시지 수정';

  @override
  String get shareMessageLabel => '안전 상태 메시지';

  @override
  String get shareMessageEmpty => '공유할 메시지를 입력해 주세요.';

  @override
  String get sharePreviewDone => '미리보기 완료';

  @override
  String get sharePreviewNotSent => '실제 메시지는 전송되지 않았습니다.';

  @override
  String sharePreviewTargets(Object names) {
    return '미리보기 대상: $names';
  }

  @override
  String shareTodayAt(Object time) {
    return '오늘 $time';
  }

  @override
  String get shareNoData => '공유 정보가 없습니다.';

  @override
  String get shareBackHome => '홈으로 돌아가기';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsDisasterAlert => '재난문자 알림';

  @override
  String get settingsSafetyAlert => '안전 안내 알림';

  @override
  String get settingsLanguage => '언어 설정';

  @override
  String get settingsRegions => '관심지역 관리';

  @override
  String get settingsContacts => '안전 연락처 관리';

  @override
  String get settingsTextSize => '텍스트 크기 조절';

  @override
  String get settingsNeedsSetup => '설정 필요';

  @override
  String settingsRegionSummary(String region, int count) {
    return '$region 외 $count곳';
  }

  @override
  String settingsContactCount(int count) {
    return '$count명';
  }

  @override
  String get textSizeSmall => '작게';

  @override
  String get textSizeNormal => '보통';

  @override
  String get textSizeLarge => '크게';

  @override
  String get textSizeExtraLarge => '매우크게';

  @override
  String get textSizeSample => '재난 문자 예시입니다';

  @override
  String get contactSearchHint => '연락처를 입력하세요';

  @override
  String get contactsEmpty => '등록된 연락처가 없습니다';

  @override
  String get contactAdd => '연락처 추가';

  @override
  String get contactEdit => '연락처 수정';

  @override
  String contactAdded(Object name) {
    return '$name 연락처를 추가했습니다.';
  }

  @override
  String contactUpdated(Object name) {
    return '$name 연락처를 수정했습니다.';
  }

  @override
  String get contactName => '이름';

  @override
  String get contactNameHint => '이름을 입력하세요';

  @override
  String get contactPhone => '전화번호';

  @override
  String get contactSeoulTooLong => '서울(02) 번호는 10자리까지입니다. 번호를 확인해 주세요.';

  @override
  String get contactRelation => '관계';

  @override
  String get regionLoadFailed => '지역 정보를 불러오지 못했습니다';

  @override
  String get regionCodeNotFound => '선택한 지역의 재난문자 수신지역 코드를 찾지 못했습니다.';

  @override
  String get regionSearchTitle => '관심지역을 설정해주세요';

  @override
  String get regionSearchSubtitle => '재난 알림을 받을 지역을 선택하세요';

  @override
  String regionSelected(Object region) {
    return '$region(으)로 선택됨';
  }

  @override
  String get regionSearchHint => '지역을 입력하세요';

  @override
  String get regionNoChildren => '하위 지역이 없습니다';

  @override
  String get regionNoResults => '검색 결과가 없습니다';

  @override
  String get regionListTitle => '관심지역을 관리하세요';

  @override
  String get regionListSubtitle => '재난 알림을 받을 지역을 추가하거나 삭제하세요';

  @override
  String get regionListEmpty => '등록된 관심지역이 없습니다';

  @override
  String regionMigrationFailed(Object region) {
    return '$region\n자동 전환하지 못했습니다. 삭제 후 다시 추가해주세요';
  }

  @override
  String get regionPrimary => '대표';

  @override
  String get regionAdd => '관심지역 추가';
}
