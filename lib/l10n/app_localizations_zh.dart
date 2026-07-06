// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '量形';

  @override
  String get brandMark => 'CONTOUR';

  @override
  String get tagline => '两张照片，认识你的身形';

  @override
  String get taglineSub => 'AI 量体 · 21 项定制尺寸';

  @override
  String get loginAccount => '账号登录';

  @override
  String get loginGuest => '游客进入';

  @override
  String get loginDemo => '体验模式';

  @override
  String get loginDemoHint => '无需账号，离线走通完整流程';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get loginTitle => '欢迎来到量形';

  @override
  String get loginSubtitle => '为你的裁缝，留下精确的你';

  @override
  String get mustAgreePrivacy => '请先阅读并同意隐私政策';

  @override
  String get privacyAgreePrefix => '已阅读并同意';

  @override
  String get privacyPolicyLink => '《隐私政策》';

  @override
  String get loginMissingCredentials => '请输入用户名和密码';

  @override
  String get signingIn => '正在登录…';

  @override
  String get homeStart => '开始量体';

  @override
  String get homeStartSub => '正面 · 侧面 · 约 2 分钟';

  @override
  String get homeRecords => '量体记录';

  @override
  String homeRecordsCount(int count) {
    return '$count 条';
  }

  @override
  String get homeSettings => '设置';

  @override
  String get homeHeroBust => '胸围';

  @override
  String get homeHeroWaist => '腰围';

  @override
  String get homeHeroHip => '臀围';

  @override
  String get subjectTitle => '被测人';

  @override
  String get subjectWho => '这次为谁量体？';

  @override
  String get subjectName => '姓名';

  @override
  String get subjectNameHint => '如：王小明';

  @override
  String get subjectContact => '手机或邮箱';

  @override
  String get subjectContactHint => '用于关联你的定制订单';

  @override
  String get subjectGender => '性别';

  @override
  String get genderMale => '男';

  @override
  String get genderFemale => '女';

  @override
  String get subjectFit => '上装贴合度';

  @override
  String get fitTight => '贴身';

  @override
  String get fitLoose => '宽松';

  @override
  String get subjectFitHint => '穿宽松上衣时，围度置信区间会更宽';

  @override
  String get subjectHeight => '身高';

  @override
  String get subjectWeight => '体重';

  @override
  String get unitMetric => '厘米 · 公斤';

  @override
  String get unitImperial => '英尺 · 磅';

  @override
  String get errNameRequired => '请输入姓名';

  @override
  String get errContactRequired => '请输入手机或邮箱';

  @override
  String get errHeightRange => '身高需在 120–220 cm 之间';

  @override
  String get errWeightRange => '体重需在 30–200 kg 之间';

  @override
  String get subjectContinue => '下一步 · 拍摄';

  @override
  String get briefingTitle => '拍摄要领';

  @override
  String get briefingIntro => '好照片决定尺寸精度，请让被测人：';

  @override
  String get briefTip1 => '穿贴身衣物，避免宽松外套与裙装';

  @override
  String get briefTip2 => '全身入镜，别裁掉头顶和脚';

  @override
  String get briefTip3 => '自然站立，双臂微微张开成 A 字';

  @override
  String get briefTip4 => '手机竖直放稳，镜头约与腰同高';

  @override
  String get briefTip5 => '光线充足，背景尽量简洁';

  @override
  String get briefingAuto => '手机放稳调平后会自动倒数拍摄，双手离机也能完成';

  @override
  String get briefingStart => '开始拍摄';

  @override
  String get captureFront => '正面';

  @override
  String get captureSide => '侧面';

  @override
  String get captureStepFront => '第 1 张 · 正面';

  @override
  String get captureStepSide => '第 2 张 · 侧面';

  @override
  String get captureLevelHint => '微调手机，让气泡进入圆环';

  @override
  String get captureHoldSteady => '保持稳定…';

  @override
  String captureCountdown(int n) {
    return '$n';
  }

  @override
  String get captureRetake => '重拍';

  @override
  String get captureUse => '就用这张';

  @override
  String get captureSwitchCamera => '切换镜头';

  @override
  String get captureNoCameraTitle => '此设备没有可用相机';

  @override
  String get captureNoCameraBody => '可以使用内置示例照片继续体验完整流程。';

  @override
  String get captureUseSample => '使用示例照片';

  @override
  String get capturePermissionTitle => '需要相机权限';

  @override
  String get capturePermissionBody => '拍摄量体照片需要访问相机。可在系统设置中开启。';

  @override
  String get captureOpenSettings => '前往设置';

  @override
  String get ttsFrontPrompt => '请拍摄正面。走到三米外，面向镜头，双臂微微张开。';

  @override
  String get ttsSidePrompt => '很好。请右转九十度，拍摄侧面。';

  @override
  String get ttsLevelPrompt => '手机未摆正，请调整手机让气泡进入圆环。';

  @override
  String get ttsCaptured => '已拍摄。';

  @override
  String get measuringTitle => '正在测量';

  @override
  String get measuringPhase1 => '正在核对照片…';

  @override
  String get measuringPhase2 => '重建身体轮廓…';

  @override
  String get measuringPhase3 => '推算 21 项尺寸…';

  @override
  String get measuringFailed => '测量失败';

  @override
  String get measuringRetry => '重试';

  @override
  String get resultsTitle => '量体结果';

  @override
  String get resultsGroupGirth => '围度';

  @override
  String get resultsGroupLength => '长度';

  @override
  String get resultsGroupWidth => '宽与高';

  @override
  String get resultsEditHint => '点击任意尺寸可微调（±10 cm）';

  @override
  String resultsRangeBadge(Object lo, Object hi) {
    return '可调范围 $lo – $hi';
  }

  @override
  String resultsInvalid(int count) {
    return '有 $count 项超出可信范围，请检查标红的尺寸';
  }

  @override
  String get resultsSave => '保存尺寸';

  @override
  String get saving => '正在保存…';

  @override
  String get successTitle => '已保存';

  @override
  String get successSub => '把这张量体码出示给你的裁缝';

  @override
  String get successShare => '分享量体码';

  @override
  String get successDone => '完成';

  @override
  String get successNewMeasure => '再量一位';

  @override
  String get recordsTitle => '量体记录';

  @override
  String get recordsEmpty => '还没有量体记录';

  @override
  String get recordsEmptySub => '完成第一次量体后，记录会出现在这里';

  @override
  String get recordsDelete => '删除';

  @override
  String get recordsDeleteConfirm => '删除这条记录？';

  @override
  String get recordsDeleteBody => '删除后无法恢复。';

  @override
  String get recordDetailTitle => '记录详情';

  @override
  String get recordMetaGender => '性别';

  @override
  String get recordMetaContact => '联系方式';

  @override
  String get recordMetaTime => '时间';

  @override
  String get recordShowQr => '量体码';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionGeneral => '通用';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsTheme => '外观';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsSectionPrivacy => '隐私与权限';

  @override
  String get settingsPermissions => '权限管理';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsSectionAccount => '账号';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsSignOutConfirm => '确定退出登录？';

  @override
  String get settingsCancelAccount => '注销账号';

  @override
  String get settingsCancelConfirm => '注销将删除账号数据';

  @override
  String get settingsCancelBody => '此操作不可恢复，确定继续？';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsDemoBadge => '当前为体验模式';

  @override
  String get permCamera => '相机';

  @override
  String get permCameraWhy => '拍摄量体照片';

  @override
  String get permPhotos => '相册';

  @override
  String get permPhotosWhy => '保存或选择照片';

  @override
  String get permGranted => '已允许';

  @override
  String get permDenied => '未允许';

  @override
  String get permOpenSystem => '在系统设置中修改';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String get privacyAccept => '同意并继续';

  @override
  String get privacyDecline => '不同意';

  @override
  String get privacyBuiltin =>
      '我们深知身体数据的敏感性。量形收集的照片与身高体重仅用于计算你的定制尺寸；照片在测量完成后即被处理，不会用于其他目的。你可以随时在设置中删除记录或注销账号。继续使用代表你同意以上条款。';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确定';

  @override
  String get commonOk => '好';

  @override
  String get commonBack => '返回';

  @override
  String get commonRetry => '重试';

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
