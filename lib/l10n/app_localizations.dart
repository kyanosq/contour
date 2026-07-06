import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'量形'**
  String get appName;

  /// No description provided for @brandMark.
  ///
  /// In zh, this message translates to:
  /// **'CONTOUR'**
  String get brandMark;

  /// No description provided for @tagline.
  ///
  /// In zh, this message translates to:
  /// **'两张照片，认识你的身形'**
  String get tagline;

  /// No description provided for @taglineSub.
  ///
  /// In zh, this message translates to:
  /// **'AI 量体 · 21 项定制尺寸'**
  String get taglineSub;

  /// No description provided for @loginAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号登录'**
  String get loginAccount;

  /// No description provided for @loginGuest.
  ///
  /// In zh, this message translates to:
  /// **'游客进入'**
  String get loginGuest;

  /// No description provided for @loginDemo.
  ///
  /// In zh, this message translates to:
  /// **'体验模式'**
  String get loginDemo;

  /// No description provided for @loginDemoHint.
  ///
  /// In zh, this message translates to:
  /// **'无需账号，离线走通完整流程'**
  String get loginDemoHint;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @loginTitle.
  ///
  /// In zh, this message translates to:
  /// **'欢迎来到量形'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'为你的裁缝，留下精确的你'**
  String get loginSubtitle;

  /// No description provided for @mustAgreePrivacy.
  ///
  /// In zh, this message translates to:
  /// **'请先阅读并同意隐私政策'**
  String get mustAgreePrivacy;

  /// No description provided for @privacyAgreePrefix.
  ///
  /// In zh, this message translates to:
  /// **'已阅读并同意'**
  String get privacyAgreePrefix;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In zh, this message translates to:
  /// **'《隐私政策》'**
  String get privacyPolicyLink;

  /// No description provided for @loginMissingCredentials.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名和密码'**
  String get loginMissingCredentials;

  /// No description provided for @signingIn.
  ///
  /// In zh, this message translates to:
  /// **'正在登录…'**
  String get signingIn;

  /// No description provided for @homeStart.
  ///
  /// In zh, this message translates to:
  /// **'开始量体'**
  String get homeStart;

  /// No description provided for @homeStartSub.
  ///
  /// In zh, this message translates to:
  /// **'正面 · 侧面 · 约 2 分钟'**
  String get homeStartSub;

  /// No description provided for @homeRecords.
  ///
  /// In zh, this message translates to:
  /// **'量体记录'**
  String get homeRecords;

  /// No description provided for @homeRecordsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String homeRecordsCount(int count);

  /// No description provided for @homeSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get homeSettings;

  /// No description provided for @homeHeroBust.
  ///
  /// In zh, this message translates to:
  /// **'胸围'**
  String get homeHeroBust;

  /// No description provided for @homeHeroWaist.
  ///
  /// In zh, this message translates to:
  /// **'腰围'**
  String get homeHeroWaist;

  /// No description provided for @homeHeroHip.
  ///
  /// In zh, this message translates to:
  /// **'臀围'**
  String get homeHeroHip;

  /// No description provided for @subjectTitle.
  ///
  /// In zh, this message translates to:
  /// **'被测人'**
  String get subjectTitle;

  /// No description provided for @subjectWho.
  ///
  /// In zh, this message translates to:
  /// **'这次为谁量体？'**
  String get subjectWho;

  /// No description provided for @subjectName.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get subjectName;

  /// No description provided for @subjectNameHint.
  ///
  /// In zh, this message translates to:
  /// **'如：王小明'**
  String get subjectNameHint;

  /// No description provided for @subjectContact.
  ///
  /// In zh, this message translates to:
  /// **'手机或邮箱'**
  String get subjectContact;

  /// No description provided for @subjectContactHint.
  ///
  /// In zh, this message translates to:
  /// **'用于关联你的定制订单'**
  String get subjectContactHint;

  /// No description provided for @subjectGender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get subjectGender;

  /// No description provided for @genderMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get genderFemale;

  /// No description provided for @subjectFit.
  ///
  /// In zh, this message translates to:
  /// **'上装贴合度'**
  String get subjectFit;

  /// No description provided for @fitTight.
  ///
  /// In zh, this message translates to:
  /// **'贴身'**
  String get fitTight;

  /// No description provided for @fitLoose.
  ///
  /// In zh, this message translates to:
  /// **'宽松'**
  String get fitLoose;

  /// No description provided for @subjectFitHint.
  ///
  /// In zh, this message translates to:
  /// **'穿宽松上衣时，围度置信区间会更宽'**
  String get subjectFitHint;

  /// No description provided for @subjectHeight.
  ///
  /// In zh, this message translates to:
  /// **'身高'**
  String get subjectHeight;

  /// No description provided for @subjectWeight.
  ///
  /// In zh, this message translates to:
  /// **'体重'**
  String get subjectWeight;

  /// No description provided for @unitMetric.
  ///
  /// In zh, this message translates to:
  /// **'厘米 · 公斤'**
  String get unitMetric;

  /// No description provided for @unitImperial.
  ///
  /// In zh, this message translates to:
  /// **'英尺 · 磅'**
  String get unitImperial;

  /// No description provided for @errNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入姓名'**
  String get errNameRequired;

  /// No description provided for @errContactRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机或邮箱'**
  String get errContactRequired;

  /// No description provided for @errHeightRange.
  ///
  /// In zh, this message translates to:
  /// **'身高需在 120–220 cm 之间'**
  String get errHeightRange;

  /// No description provided for @errWeightRange.
  ///
  /// In zh, this message translates to:
  /// **'体重需在 30–200 kg 之间'**
  String get errWeightRange;

  /// No description provided for @subjectContinue.
  ///
  /// In zh, this message translates to:
  /// **'下一步 · 拍摄'**
  String get subjectContinue;

  /// No description provided for @briefingTitle.
  ///
  /// In zh, this message translates to:
  /// **'拍摄要领'**
  String get briefingTitle;

  /// No description provided for @briefingIntro.
  ///
  /// In zh, this message translates to:
  /// **'好照片决定尺寸精度，请让被测人：'**
  String get briefingIntro;

  /// No description provided for @briefTip1.
  ///
  /// In zh, this message translates to:
  /// **'穿贴身衣物，避免宽松外套与裙装'**
  String get briefTip1;

  /// No description provided for @briefTip2.
  ///
  /// In zh, this message translates to:
  /// **'全身入镜，别裁掉头顶和脚'**
  String get briefTip2;

  /// No description provided for @briefTip3.
  ///
  /// In zh, this message translates to:
  /// **'自然站立，双臂微微张开成 A 字'**
  String get briefTip3;

  /// No description provided for @briefTip4.
  ///
  /// In zh, this message translates to:
  /// **'手机竖直放稳，镜头约与腰同高'**
  String get briefTip4;

  /// No description provided for @briefTip5.
  ///
  /// In zh, this message translates to:
  /// **'光线充足，背景尽量简洁'**
  String get briefTip5;

  /// No description provided for @briefingAuto.
  ///
  /// In zh, this message translates to:
  /// **'手机放稳调平后会自动倒数拍摄，双手离机也能完成'**
  String get briefingAuto;

  /// No description provided for @briefingStart.
  ///
  /// In zh, this message translates to:
  /// **'开始拍摄'**
  String get briefingStart;

  /// No description provided for @captureFront.
  ///
  /// In zh, this message translates to:
  /// **'正面'**
  String get captureFront;

  /// No description provided for @captureSide.
  ///
  /// In zh, this message translates to:
  /// **'侧面'**
  String get captureSide;

  /// No description provided for @captureStepFront.
  ///
  /// In zh, this message translates to:
  /// **'第 1 张 · 正面'**
  String get captureStepFront;

  /// No description provided for @captureStepSide.
  ///
  /// In zh, this message translates to:
  /// **'第 2 张 · 侧面'**
  String get captureStepSide;

  /// No description provided for @captureLevelHint.
  ///
  /// In zh, this message translates to:
  /// **'微调手机，让气泡进入圆环'**
  String get captureLevelHint;

  /// No description provided for @captureHoldSteady.
  ///
  /// In zh, this message translates to:
  /// **'保持稳定…'**
  String get captureHoldSteady;

  /// No description provided for @captureCountdown.
  ///
  /// In zh, this message translates to:
  /// **'{n}'**
  String captureCountdown(int n);

  /// No description provided for @captureRetake.
  ///
  /// In zh, this message translates to:
  /// **'重拍'**
  String get captureRetake;

  /// No description provided for @captureUse.
  ///
  /// In zh, this message translates to:
  /// **'就用这张'**
  String get captureUse;

  /// No description provided for @captureSwitchCamera.
  ///
  /// In zh, this message translates to:
  /// **'切换镜头'**
  String get captureSwitchCamera;

  /// No description provided for @captureNoCameraTitle.
  ///
  /// In zh, this message translates to:
  /// **'此设备没有可用相机'**
  String get captureNoCameraTitle;

  /// No description provided for @captureNoCameraBody.
  ///
  /// In zh, this message translates to:
  /// **'可以使用内置示例照片继续体验完整流程。'**
  String get captureNoCameraBody;

  /// No description provided for @captureUseSample.
  ///
  /// In zh, this message translates to:
  /// **'使用示例照片'**
  String get captureUseSample;

  /// No description provided for @capturePermissionTitle.
  ///
  /// In zh, this message translates to:
  /// **'需要相机权限'**
  String get capturePermissionTitle;

  /// No description provided for @capturePermissionBody.
  ///
  /// In zh, this message translates to:
  /// **'拍摄量体照片需要访问相机。可在系统设置中开启。'**
  String get capturePermissionBody;

  /// No description provided for @captureOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'前往设置'**
  String get captureOpenSettings;

  /// No description provided for @ttsFrontPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请拍摄正面。走到三米外，面向镜头，双臂微微张开。'**
  String get ttsFrontPrompt;

  /// No description provided for @ttsSidePrompt.
  ///
  /// In zh, this message translates to:
  /// **'很好。请右转九十度，拍摄侧面。'**
  String get ttsSidePrompt;

  /// No description provided for @ttsLevelPrompt.
  ///
  /// In zh, this message translates to:
  /// **'手机未摆正，请调整手机让气泡进入圆环。'**
  String get ttsLevelPrompt;

  /// No description provided for @ttsCaptured.
  ///
  /// In zh, this message translates to:
  /// **'已拍摄。'**
  String get ttsCaptured;

  /// No description provided for @measuringTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在测量'**
  String get measuringTitle;

  /// No description provided for @measuringPhase1.
  ///
  /// In zh, this message translates to:
  /// **'正在核对照片…'**
  String get measuringPhase1;

  /// No description provided for @measuringPhase2.
  ///
  /// In zh, this message translates to:
  /// **'重建身体轮廓…'**
  String get measuringPhase2;

  /// No description provided for @measuringPhase3.
  ///
  /// In zh, this message translates to:
  /// **'推算 21 项尺寸…'**
  String get measuringPhase3;

  /// No description provided for @measuringFailed.
  ///
  /// In zh, this message translates to:
  /// **'测量失败'**
  String get measuringFailed;

  /// No description provided for @measuringRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get measuringRetry;

  /// No description provided for @resultsTitle.
  ///
  /// In zh, this message translates to:
  /// **'量体结果'**
  String get resultsTitle;

  /// No description provided for @resultsGroupGirth.
  ///
  /// In zh, this message translates to:
  /// **'围度'**
  String get resultsGroupGirth;

  /// No description provided for @resultsGroupLength.
  ///
  /// In zh, this message translates to:
  /// **'长度'**
  String get resultsGroupLength;

  /// No description provided for @resultsGroupWidth.
  ///
  /// In zh, this message translates to:
  /// **'宽与高'**
  String get resultsGroupWidth;

  /// No description provided for @resultsEditHint.
  ///
  /// In zh, this message translates to:
  /// **'点击任意尺寸可微调（±10 cm）'**
  String get resultsEditHint;

  /// No description provided for @resultsRangeBadge.
  ///
  /// In zh, this message translates to:
  /// **'可调范围 {lo} – {hi}'**
  String resultsRangeBadge(Object lo, Object hi);

  /// No description provided for @resultsInvalid.
  ///
  /// In zh, this message translates to:
  /// **'有 {count} 项超出可信范围，请检查标红的尺寸'**
  String resultsInvalid(int count);

  /// No description provided for @resultsSave.
  ///
  /// In zh, this message translates to:
  /// **'保存尺寸'**
  String get resultsSave;

  /// No description provided for @saving.
  ///
  /// In zh, this message translates to:
  /// **'正在保存…'**
  String get saving;

  /// No description provided for @successTitle.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get successTitle;

  /// No description provided for @successSub.
  ///
  /// In zh, this message translates to:
  /// **'把这张量体码出示给你的裁缝'**
  String get successSub;

  /// No description provided for @successShare.
  ///
  /// In zh, this message translates to:
  /// **'分享量体码'**
  String get successShare;

  /// No description provided for @successDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get successDone;

  /// No description provided for @successNewMeasure.
  ///
  /// In zh, this message translates to:
  /// **'再量一位'**
  String get successNewMeasure;

  /// No description provided for @recordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'量体记录'**
  String get recordsTitle;

  /// No description provided for @recordsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有量体记录'**
  String get recordsEmpty;

  /// No description provided for @recordsEmptySub.
  ///
  /// In zh, this message translates to:
  /// **'完成第一次量体后，记录会出现在这里'**
  String get recordsEmptySub;

  /// No description provided for @recordsDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get recordsDelete;

  /// No description provided for @recordsDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除这条记录？'**
  String get recordsDeleteConfirm;

  /// No description provided for @recordsDeleteBody.
  ///
  /// In zh, this message translates to:
  /// **'删除后无法恢复。'**
  String get recordsDeleteBody;

  /// No description provided for @recordDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录详情'**
  String get recordDetailTitle;

  /// No description provided for @recordMetaGender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get recordMetaGender;

  /// No description provided for @recordMetaContact.
  ///
  /// In zh, this message translates to:
  /// **'联系方式'**
  String get recordMetaContact;

  /// No description provided for @recordMetaTime.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get recordMetaTime;

  /// No description provided for @recordShowQr.
  ///
  /// In zh, this message translates to:
  /// **'量体码'**
  String get recordShowQr;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsTheme.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settingsThemeDark;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私与权限'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsPermissions.
  ///
  /// In zh, this message translates to:
  /// **'权限管理'**
  String get settingsPermissions;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSignOut.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定退出登录？'**
  String get settingsSignOutConfirm;

  /// No description provided for @settingsCancelAccount.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get settingsCancelAccount;

  /// No description provided for @settingsCancelConfirm.
  ///
  /// In zh, this message translates to:
  /// **'注销将删除账号数据'**
  String get settingsCancelConfirm;

  /// No description provided for @settingsCancelBody.
  ///
  /// In zh, this message translates to:
  /// **'此操作不可恢复，确定继续？'**
  String get settingsCancelBody;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get settingsVersion;

  /// No description provided for @settingsDemoBadge.
  ///
  /// In zh, this message translates to:
  /// **'当前为体验模式'**
  String get settingsDemoBadge;

  /// No description provided for @permCamera.
  ///
  /// In zh, this message translates to:
  /// **'相机'**
  String get permCamera;

  /// No description provided for @permCameraWhy.
  ///
  /// In zh, this message translates to:
  /// **'拍摄量体照片'**
  String get permCameraWhy;

  /// No description provided for @permPhotos.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get permPhotos;

  /// No description provided for @permPhotosWhy.
  ///
  /// In zh, this message translates to:
  /// **'保存或选择照片'**
  String get permPhotosWhy;

  /// No description provided for @permGranted.
  ///
  /// In zh, this message translates to:
  /// **'已允许'**
  String get permGranted;

  /// No description provided for @permDenied.
  ///
  /// In zh, this message translates to:
  /// **'未允许'**
  String get permDenied;

  /// No description provided for @permOpenSystem.
  ///
  /// In zh, this message translates to:
  /// **'在系统设置中修改'**
  String get permOpenSystem;

  /// No description provided for @privacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyTitle;

  /// No description provided for @privacyAccept.
  ///
  /// In zh, this message translates to:
  /// **'同意并继续'**
  String get privacyAccept;

  /// No description provided for @privacyDecline.
  ///
  /// In zh, this message translates to:
  /// **'不同意'**
  String get privacyDecline;

  /// No description provided for @privacyBuiltin.
  ///
  /// In zh, this message translates to:
  /// **'我们深知身体数据的敏感性。量形收集的照片与身高体重仅用于计算你的定制尺寸；照片在测量完成后即被处理，不会用于其他目的。你可以随时在设置中删除记录或注销账号。继续使用代表你同意以上条款。'**
  String get privacyBuiltin;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonConfirm;

  /// No description provided for @commonOk.
  ///
  /// In zh, this message translates to:
  /// **'好'**
  String get commonOk;

  /// No description provided for @commonBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get commonBack;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @unitCm.
  ///
  /// In zh, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @unitIn.
  ///
  /// In zh, this message translates to:
  /// **'in'**
  String get unitIn;

  /// No description provided for @unitKg.
  ///
  /// In zh, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitLb.
  ///
  /// In zh, this message translates to:
  /// **'lb'**
  String get unitLb;

  /// No description provided for @unitFt.
  ///
  /// In zh, this message translates to:
  /// **'ft'**
  String get unitFt;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
