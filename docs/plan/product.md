# Contour（量形）— 产品规划

> Planner 产物 ｜ 2026-07-06 ｜ 替代 emeasure-flutter 的全新重写
> 目标品质线：Apple Design Award 级（工艺、深度、原创性、一致性）

## 1. 产品定位

**Contour（中文名：量形）** — 面向定制服装顾客与门店的「拍照量体」应用。
两张照片（正面/侧面）+ 身高体重，AI 返回 21 项人体尺寸，可精修、保存、分享给裁缝。

设计概念：**数字裁缝工坊（Digital Atelier）**。整个 app 的视觉 DNA 来自裁缝工具：
卷尺的刻度线、划粉的暖白、藏蓝呢料、黄铜配件。度量是这款 app 的灵魂，因此
「刻度」作为贯穿性视觉母题：身高体重选择器是真实滑动的卷尺，步骤进度是刻度带，
水平仪是刻度环，结果加载是卷尺展开动画，数字全部等宽轻字重大号呈现。

## 2. 旧 app 功能清单（必须保持的能力）

| # | 旧功能 | 新方案（保持/重塑） |
|---|---|---|
| 1 | 账号登录 + 游客登录（设备ID） | 保持；新增**体验模式**（本地 demo 后端，离线可完整走通全流程） |
| 2 | 隐私政策启动弹窗（远程拉取+重试+默认回退） | 保持（首启一次、拒绝退出、设置页可查看） |
| 3 | 被测人信息：姓名/联系方式/性别/身高/体重/单位切换(cm-kg ↔ ft in-lb)/上装合身度(fit/loose) | 重塑：三幕式流程第一幕「是谁」；卷尺拾取器输入身高体重 |
| 4 | 采集标准校验（身高120-220cm、体重30-200kg、必填项） | 保持（CaptureStandard 平移，纯函数可单测） |
| 5 | 原生引导拍摄：正/侧两步、姿势蒙版、加速度计水平球、TTS 语音提示、语音口令、前后摄切换、重拍、教学视频 | 重塑为纯 Flutter：相机预览+刻度环水平仪+人形轮廓蒙版+TTS 提示；语音口令→**调平自动快门**（3-2-1 语音倒数，双手离机也能拍）；教学视频→内置图解要领页；模拟器/无相机→示例照片回退 |
| 6 | 快门时刻元数据：capture_metadata（俯仰/重力/内参/景深统计）+ device_info | 保持（sensors_plus 重力快照 + 相机参数；JSON 结构与 MeasurePlatform 契约一致） |
| 7 | 上传测量：POST newGetCustomerPart（21 项部位值） | 保持协议；结果页重塑（分区分组+数字滚动动画） |
| 8 | 结果精修：每项 ±10cm/±4in 区间校验、单位感知显示、保存 newUpdateCustomerSize | 保持；行内步进器+区间提示，超界即时标红 |
| 9 | 记录列表：分页/下拉刷新/上拉加载、删除、详情弹层、二维码分享 | 保持；弹层→独立详情页，删除加确认 |
| 10 | 设置：语言(中/英)、权限管理器（相机/麦克风/相册状态+跳系统设置）、隐私政策、退出登录、注销账号、版本信息 | 保持；新增**深浅色主题**跟随/手动 |
| 11 | i18n 中/英（217 键） | 保持（gen-l10n ARB 方案） |
| 12 | 401 自动登出、错误信封统一提示 | 保持（dio 拦截器） |

刻意替换说明：旧「语音口令拍照」（SFSpeech 识别"拍照/确认/重拍"）以**调平自动快门 +
语音倒数**替代——同样满足"无人协助自拍"场景，且无常开麦克风的隐私负担与误识别问题。
麦克风权限因此从必需降为不需要。

## 3. 用户故事

1. 顾客第一次打开 app，看到简洁的开始页，点「开始量体」，按引导填好性别身高体重，
   把手机靠在桌上，走到 3 米外按语音提示站好，手机调平后自动 3-2-1 拍下正面，
   转身 90° 再拍侧面，回到手机前看到 21 项尺寸，确认后保存并把二维码发给裁缝。
2. 门店店员用账号登录，连续为多位顾客量体，在记录列表按姓名查看历史，删除误拍。
3. 审核人员/新用户无账号，选「体验模式」，全流程走通（示例照片+本地模拟测量），
   了解产品后再注册。
4. 英文用户切换语言，全部界面与语音提示变为英文；夜间使用切换深色主题。

## 4. 信息架构与流程（三幕式）

```
启动 → (隐私弹窗) → 登录/游客/体验 → 首页(Home)
首页 ── 开始量体 ──> 幕1 被测人(Subject)：性别·身高·体重·合身度·姓名·联系方式
                    幕2 拍摄(Capture)：要领页 → 正面(调平+轮廓+TTS+自动快门) → 确认 → 侧面 → 确认
                    幕3 结果(Results)：测量动画 → 21项分组结果 → 行内精修 → 保存 → 成功页(二维码分享)
首页 ── 量体记录 ──> 记录列表 → 记录详情(尺寸表+照片+二维码分享+删除)
首页 ── 设置 ──> 语言/主题/权限管理/隐私政策/退出/注销/版本
```

## 5. 数据模型（与旧协议兼容）

- `Subject`：name, contact, gender(male|female), heightCm, weightKg,
  displayUnit(metric|imperial), topFit(fit|loose)
- `Part`：partId, partName(zh), partEnName, valueCm(可编辑), lower/upper(±10cm)
- `MeasureSession`：subject + frontJpeg + sideJpeg + captureMetadata + deviceInfo
- `MeasureResult`：customerId, pzUserDetailId, measureId, date, parts[21]
- `MeasureRecord`：id, customerName, tel, gender, qrCode, operationTime, imgF/imgS
- `CaptureMetadata`：per-view {pitch_deg, gravity[x,y,z], intrinsics{fx,fy,cx,cy}?,
  depth{median_m,p10,p90}?, resolution, ts} — 与 MeasurePlatform capture_metadata 契约一致

## 6. API 抽象

`MeasureApi` 接口 × 2 实现：
- `RemoteMeasureApi`（dio，旧 customerwx 协议原样）：
  - POST `/app/pzuserdetail/checkUser` → openid（账号或 deviceId）
  - POST `/login?username=<openid>&srdzflag=WX` → token
  - GET  `/app/customerwx/newCustomerWxList?pageSize=&pageNum=` → {total, data[]}
  - POST `/app/customerwx/newGetCustomerPart` → TempDetails(partValues)
  - POST `/app/customerwx/newUpdateCustomerSize`
  - POST `/app/customerwx/customerWxDetail` (id)
  - DELETE `/app/customerwx?id=`
  - POST `/app/pzuserdetail/cancel`
  - GET  `/privacyPolicy?type=3`
- `DemoMeasureApi`（体验模式/评测用）：确定性本地夹具，21 项尺寸由身高体重的
  人体测量学比例生成（可信、可复测），记录持久化于本地，模拟网络延迟。

## 7. 设计系统（Atelier 语言）

- **色彩** Light：Ink `#171C30`（藏蓝呢）、Chalk `#FAF7F2`（划粉暖白，页面底）、
  Card `#FFFFFF`、Brass `#A8874F`（黄铜，主行动色）、Thread `#8B93A7`（辅助文字）、
  安全 `#3E7C5B` / 危险 `#B4443C`。Dark：底 `#101321`、卡 `#1A1F31`、文字 Chalk、Brass 提亮 `#C4A46B`。
- **字体**：系统（SF Pro / PingFang SC）；测量数字：w200-w300 大号 + tabularFigures；
  标题 w600；正文 w400。
- **母题**：`TickRuler` 刻度组件（10 细分 1 粗）用于：卷尺拾取器、步骤进度带、
  水平刻度环、结果页分隔、成功页装饰。
- **形制**：卡片圆角 20、控件圆角 14、hairline 0.5 描边 `#000×8%`；间距 4pt 网格。
- **动效**：标准 240ms easeOutCubic；页面转场 400ms 弹性；数字滚动 600ms；
  快门→测量环 hero 变形；刻度滑动带触感（HapticFeedback.selectionClick 每刻度）。
- **无障碍**：全部交互 44pt 起、Semantics 标签、对比度 ≥4.5:1、支持动态字体一档放大不破版。

## 8. 技术栈

Flutter 3.44 stable ／ Dart 3.12。依赖白名单（刻意精简）：
`provider`（状态）、`go_router`（路由）、`dio`（网络）、`camera`、`sensors_plus`、
`flutter_tts`、`permission_handler`、`shared_preferences`、`qr_flutter`、`share_plus`、
`package_info_plus`、`flutter_localizations` + gen-l10n。
不用 GetX（魔法太多）、不用 EasyLoading（自绘 HUD 更可控）。

## 9. 冲刺划分

| Sprint | 内容 | 验收要点 |
|---|---|---|
| S1 基础 | 脚手架、设计系统、i18n、路由、MeasureApi+Demo 实现、首页 | analyze 0 issue；test 绿；模拟器可启动到首页；中英切换 |
| S2 被测人 | Subject 表单、卷尺拾取器、单位换算、采集标准校验 | 换算/校验单测；拾取器交互真机验证 |
| S3 拍摄 | 相机、刻度环水平仪、轮廓蒙版、TTS、自动快门、元数据、模拟器回退 | 真机（模拟器）走通正/侧两步；metadata JSON 快照测试 |
| S4 结果与记录 | 测量动画、结果分组精修、保存、记录列表/详情/分享/删除 | demo 模式全流程 E2E；区间校验单测 |
| S5 账号与打磨 | 登录/隐私/权限/设置、深色、无障碍、动效、图标 | Evaluator 全维度评分 ≥ 阈值 |

## 10. 风险

- 模拟器无相机：内置示例照片回退（同时服务体验模式与评测）。
- 真实后端不可用/无测试账号：体验模式兜底；Remote 协议以旧 app 源码为准逐字段平移。
- flutter_tts 在模拟器的可用性：语音失败静默降级为纯视觉提示（不阻塞流程）。
