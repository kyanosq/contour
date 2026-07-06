# Sprint Contracts（Generator ↔ Evaluator 约定）

评测环境：iPhone 17 Pro 模拟器（iOS 26）+ `flutter analyze` + `flutter test`。
真实交互取证：模拟器安装运行，simctl 截图，关键流程逐步截图存 `eval/`。
统一硬门槛（每个冲刺）：`flutter analyze` 0 issues；`flutter test` 全绿；
app 在模拟器可启动且本冲刺声明的路径可实际走通；截图作为证据落盘。

## S1 合同（基础）
交付：脚手架(contour)、design tokens + TickRuler、gen-l10n(zh/en)、go_router、
MeasureApi 接口 + DemoMeasureApi、登录占位（体验模式可进）、首页。
验收：F01 全部步骤；F02 步骤1-2；F03 步骤1；F04 步骤2（单测）；F05 步骤1、3。
说明：F02 深色对比、F03 切换持久化、F04 端到端、F05 徽标一致性延后到 S4/S5 评。

## S2 合同（被测人）
交付：Subject 表单页、TapePicker 卷尺、单位换算、CaptureStandard 校验。
验收：F06 全部；F07 全部；F08 全部。

## S3 合同（拍摄）
交付：要领页、拍摄页（相机/轮廓蒙版/刻度环水平仪/TTS/自动快门/预览确认）、
capture_metadata + device_info、无相机回退。
验收：F09-F14 全部（模拟器上以模拟重力流 + 示例照片验证）。

## S4 合同（结果与记录）
交付：测量页、结果分组精修、保存、成功页(QR/分享)、记录列表/详情/删除。
验收：F15-F20 全部 + F04 步骤1、3 + F05 步骤2。

## S5 合同（账号与打磨）
交付：登录三通道、隐私弹窗、设置页、权限管理、深色、无障碍、RemoteApi 平移。
验收：F21-F26 全部 + F02/F03 余项 + 最终六维评分。

## Evaluator 评分维度与阈值（终评）
1. 产品深度 ≥8/10（无 stub、无死按钮）
2. 功能可用性 ≥8/10（不看说明能完成量体→保存→分享）
3. 设计质量 ≥8/10（Atelier 语言贯穿、深浅色一致）
4. 原创性 ≥7/10（卷尺母题等刻意决策可辨识，无模板感）
5. 工艺 ≥8/10（层级/间距/对比度/动效帧率）
6. 代码质量 ≥8/10（analyze 0、结构清晰、测试覆盖核心逻辑）
任一维不达标 → 整轮 FAIL，出具 critique（文件:行号）。
