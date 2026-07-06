// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Contour';

  @override
  String get brandMark => 'CONTOUR';

  @override
  String get tagline => 'Two photos. Your true shape.';

  @override
  String get taglineSub => 'AI measuring · 21 tailoring sizes';

  @override
  String get loginAccount => 'Sign in';

  @override
  String get loginGuest => 'Continue as guest';

  @override
  String get loginDemo => 'Try the demo';

  @override
  String get loginDemoHint => 'No account needed — full flow, offline';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginTitle => 'Welcome to Contour';

  @override
  String get loginSubtitle => 'Leave your tailor a precise you';

  @override
  String get mustAgreePrivacy =>
      'Please read and accept the privacy policy first';

  @override
  String get privacyAgreePrefix => 'I have read and accept the';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get loginMissingCredentials => 'Enter your username and password';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get homeStart => 'Begin measuring';

  @override
  String get homeStartSub => 'Front · side · about 2 minutes';

  @override
  String get homeRecords => 'Records';

  @override
  String homeRecordsCount(int count) {
    return '$count';
  }

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeHeroBust => 'Bust';

  @override
  String get homeHeroWaist => 'Waist';

  @override
  String get homeHeroHip => 'Hip';

  @override
  String get subjectTitle => 'Subject';

  @override
  String get subjectWho => 'Who are we measuring?';

  @override
  String get subjectName => 'Name';

  @override
  String get subjectNameHint => 'e.g. Alex Wang';

  @override
  String get subjectContact => 'Phone or email';

  @override
  String get subjectContactHint => 'Links the sizes to your order';

  @override
  String get subjectGender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get subjectFit => 'Top fit';

  @override
  String get fitTight => 'Fitted';

  @override
  String get fitLoose => 'Loose';

  @override
  String get subjectFitHint => 'Loose tops widen girth confidence intervals';

  @override
  String get subjectHeight => 'Height';

  @override
  String get subjectWeight => 'Weight';

  @override
  String get unitMetric => 'cm · kg';

  @override
  String get unitImperial => 'ft · lb';

  @override
  String get errNameRequired => 'Please enter a name';

  @override
  String get errContactRequired => 'Please enter a phone or email';

  @override
  String get errHeightRange => 'Height must be 120–220 cm';

  @override
  String get errWeightRange => 'Weight must be 30–200 kg';

  @override
  String get subjectContinue => 'Next · Capture';

  @override
  String get briefingTitle => 'Before you shoot';

  @override
  String get briefingIntro =>
      'Good photos make precise sizes. The subject should:';

  @override
  String get briefTip1 => 'Wear fitted clothes — no loose coats or skirts';

  @override
  String get briefTip2 => 'Fit the whole body in frame, head to feet';

  @override
  String get briefTip3 => 'Stand naturally, arms slightly out in an A-shape';

  @override
  String get briefTip4 =>
      'Keep the phone upright and steady, near waist height';

  @override
  String get briefTip5 => 'Good light, clean background';

  @override
  String get briefingAuto =>
      'Once the phone is level it counts down and shoots itself — fully hands-free';

  @override
  String get briefingStart => 'Start capture';

  @override
  String get captureFront => 'Front';

  @override
  String get captureSide => 'Side';

  @override
  String get captureStepFront => 'Shot 1 · Front';

  @override
  String get captureStepSide => 'Shot 2 · Side';

  @override
  String get captureLevelHint =>
      'Tilt the phone until the bubble sits in the ring';

  @override
  String get captureHoldSteady => 'Hold steady…';

  @override
  String captureCountdown(int n) {
    return '$n';
  }

  @override
  String get captureRetake => 'Retake';

  @override
  String get captureUse => 'Use this shot';

  @override
  String get captureSwitchCamera => 'Flip camera';

  @override
  String get captureNoCameraTitle => 'No camera on this device';

  @override
  String get captureNoCameraBody =>
      'You can continue the full flow with built-in sample photos.';

  @override
  String get captureUseSample => 'Use sample photos';

  @override
  String get capturePermissionTitle => 'Camera access needed';

  @override
  String get capturePermissionBody =>
      'Contour needs the camera to take measuring photos. Enable it in Settings.';

  @override
  String get captureOpenSettings => 'Open Settings';

  @override
  String get ttsFrontPrompt =>
      'Front view. Step three meters back, face the camera, arms slightly out.';

  @override
  String get ttsSidePrompt =>
      'Great. Now turn ninety degrees to your right for the side view.';

  @override
  String get ttsLevelPrompt =>
      'The phone is tilted. Adjust it until the bubble sits in the ring.';

  @override
  String get ttsCaptured => 'Captured.';

  @override
  String get measuringTitle => 'Measuring';

  @override
  String get measuringPhase1 => 'Checking your photos…';

  @override
  String get measuringPhase2 => 'Reconstructing your contour…';

  @override
  String get measuringPhase3 => 'Deriving 21 sizes…';

  @override
  String get measuringFailed => 'Measuring failed';

  @override
  String get measuringRetry => 'Try again';

  @override
  String get resultsTitle => 'Your sizes';

  @override
  String get resultsGroupGirth => 'Girths';

  @override
  String get resultsGroupLength => 'Lengths';

  @override
  String get resultsGroupWidth => 'Widths & heights';

  @override
  String get resultsEditHint => 'Tap any size to fine-tune (±10 cm)';

  @override
  String resultsRangeBadge(Object lo, Object hi) {
    return 'Adjustable $lo – $hi';
  }

  @override
  String resultsInvalid(int count) {
    return '$count sizes are outside the trusted range — check the red rows';
  }

  @override
  String get resultsSave => 'Save sizes';

  @override
  String get saving => 'Saving…';

  @override
  String get successTitle => 'Saved';

  @override
  String get successSub => 'Show this code to your tailor';

  @override
  String get successShare => 'Share code';

  @override
  String get successDone => 'Done';

  @override
  String get successNewMeasure => 'Measure another';

  @override
  String get recordsTitle => 'Records';

  @override
  String get recordsEmpty => 'No records yet';

  @override
  String get recordsEmptySub =>
      'Finish your first measuring session and it will appear here';

  @override
  String get recordsDelete => 'Delete';

  @override
  String get recordsDeleteConfirm => 'Delete this record?';

  @override
  String get recordsDeleteBody => 'This cannot be undone.';

  @override
  String get recordDetailTitle => 'Record';

  @override
  String get recordMetaGender => 'Gender';

  @override
  String get recordMetaContact => 'Contact';

  @override
  String get recordMetaTime => 'Time';

  @override
  String get recordShowQr => 'Measuring code';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSectionPrivacy => 'Privacy & permissions';

  @override
  String get settingsPermissions => 'Permissions';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirm => 'Sign out of this account?';

  @override
  String get settingsCancelAccount => 'Delete account';

  @override
  String get settingsCancelConfirm => 'Deleting removes account data';

  @override
  String get settingsCancelBody => 'This cannot be undone. Continue?';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsDemoBadge => 'Demo mode';

  @override
  String get permCamera => 'Camera';

  @override
  String get permCameraWhy => 'Take measuring photos';

  @override
  String get permPhotos => 'Photos';

  @override
  String get permPhotosWhy => 'Save or pick photos';

  @override
  String get permGranted => 'Allowed';

  @override
  String get permDenied => 'Not allowed';

  @override
  String get permOpenSystem => 'Change in system Settings';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyAccept => 'Accept & continue';

  @override
  String get privacyDecline => 'Decline';

  @override
  String get privacyBuiltin =>
      'Body data is sensitive and we treat it that way. Contour uses your photos, height and weight solely to compute your tailoring sizes; photos are processed for measurement and nothing else. You can delete records or your account at any time in Settings. Continuing means you accept these terms.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonOk => 'OK';

  @override
  String get commonBack => 'Back';

  @override
  String get commonRetry => 'Retry';

  @override
  String get unitCm => 'cm';

  @override
  String get unitIn => 'in';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get unitFt => 'ft';
}
