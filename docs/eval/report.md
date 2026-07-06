# Contour（量形）评测报告

- 日期：2026-07-06
- 评测环境：iOS Simulator「Contour-Eval」(iPhone 17 Pro, iOS 26.5)，Flutter 3.44.4 / Dart 3.12.2
- 评测方式：真实交互取证 —— `flutter drive` 集成走查（真实引擎、真实手势、逐屏截图）+ 冷启动持久化验证 + 单元/widget 测试 + 旧协议逐端点对照

## 结论

26/26 验收条目全部通过（见 `feature_list.json`，每条含证据路径）。
静态检查零告警，45 个单元/widget 测试全绿，4 条集成走查全部通过。

| 检查 | 结果 |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 45/45 通过 |
| `walk_full_test`（主旅程 23 屏） | 通过，截图 `eval/w01–w23` |
| `walk_autoshutter_test`（脚本重力→自动快门） | 通过，截图 `eval/a01–a03` |
| `walk_misc_test`（协议勾选/设置角落/深色/分享面板） | 通过，截图 `eval/m01–m10` |
| 冷重启持久化（语言/主题/会话/记录） | 通过，截图 `eval/p01_relaunch_home.png` |

## 主旅程证据链（demo 通道）

首启隐私弹窗 w01 → 登录三通道 w02 → 首页人台 hero w03 →
表单校验（双错误内联+自动滚动）w04 → 英制换算 5'9"/143lb w05 → 填毕 w06 →
拍摄要领五条 w07 → 无相机回退卡片+正面轮廓 w08 → 预览/重拍 w09 → 侧面轮廓 w10 →
测量表盘动画 w11 → 结果 21 项三分组 w12/w12b → 超界标红+保存禁用 w13 →
成功页二维码 w14 → 首页徽标「1 条」w15 → 记录列表 w16 → 详情 w17 →
确认删除→空态 w18 → 设置 w19 → 深色 w20 → English w21/w22 → 退出登录 w23。

自动快门链：倾斜（气泡出环+提示）a01 → 调平（环亮+保持稳定）a02 →
无点击自动出片进入预览 a03。

角落链：未勾选协议被阻 m01 → 设置内政策页（离线内置文本）m02 →
权限实时状态页 m03 → 注销二次确认 m04 → 深色表单/要领/测量/结果/成功 m05–m09 →
系统分享面板实拉起 m10。

## 评分（自评，Apple Design Award 维度）

| 维度 | 分 | 说明 |
| --- | --- | --- |
| Delight & Fun | 8.5/10 | 卷尺拾取器逐格触感、人台 hero、表盘测量动画、黄铜勾章成功页 |
| Interaction | 9/10 | 水平仪+语音倒数把「双手离机自拍」做成了主路径；校验自动滚动到问题区 |
| Visual & Graphics | 9/10 | Ink/Chalk/Brass 三色体系贯穿 23 屏，深色模式全覆盖无白闪 |
| Inclusivity | 8/10 | 中英即时切换、slider Semantics、1.3 倍字号零溢出、44pt 交互底线 |
| Innovation | 8/10 | 体验模式=离线可评测后端；采集元数据契约与训练平台对齐 |

## 过程中发现并修复的缺陷（Evaluator → Generator 回修）

1. `Ink` 令牌类与 Material `Ink` 冲突（编译错）→ 更名 `Atelier`。
2. `CupertinoPageTransitionsBuilder` 在 3.44 移出 material 导出 → 显式 cupertino 导入。
3. TapePicker 刻度在轮投影下垂直溢出 2px → OverflowBox 自然布局。
4. WorkingVeil 隐形时仍在播 spinner，导致 pumpAndSettle 永不停 → 可见才挂载。
5. 表单校验错误在屏外（懒加载列表找不到）→ 校验失败自动滚动到问题区。
6. `bool.fromEnvironment` 不认 `=1`（RESET/SIM_GRAVITY 均未生效）→ 改字符串判定。
7. 预览时回退卡片仍然可见 → review 态隐藏。
8. **协议契约偏差 ×3**（对照旧 app 逐字段核出）：单位字典码应为 10266/10265/10261/10260；
   `customerWxDetail` 应为 GET+query；save 需回传测量响应中的 `imgF/imgS` 以保持照片关联。
9. share_plus 未传 `sharePositionOrigin`，iPad 上必崩 → 以按钮为锚点。
10. SectionLabel 在 1.3 倍字号下横向溢出 → Flexible+ellipsis。

## 已知边界（不阻塞验收）

- 账号密码/游客登录的**真实后端**联通未验（无测试凭据）；协议层已按旧 app 逐字段对照并有拦截器单测兜底。
- 真机相机/TTS 发声/触感的体感质量需要真机抽查（模拟器只能证明调用路径不崩溃）。
- 记录列表分页需 >10 条数据才能触发加载更多（逻辑有单测，UI 未在走查中触发）。

## 复跑指引

```bash
cd contour
flutter analyze && flutter test
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/walk_full_test.dart --dart-define=RESET=1 -d <sim>
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/walk_autoshutter_test.dart \
  --dart-define=RESET=1 --dart-define=SIM_GRAVITY=1 -d <sim>
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/walk_misc_test.dart --dart-define=RESET=1 \
  --keep-app-running -d <sim>
```
