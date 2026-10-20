import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @select.
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get select;

  /// No description provided for @all.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get all;

  /// No description provided for @etc.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get etc;

  /// No description provided for @deleteTooltip.
  ///
  /// In ko, this message translates to:
  /// **'{name} 삭제'**
  String deleteTooltip(Object name);

  /// No description provided for @editTooltip.
  ///
  /// In ko, this message translates to:
  /// **'{name} 수정'**
  String editTooltip(Object name);

  /// No description provided for @navAlerts.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get navAlerts;

  /// No description provided for @navLocation.
  ///
  /// In ko, this message translates to:
  /// **'위치'**
  String get navLocation;

  /// No description provided for @navGuide.
  ///
  /// In ko, this message translates to:
  /// **'행동요령'**
  String get navGuide;

  /// No description provided for @navShare.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get navShare;

  /// No description provided for @navSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get navSettings;

  /// No description provided for @notificationSyncFailed.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정을 서버에 반영하지 못했습니다. 연결 후 다시 시도해주세요.'**
  String get notificationSyncFailed;

  /// No description provided for @severityCritical.
  ///
  /// In ko, this message translates to:
  /// **'위급'**
  String get severityCritical;

  /// No description provided for @severityUrgent.
  ///
  /// In ko, this message translates to:
  /// **'긴급'**
  String get severityUrgent;

  /// No description provided for @severitySafety.
  ///
  /// In ko, this message translates to:
  /// **'안전안내'**
  String get severitySafety;

  /// No description provided for @categoryHeatWave.
  ///
  /// In ko, this message translates to:
  /// **'폭염'**
  String get categoryHeatWave;

  /// No description provided for @categoryEarthquake.
  ///
  /// In ko, this message translates to:
  /// **'지진'**
  String get categoryEarthquake;

  /// No description provided for @categoryTyphoon.
  ///
  /// In ko, this message translates to:
  /// **'태풍'**
  String get categoryTyphoon;

  /// No description provided for @categoryHeavyRain.
  ///
  /// In ko, this message translates to:
  /// **'호우'**
  String get categoryHeavyRain;

  /// No description provided for @relationFamily.
  ///
  /// In ko, this message translates to:
  /// **'가족'**
  String get relationFamily;

  /// No description provided for @relationFriend.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get relationFriend;

  /// No description provided for @relationAcquaintance.
  ///
  /// In ko, this message translates to:
  /// **'지인'**
  String get relationAcquaintance;

  /// No description provided for @durationMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 {minutes}분'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @infoTitle.
  ///
  /// In ko, this message translates to:
  /// **'재난 정보'**
  String get infoTitle;

  /// No description provided for @infoLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'재난 정보를 불러오지 못했습니다.\n네트워크 상태를 확인해 주세요.'**
  String get infoLoadFailed;

  /// No description provided for @infoEmpty.
  ///
  /// In ko, this message translates to:
  /// **'해당 카테고리의 정보가 없습니다.'**
  String get infoEmpty;

  /// No description provided for @disasterDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'재난문자 상세'**
  String get disasterDetailTitle;

  /// No description provided for @disasterShowGuide.
  ///
  /// In ko, this message translates to:
  /// **'행동요령 보기'**
  String get disasterShowGuide;

  /// No description provided for @disasterShowShelters.
  ///
  /// In ko, this message translates to:
  /// **'대피소 보기'**
  String get disasterShowShelters;

  /// No description provided for @disasterAreaUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'재난 지역 위치를 표시할 수 없습니다.'**
  String get disasterAreaUnavailable;

  /// No description provided for @guideTitle.
  ///
  /// In ko, this message translates to:
  /// **'{category} 행동요령'**
  String guideTitle(Object category);

  /// No description provided for @guideShowNearbyShelters.
  ///
  /// In ko, this message translates to:
  /// **'가까운 대피소 보기'**
  String get guideShowNearbyShelters;

  /// No description provided for @guideStepTitle.
  ///
  /// In ko, this message translates to:
  /// **'{step, select, earthquake1{탁자 아래로 몸을 보호하세요} earthquake2{흔들림이 멈추면 전기와 가스를 차단하세요} earthquake3{계단을 이용해 밖으로 나가세요} earthquake4{넓은 공간으로 대피하세요} earthquake5{공식 정보를 따르세요} heavyRain1{기상 정보를 수시로 확인하세요} heavyRain2{하천과 저지대에 가까이 가지 마세요} heavyRain3{지하 공간에서 바로 나오세요} heavyRain4{물에 잠긴 도로는 건너지 마세요} heavyRain5{대피 권고가 내려지면 즉시 대피하세요} typhoon1{외출을 자제하세요} typhoon2{창문을 단단히 고정하세요} typhoon3{바람에 날릴 물건을 치우세요} typhoon4{해안가와 공사장 근처에 가지 마세요} typhoon5{정전에 대비하세요} heatWave1{물을 자주 마시세요} heatWave2{한낮에는 야외 활동을 피하세요} heatWave3{시원한 곳에 머무르세요} heatWave4{어지러우면 바로 쉬세요} heatWave5{주변 사람을 살펴주세요} other{}}'**
  String guideStepTitle(String step);

  /// No description provided for @guideStepDescription.
  ///
  /// In ko, this message translates to:
  /// **'{step, select, earthquake1{흔들리는 동안 탁자 아래로 들어가 다리를 꽉 잡고 머리를 보호합니다.} earthquake2{가스 밸브와 전기를 잠그고, 문을 열어 출구를 확보합니다.} earthquake3{엘리베이터는 타지 말고, 건물과 담장에서 떨어져 이동합니다.} earthquake4{가방 등으로 머리를 보호하며 운동장이나 공원처럼 넓은 곳으로 이동합니다.} earthquake5{재난문자·라디오 등으로 정보를 확인하고, 확인되지 않은 소문은 믿지 않습니다.} heavyRain1{재난문자·TV·라디오로 호우 특보와 대피 안내를 확인합니다.} heavyRain2{하천변 산책로, 계곡, 방파제에서는 즉시 벗어납니다.} heavyRain3{지하주차장·반지하에 물이 차기 시작하면 문이 열리지 않을 수 있으니 곧바로 지상으로 올라갑니다.} heavyRain4{물살이 약해 보여도 걸어서나 차로 지나가지 않습니다.} heavyRain5{전기와 가스를 차단하고 가까운 대피소로 이동합니다.} typhoon1{태풍 특보 중에는 실내에 머물며 기상 정보를 확인합니다.} typhoon2{창틀을 고정하고, 깨질 수 있는 유리창에서 떨어져 지냅니다.} typhoon3{화분·간판 등 날아갈 수 있는 물건을 실내로 옮기거나 단단히 묶습니다.} typhoon4{높은 파도에 휩쓸리거나 떨어지는 물체에 다칠 수 있습니다.} typhoon5{손전등, 보조배터리, 식수를 미리 챙겨 둡니다.} heatWave1{목이 마르지 않아도 규칙적으로 물을 마십니다.} heatWave2{가장 더운 오후 2시~5시에는 외출과 야외 작업을 줄입니다.} heatWave3{헐렁하고 밝은 옷을 입고, 가까운 무더위쉼터를 이용합니다.} heatWave4{두통·어지러움·메스꺼움이 느껴지면 시원한 곳에서 쉬고, 증상이 계속되면 119에 연락합니다.} heatWave5{어르신과 어린이 등 더위에 약한 이웃의 안부를 확인합니다.} other{}}'**
  String guideStepDescription(String step);

  /// No description provided for @shelterLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'대피소 정보를 불러오지 못했습니다.\n네트워크 상태를 확인해 주세요.'**
  String get shelterLoadFailed;

  /// No description provided for @locationTimeout.
  ///
  /// In ko, this message translates to:
  /// **'현재 위치를 확인하지 못했습니다. 잠시 후 다시 시도해 주세요.'**
  String get locationTimeout;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In ko, this message translates to:
  /// **'위치 서비스가 꺼져 있습니다. 설정에서 켜 주세요.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In ko, this message translates to:
  /// **'가까운 대피소를 찾으려면 위치 권한이 필요합니다.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 위치 권한을 허용해 주세요.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @nearbyShelters.
  ///
  /// In ko, this message translates to:
  /// **'가까운 대피소'**
  String get nearbyShelters;

  /// No description provided for @disasterAreaShelters.
  ///
  /// In ko, this message translates to:
  /// **'재난 지역 대피소'**
  String get disasterAreaShelters;

  /// No description provided for @shelterOutsideArea.
  ///
  /// In ko, this message translates to:
  /// **'현재 위치가 재난 지역 밖이라 지역 안의 대피소를 보여줍니다.'**
  String get shelterOutsideArea;

  /// No description provided for @shelterCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}곳'**
  String shelterCount(int count);

  /// No description provided for @routeLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'경로를 불러오지 못했습니다.'**
  String get routeLoadFailed;

  /// No description provided for @routeHeadToShelter.
  ///
  /// In ko, this message translates to:
  /// **'대피소 방향으로 이동하세요'**
  String get routeHeadToShelter;

  /// No description provided for @routeFarWarning.
  ///
  /// In ko, this message translates to:
  /// **'도보로 가기엔 먼 거리입니다({distance}). 한 번 더 누르면 경로 안내를 시작합니다.'**
  String routeFarWarning(Object distance);

  /// No description provided for @routeStart.
  ///
  /// In ko, this message translates to:
  /// **'경로 안내 시작'**
  String get routeStart;

  /// No description provided for @routeStartConfirm.
  ///
  /// In ko, this message translates to:
  /// **'한 번 더 눌러 경로 안내 시작'**
  String get routeStartConfirm;

  /// No description provided for @routeDistanceTo.
  ///
  /// In ko, this message translates to:
  /// **'{destination}까지 {distance}'**
  String routeDistanceTo(Object destination, Object distance);

  /// No description provided for @routeEnd.
  ///
  /// In ko, this message translates to:
  /// **'안내 종료'**
  String get routeEnd;

  /// No description provided for @routeSummary.
  ///
  /// In ko, this message translates to:
  /// **'도보 {duration} · {distance} 남음'**
  String routeSummary(Object distance, Object duration);

  /// No description provided for @routeSummaryEstimated.
  ///
  /// In ko, this message translates to:
  /// **'직선 약 {distance} · 도보 {duration} (추정)'**
  String routeSummaryEstimated(Object distance, Object duration);

  /// No description provided for @shareTitle.
  ///
  /// In ko, this message translates to:
  /// **'안전 상태 공유'**
  String get shareTitle;

  /// No description provided for @shareDefaultMessage.
  ///
  /// In ko, this message translates to:
  /// **'저는 지금 안전합니다. 걱정하지 마세요.'**
  String get shareDefaultMessage;

  /// No description provided for @sharePreviewNotice.
  ///
  /// In ko, this message translates to:
  /// **'현재는 미리보기이며 실제 메시지는 전송되지 않습니다.'**
  String get sharePreviewNotice;

  /// No description provided for @shareButton.
  ///
  /// In ko, this message translates to:
  /// **'저는 안전합니다 (공유하기)'**
  String get shareButton;

  /// No description provided for @shareContactsTitle.
  ///
  /// In ko, this message translates to:
  /// **'등록된 안전 연락처'**
  String get shareContactsTitle;

  /// No description provided for @shareContactsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 안전 연락처가 없습니다'**
  String get shareContactsEmpty;

  /// No description provided for @shareContactsEmptyCaption.
  ///
  /// In ko, this message translates to:
  /// **'연락처를 추가해 안전 상태를 공유할 준비를 해 주세요.'**
  String get shareContactsEmptyCaption;

  /// No description provided for @shareMessageTitle.
  ///
  /// In ko, this message translates to:
  /// **'자동 생성 메시지'**
  String get shareMessageTitle;

  /// No description provided for @shareEditMessage.
  ///
  /// In ko, this message translates to:
  /// **'메시지 수정'**
  String get shareEditMessage;

  /// No description provided for @shareMessageLabel.
  ///
  /// In ko, this message translates to:
  /// **'안전 상태 메시지'**
  String get shareMessageLabel;

  /// No description provided for @shareMessageEmpty.
  ///
  /// In ko, this message translates to:
  /// **'공유할 메시지를 입력해 주세요.'**
  String get shareMessageEmpty;

  /// No description provided for @sharePreviewDone.
  ///
  /// In ko, this message translates to:
  /// **'미리보기 완료'**
  String get sharePreviewDone;

  /// No description provided for @sharePreviewNotSent.
  ///
  /// In ko, this message translates to:
  /// **'실제 메시지는 전송되지 않았습니다.'**
  String get sharePreviewNotSent;

  /// No description provided for @sharePreviewTargets.
  ///
  /// In ko, this message translates to:
  /// **'미리보기 대상: {names}'**
  String sharePreviewTargets(Object names);

  /// No description provided for @shareTodayAt.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {time}'**
  String shareTodayAt(Object time);

  /// No description provided for @shareNoData.
  ///
  /// In ko, this message translates to:
  /// **'공유 정보가 없습니다.'**
  String get shareNoData;

  /// No description provided for @shareBackHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로 돌아가기'**
  String get shareBackHome;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsDisasterAlert.
  ///
  /// In ko, this message translates to:
  /// **'재난문자 알림'**
  String get settingsDisasterAlert;

  /// No description provided for @settingsSafetyAlert.
  ///
  /// In ko, this message translates to:
  /// **'안전 안내 알림'**
  String get settingsSafetyAlert;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get settingsLanguage;

  /// No description provided for @settingsRegions.
  ///
  /// In ko, this message translates to:
  /// **'관심지역 관리'**
  String get settingsRegions;

  /// No description provided for @settingsContacts.
  ///
  /// In ko, this message translates to:
  /// **'안전 연락처 관리'**
  String get settingsContacts;

  /// No description provided for @settingsTextSize.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 크기 조절'**
  String get settingsTextSize;

  /// No description provided for @settingsNeedsSetup.
  ///
  /// In ko, this message translates to:
  /// **'설정 필요'**
  String get settingsNeedsSetup;

  /// No description provided for @settingsRegionSummary.
  ///
  /// In ko, this message translates to:
  /// **'{region} 외 {count}곳'**
  String settingsRegionSummary(String region, int count);

  /// No description provided for @settingsContactCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String settingsContactCount(int count);

  /// No description provided for @textSizeSmall.
  ///
  /// In ko, this message translates to:
  /// **'작게'**
  String get textSizeSmall;

  /// No description provided for @textSizeNormal.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In ko, this message translates to:
  /// **'크게'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In ko, this message translates to:
  /// **'매우크게'**
  String get textSizeExtraLarge;

  /// No description provided for @textSizeSample.
  ///
  /// In ko, this message translates to:
  /// **'재난 문자 예시입니다'**
  String get textSizeSample;

  /// No description provided for @contactSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'연락처를 입력하세요'**
  String get contactSearchHint;

  /// No description provided for @contactsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 연락처가 없습니다'**
  String get contactsEmpty;

  /// No description provided for @contactAdd.
  ///
  /// In ko, this message translates to:
  /// **'연락처 추가'**
  String get contactAdd;

  /// No description provided for @contactEdit.
  ///
  /// In ko, this message translates to:
  /// **'연락처 수정'**
  String get contactEdit;

  /// No description provided for @contactAdded.
  ///
  /// In ko, this message translates to:
  /// **'{name} 연락처를 추가했습니다.'**
  String contactAdded(Object name);

  /// No description provided for @contactUpdated.
  ///
  /// In ko, this message translates to:
  /// **'{name} 연락처를 수정했습니다.'**
  String contactUpdated(Object name);

  /// No description provided for @contactName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get contactName;

  /// No description provided for @contactNameHint.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get contactNameHint;

  /// No description provided for @contactPhone.
  ///
  /// In ko, this message translates to:
  /// **'전화번호'**
  String get contactPhone;

  /// No description provided for @contactSeoulTooLong.
  ///
  /// In ko, this message translates to:
  /// **'서울(02) 번호는 10자리까지입니다. 번호를 확인해 주세요.'**
  String get contactSeoulTooLong;

  /// No description provided for @contactRelation.
  ///
  /// In ko, this message translates to:
  /// **'관계'**
  String get contactRelation;

  /// No description provided for @regionLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'지역 정보를 불러오지 못했습니다'**
  String get regionLoadFailed;

  /// No description provided for @regionCodeNotFound.
  ///
  /// In ko, this message translates to:
  /// **'선택한 지역의 재난문자 수신지역 코드를 찾지 못했습니다.'**
  String get regionCodeNotFound;

  /// No description provided for @regionSearchTitle.
  ///
  /// In ko, this message translates to:
  /// **'관심지역을 설정해주세요'**
  String get regionSearchTitle;

  /// No description provided for @regionSearchSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'재난 알림을 받을 지역을 선택하세요'**
  String get regionSearchSubtitle;

  /// No description provided for @regionSelected.
  ///
  /// In ko, this message translates to:
  /// **'{region}(으)로 선택됨'**
  String regionSelected(Object region);

  /// No description provided for @regionSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'지역을 입력하세요'**
  String get regionSearchHint;

  /// No description provided for @regionNoChildren.
  ///
  /// In ko, this message translates to:
  /// **'하위 지역이 없습니다'**
  String get regionNoChildren;

  /// No description provided for @regionNoResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다'**
  String get regionNoResults;

  /// No description provided for @regionListTitle.
  ///
  /// In ko, this message translates to:
  /// **'관심지역을 관리하세요'**
  String get regionListTitle;

  /// No description provided for @regionListSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'재난 알림을 받을 지역을 추가하거나 삭제하세요'**
  String get regionListSubtitle;

  /// No description provided for @regionListEmpty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 관심지역이 없습니다'**
  String get regionListEmpty;

  /// No description provided for @regionMigrationFailed.
  ///
  /// In ko, this message translates to:
  /// **'{region}\n자동 전환하지 못했습니다. 삭제 후 다시 추가해주세요'**
  String regionMigrationFailed(Object region);

  /// No description provided for @regionPrimary.
  ///
  /// In ko, this message translates to:
  /// **'대표'**
  String get regionPrimary;

  /// No description provided for @regionAdd.
  ///
  /// In ko, this message translates to:
  /// **'관심지역 추가'**
  String get regionAdd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
