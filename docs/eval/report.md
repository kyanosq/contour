# Contour（量形）评测报告

- 日期：2026-07-06（第三轮「午夜工坊」暗色重塑后复评）
- 评测环境：iOS Simulator「Contour-Eval」(iPhone 17 Pro, iOS 26.5)，Flutter 3.44.4 / Dart 3.12.2
- 评测方式：真实交互取证 —— `flutter drive` 集成走查（真实引擎、真实手势、逐屏截图）+ 冷启动持久化验证 + 单元/widget 测试 + 旧协议逐端点对照

## 结论

26/26 验收条目全部通过（见 `feature_list.json`，每条含证据路径）。
静态检查零告警，45 个单元/widget 测试全绿，4 条集成走查全部通过，
驱动日志零 `warnIfMissed` 命中告警。按下方新评分标准，加权总分 **9.5/10**。

## 第三轮：午夜工坊（Midnight Atelier）暗色重塑（本轮新增）

针对「配色改用暗黑色系、原黄铜主题色不合适」的反馈，整轮换血配色系统：

- **主题色更换**：黄铜 `#C4A46B` → **Lumen 青蓝** `#35D0C4`（曜黑下提亮 `#4FE3D6`）。
  代码层 `brass* → accent*` 全量更名（tokens/组件/取景 chrome/表盘/水平环/进度带）。
- **全系暗色双变体**：两套外观均为暗色 —— **曜黑**（深邃默认，底 `#070A11`）与
  **石墨**（提亮炭灰，底 `#151924`）。外观切换功能保留（跟随系统/浅色/深色），
  「浅色」即石墨变体；环境光舞台、玻璃填充、描边、阴影全部按暗色重调。
- **可扫性修复**：二维码在暗色下反色不可扫 → 成功页/记录详情改为白色圆角底板 +
  深墨码点（`w14`/`w17`），扫码器友好。
- **测量表盘提亮**：刻度对比度上调、扫描弧加辉光垫层、中心点加光晕（`w11`）。
- **资源图更新**：重新生成 2 张与新配色同调的暗色影棚人台样照（炭黑亚麻人台 +
  钢制卷尺 + 石墨无缝背景 + 青蓝轮廓光），正面/侧面（`w09`/`a03`）。
- **文档同步**：`docs/plan/product.md` 设计语言与色板更新为午夜工坊体系。

## 评分标准（本轮重建）

对照 Apple Design Award 官方奖项维度重建，6 维加权，每维含可核验的具体判据；
判据不满足即扣分，证据一律指向 `eval/` 截图或驱动日志（可复跑）。

| 维度 | 权重 | 判据（摘要） |
| --- | --- | --- |
| 视觉与图形 Visual & Graphics | 25% | 全屏统一的设计语言与色板；层级/对比度经暗色校核；资产（插画/照片）与色系同调；跨页光场连续无跳变 |
| 交互 Interaction | 25% | 主路径 ≤3 步心智模型；表单错误内联+自动定位；全部点按命中真实区域（驱动日志零 miss）；键盘/滚动/返回无死角 |
| 愉悦与动效 Delight | 15% | 关键节点有恰当动效（入场/进度/成功）；触感反馈；动效服务信息而非炫技 |
| 包容性 Inclusivity | 15% | 中英即时切换；1.3× 字号零溢出；Semantics 完整；≥44pt 触达；反色场景（二维码）可用 |
| 工艺与稳定 Craft & Reliability | 15% | analyze 零告警；单测全绿；4 条集成走查通过；冷启动持久化；无相机/无网降级路径完整 |
| 创新 Innovation | 5% | 离线可评测后端；采集元数据契约对齐训练平台；脚本重力自动快门评测链 |

### 本轮评分

| 维度 | 分 | 证据 |
| --- | --- | --- |
| 视觉与图形 | 9.5 | 曜黑/石墨双暗色贯穿 23 屏（w01–w23、m05–m09）；Lumen 单一强调色系统；暗色影棚样照与 UI 同调（w09）；环境光舞台跨路由连续 |
| 交互 | 9.5 | 走查日志零 `warnIfMissed`；校验自动滚动（w04）；毛玻璃底栏可滚穿（w12）；水平仪+倒数双手离机主路径（a01–a03） |
| 愉悦与动效 | 9.5 | 人台描线入场（w03）、卷尺逐格触感、表盘辉光扫描（w11）、勾章光环+数字滚动（w14）、玻璃对话框缩放淡入（m04） |
| 包容性 | 9.5 | 中英即时切换（w21/w22）；1.3× 零溢出（单测）；slider Semantics；44pt 底线；二维码白板反色修复（w14/w17） |
| 工艺与稳定 | 9.5 | analyze 0 告警；45/45 单测；4/4 走查；冷重启持久化（p01）；无相机回退（w08）、断网重试（测量失败态） |
| 创新 | 9.0 | 体验模式=离线人体测量学后端；元数据契约与训练平台对齐；SIM_GRAVITY 脚本重力链 |

**加权总分 = 9.5×0.25 + 9.5×0.25 + 9.5×0.15 + 9.5×0.15 + 9.5×0.15 + 9.0×0.05 ≈ 9.48 → 9.5/10**

## 回归检查（本轮全部复跑）

| 检查 | 结果 |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 45/45 通过 |
| `walk_full_test`（主旅程 23 屏） | 通过，截图 `eval/w01–w23` |
| `walk_autoshutter_test`（脚本重力→自动快门） | 通过，截图 `eval/a01–a03` |
| `walk_misc_test`（协议勾选/设置角落/主题切换/分享面板） | 通过，截图 `eval/m01–m10` |
| 冷重启持久化（语言/主题/会话/记录） | 通过，截图 `eval/p01_relaunch_home.png` |

## 主旅程证据链（demo 通道）

首启隐私弹窗 w01 → 登录三通道 w02 → 首页人台 hero w03 →
表单校验（双错误内联+自动滚动）w04 → 英制换算 5'9"/143lb w05 → 填毕 w06 →
拍摄要领五条 w07 → 无相机回退卡片+正面轮廓 w08 → 预览/重拍 w09 → 侧面轮廓 w10 →
测量表盘动画 w11 → 结果 21 项三分组 w12/w12b → 超界标红+保存禁用 w13 →
成功页二维码（白板）w14 → 首页徽标「1 条」w15 → 记录列表 w16 → 详情 w17 →
确认删除→空态 w18 → 设置 w19 → 深色（曜黑）w20 → English w21/w22 → 退出登录 w23。

自动快门链：倾斜（气泡出环+提示）a01 → 调平（环亮+保持稳定）a02 →
无点击自动出片进入预览 a03。

角落链：未勾选协议被阻 m01 → 设置内政策页（离线内置文本）m02 →
权限实时状态页 m03 → 注销二次确认 m04 → 曜黑表单/要领/测量/结果/成功 m05–m09 →
系统分享面板实拉起 m10。

## 历史轮次备忘

- 第二轮（Liquid Glass）：建立玻璃系统（`design/glass.dart`：AmbientBackdrop /
  GlassPanel / GlassChip / showGlassDialog），相机 chrome 毛玻璃化，修复 GlassPanel
  InkWell 命中遮挡（5 处 miss → 0）、提示胶囊撑满、卷尺边缘遮罩穿帮。
- 第一轮（功能成型）：修复 13 项缺陷，含协议契约偏差 ×3（单位字典码、
  `customerWxDetail` GET+query、save 回传 `imgF/imgS`）、share_plus iPad 锚点、
  1.3× 溢出、`bool.fromEnvironment` 判定等（详单见 git 历史中的上一版报告）。

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
