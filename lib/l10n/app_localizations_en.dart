// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Try again';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Save changes';

  @override
  String get save => 'Save';

  @override
  String get select => 'Select';

  @override
  String get all => 'All';

  @override
  String get etc => 'Other';

  @override
  String deleteTooltip(Object name) {
    return 'Delete $name';
  }

  @override
  String editTooltip(Object name) {
    return 'Edit $name';
  }

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navLocation => 'Location';

  @override
  String get navGuide => 'Guide';

  @override
  String get navShare => 'Share';

  @override
  String get navSettings => 'Settings';

  @override
  String get notificationSyncFailed =>
      'Couldn\'t apply your notification settings to the server. Please try again once you\'re connected.';

  @override
  String get severityCritical => 'Critical';

  @override
  String get severityUrgent => 'Urgent';

  @override
  String get severitySafety => 'Safety notice';

  @override
  String get categoryHeatWave => 'Heat wave';

  @override
  String get categoryEarthquake => 'Earthquake';

  @override
  String get categoryTyphoon => 'Typhoon';

  @override
  String get categoryHeavyRain => 'Heavy rain';

  @override
  String get relationFamily => 'Family';

  @override
  String get relationFriend => 'Friend';

  @override
  String get relationAcquaintance => 'Acquaintance';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours hr';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String get infoTitle => 'Disaster info';

  @override
  String get infoLoadFailed =>
      'Couldn\'t load disaster info.\nPlease check your network connection.';

  @override
  String get infoEmpty => 'No info in this category.';

  @override
  String get disasterDetailTitle => 'Alert details';

  @override
  String get disasterShowGuide => 'View safety guide';

  @override
  String get disasterShowShelters => 'View shelters';

  @override
  String get disasterAreaUnavailable =>
      'Can\'t show the location of the affected area.';

  @override
  String guideTitle(Object category) {
    return '$category safety guide';
  }

  @override
  String get guideShowNearbyShelters => 'View nearby shelters';

  @override
  String guideStepTitle(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'earthquake1': 'Take cover under a table',
      'earthquake2': 'Turn off power and gas once the shaking stops',
      'earthquake3': 'Use the stairs to get outside',
      'earthquake4': 'Move to an open area',
      'earthquake5': 'Follow official information',
      'heavyRain1': 'Check weather updates often',
      'heavyRain2': 'Stay away from rivers and low-lying areas',
      'heavyRain3': 'Get out of underground spaces right away',
      'heavyRain4': 'Don\'t cross flooded roads',
      'heavyRain5': 'Evacuate immediately when advised',
      'typhoon1': 'Stay indoors',
      'typhoon2': 'Secure your windows',
      'typhoon3': 'Put away things the wind could blow away',
      'typhoon4': 'Stay away from the coast and construction sites',
      'typhoon5': 'Prepare for power outages',
      'heatWave1': 'Drink water often',
      'heatWave2': 'Avoid outdoor activities at midday',
      'heatWave3': 'Stay somewhere cool',
      'heatWave4': 'Rest right away if you feel dizzy',
      'heatWave5': 'Check on the people around you',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String guideStepDescription(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'earthquake1':
          'While the ground shakes, get under a table, hold on to its legs, and protect your head.',
      'earthquake2':
          'Shut off the gas valve and electricity, and open the door to secure an exit.',
      'earthquake3':
          'Don\'t take the elevator, and keep away from buildings and walls as you move.',
      'earthquake4':
          'Protect your head with a bag or similar, and move to an open area such as a sports field or park.',
      'earthquake5':
          'Check emergency alerts and the radio for information, and don\'t believe unconfirmed rumors.',
      'heavyRain1':
          'Check emergency alerts, TV, and radio for heavy rain warnings and evacuation notices.',
      'heavyRain2':
          'Leave riverside paths, valleys, and breakwaters immediately.',
      'heavyRain3':
          'Once water starts entering an underground parking lot or semi-basement, doors may not open, so go above ground right away.',
      'heavyRain4':
          'Even if the current looks weak, don\'t walk or drive through it.',
      'heavyRain5': 'Turn off power and gas, and go to the nearest shelter.',
      'typhoon1':
          'During a typhoon warning, stay indoors and keep checking weather updates.',
      'typhoon2':
          'Fasten window frames, and stay away from glass that could break.',
      'typhoon3':
          'Bring in or tie down things that could blow away, such as flower pots and signs.',
      'typhoon4':
          'You could be swept away by high waves or hurt by falling objects.',
      'typhoon5': 'Have a flashlight, a power bank, and drinking water ready.',
      'heatWave1': 'Drink water regularly, even if you don\'t feel thirsty.',
      'heatWave2':
          'Cut back on going out and outdoor work during the hottest hours, 2 to 5 PM.',
      'heatWave3':
          'Wear loose, light-colored clothes, and use a nearby cooling center.',
      'heatWave4':
          'If you have a headache, dizziness, or nausea, rest somewhere cool, and call 119 if symptoms continue.',
      'heatWave5':
          'Check on neighbors who are vulnerable to heat, such as older adults and children.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get shelterLoadFailed =>
      'Couldn\'t load shelter info.\nPlease check your network connection.';

  @override
  String get locationTimeout =>
      'Couldn\'t determine your current location. Please try again shortly.';

  @override
  String get locationServiceDisabled =>
      'Location services are off. Please turn them on in Settings.';

  @override
  String get locationPermissionDenied =>
      'Location permission is needed to find nearby shelters.';

  @override
  String get locationPermissionDeniedForever =>
      'Please allow location permission in Settings.';

  @override
  String get nearbyShelters => 'Nearby shelters';

  @override
  String get disasterAreaShelters => 'Shelters in the affected area';

  @override
  String get shelterOutsideArea =>
      'You\'re outside the affected area, so shelters inside the area are shown.';

  @override
  String shelterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shelters',
      one: '1 shelter',
    );
    return '$_temp0';
  }

  @override
  String get routeLoadFailed => 'Couldn\'t load the route.';

  @override
  String get routeHeadToShelter => 'Head toward the shelter';

  @override
  String routeFarWarning(Object distance) {
    return 'This is a long way to walk ($distance). Tap again to start directions.';
  }

  @override
  String get routeStart => 'Start directions';

  @override
  String get routeStartConfirm => 'Tap again to start directions';

  @override
  String routeDistanceTo(Object destination, Object distance) {
    return '$distance to $destination';
  }

  @override
  String get routeEnd => 'End directions';

  @override
  String routeSummary(Object distance, Object duration) {
    return '$duration walk · $distance left';
  }

  @override
  String routeSummaryEstimated(Object distance, Object duration) {
    return 'About $distance in a straight line · $duration walk (estimate)';
  }

  @override
  String get shareTitle => 'Share safety status';

  @override
  String get shareDefaultMessage => 'I\'m safe right now. Don\'t worry.';

  @override
  String get sharePreviewNotice =>
      'This is a preview only. No message is actually sent.';

  @override
  String get shareButton => 'I\'m safe (share)';

  @override
  String get shareContactsTitle => 'Safety contacts';

  @override
  String get shareContactsEmpty => 'No safety contacts yet';

  @override
  String get shareContactsEmptyCaption =>
      'Add contacts so you\'re ready to share your safety status.';

  @override
  String get shareMessageTitle => 'Auto-generated message';

  @override
  String get shareEditMessage => 'Edit message';

  @override
  String get shareMessageLabel => 'Safety status message';

  @override
  String get shareMessageEmpty => 'Please enter a message to share.';

  @override
  String get sharePreviewDone => 'Preview complete';

  @override
  String get sharePreviewNotSent => 'No message was actually sent.';

  @override
  String sharePreviewTargets(Object names) {
    return 'Preview recipients: $names';
  }

  @override
  String shareTodayAt(Object time) {
    return 'Today $time';
  }

  @override
  String get shareNoData => 'No sharing info.';

  @override
  String get shareBackHome => 'Back to home';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDisasterAlert => 'Emergency alerts';

  @override
  String get settingsSafetyAlert => 'Safety notices';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsRegions => 'Areas of interest';

  @override
  String get settingsContacts => 'Safety contacts';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsNeedsSetup => 'Not set';

  @override
  String settingsRegionSummary(String region, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more',
      one: '1 more',
    );
    return '$region and $_temp0';
  }

  @override
  String settingsContactCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeNormal => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get textSizeSample => 'This is a sample alert';

  @override
  String get contactSearchHint => 'Search contacts';

  @override
  String get contactsEmpty => 'No contacts yet';

  @override
  String get contactAdd => 'Add contact';

  @override
  String get contactEdit => 'Edit contact';

  @override
  String contactAdded(Object name) {
    return 'Added $name.';
  }

  @override
  String contactUpdated(Object name) {
    return 'Updated $name.';
  }

  @override
  String get contactName => 'Name';

  @override
  String get contactNameHint => 'Enter a name';

  @override
  String get contactPhone => 'Phone number';

  @override
  String get contactSeoulTooLong =>
      'Seoul (02) numbers have up to 10 digits. Please check the number.';

  @override
  String get contactRelation => 'Relationship';

  @override
  String get regionLoadFailed => 'Couldn\'t load area info';

  @override
  String get regionCodeNotFound =>
      'Couldn\'t find the alert area code for the selected area.';

  @override
  String get regionSearchTitle => 'Set an area of interest';

  @override
  String get regionSearchSubtitle =>
      'Choose an area to get disaster alerts for';

  @override
  String regionSelected(Object region) {
    return '$region selected';
  }

  @override
  String get regionSearchHint => 'Search areas';

  @override
  String get regionNoChildren => 'No sub-areas';

  @override
  String get regionNoResults => 'No results';

  @override
  String get regionListTitle => 'Manage your areas of interest';

  @override
  String get regionListSubtitle =>
      'Add or remove areas to get disaster alerts for';

  @override
  String get regionListEmpty => 'No areas of interest yet';

  @override
  String regionMigrationFailed(Object region) {
    return '$region\nCouldn\'t switch over automatically. Please delete it and add it again.';
  }

  @override
  String get regionPrimary => 'Primary';

  @override
  String get regionAdd => 'Add area';
}
