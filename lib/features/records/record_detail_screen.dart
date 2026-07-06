import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../api/measure_api.dart';
import '../../app/records_store.dart';
import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../measure/part_grouping.dart';

/// List-row data carried into the detail page (the detail endpoint returns
/// only part values; row meta comes from the list).
class MeasureRecordSeed {
  MeasureRecordSeed({
    this.name,
    this.tel,
    this.gender,
    this.time,
    this.qrCode,
  });

  final String? name;
  final String? tel;
  final String? gender;
  final String? time;
  final String? qrCode;

  static MeasureRecordSeed of(MeasureRecord r) => MeasureRecordSeed(
        name: r.customerName,
        tel: r.tel,
        gender: r.gender,
        time: r.operationTime,
        qrCode: r.qrCode,
      );
}

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key, required this.recordId, this.seed});

  final int recordId;
  final MeasureRecordSeed? seed;

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  MeasureResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final r =
          await context.read<Session>().api.recordDetail(widget.recordId);
      if (mounted) setState(() => _result = r);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.card)),
        title: Text(l.recordsDeleteConfirm),
        content: Text(l.recordsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Atelier.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.recordsDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<RecordsStore>().delete(widget.recordId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showToast(context, '$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final seed = widget.seed;
    final zh = Localizations.localeOf(context).languageCode == 'zh';

    return Scaffold(
      appBar: AppBar(
        title: Text(l.recordDetailTitle),
        actions: [
          IconButton(
            onPressed: _delete,
            tooltip: l.recordsDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!,
                        style:
                            TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: Sp.x4),
                    ThreadButton(label: l.commonRetry, onPressed: _load),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(Sp.x6),
                children: [
                  // meta card
                  ContourCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: brassOf(context)
                                    .withValues(alpha: 0.12),
                              ),
                              child: Icon(
                                seed?.gender == '2'
                                    ? Icons.female_rounded
                                    : Icons.male_rounded,
                                color: brassOf(context),
                              ),
                            ),
                            const SizedBox(width: Sp.x4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    seed?.name?.isNotEmpty == true
                                        ? seed!.name!
                                        : '—',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (seed?.tel?.isNotEmpty == true) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      seed!.tel!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFeatures: Numerals.features,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (seed?.time?.isNotEmpty == true) ...[
                          const SizedBox(height: Sp.x4),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 14,
                                  color: scheme.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                seed!.time!,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontFeatures: Numerals.features,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: Sp.x5),

                  // QR
                  if (seed?.qrCode?.isNotEmpty == true) ...[
                    ContourCard(
                      child: Column(
                        children: [
                          SectionLabel(l.recordShowQr.toUpperCase()),
                          const SizedBox(height: Sp.x4),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: QrImageView(
                              data: seed!.qrCode!,
                              version: QrVersions.auto,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: scheme.onSurface,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: scheme.onSurface,
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: Sp.x3),
                          Builder(
                            builder: (btnContext) => ThreadButton(
                              label: l.successShare,
                              onPressed: () {
                                // iPad popover anchor.
                                final box = btnContext.findRenderObject()
                                    as RenderBox?;
                                SharePlus.instance.share(ShareParams(
                                  text: seed.qrCode!,
                                  sharePositionOrigin: box == null
                                      ? null
                                      : box.localToGlobal(Offset.zero) &
                                          box.size,
                                ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.x5),
                  ],

                  // measurements
                  if (_result == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(Sp.x8),
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    for (final group in groupParts(_result!.parts)) ...[
                      SectionLabel(
                        switch (group.kind) {
                          PartKind.girth => l.resultsGroupGirth,
                          PartKind.length => l.resultsGroupLength,
                          PartKind.width => l.resultsGroupWidth,
                        }
                            .toUpperCase(),
                      ),
                      const SizedBox(height: Sp.x3),
                      ContourCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sp.x5, vertical: Sp.x2),
                        child: Column(
                          children: [
                            for (var i = 0;
                                i < group.parts.length;
                                i++) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Sp.x3),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        zh ||
                                                group.parts[i].nameEn
                                                    .isEmpty
                                            ? group.parts[i].nameZh
                                            : group.parts[i].nameEn,
                                        style:
                                            const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      group.parts[i].value
                                          .toStringAsFixed(1),
                                      style: Numerals.value(context,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l.unitCm,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (i < group.parts.length - 1)
                                Divider(color: scheme.outlineVariant),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: Sp.x5),
                    ],
                ],
              ),
      ),
    );
  }
}
