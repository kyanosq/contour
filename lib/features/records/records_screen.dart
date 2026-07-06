import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/records_store.dart';
import '../../design/glass.dart';
import '../../design/tick_ruler.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'record_detail_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >
          _scroll.position.maxScrollExtent - 240) {
        context.read<RecordsStore>().loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<RecordsStore>();
      if (store.records.isEmpty) store.refresh();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(MeasureRecord r) async {
    final l = AppLocalizations.of(context);
    final ok = await showGlassDialog<bool>(
      context: context,
      title: l.recordsDeleteConfirm,
      content: Text(l.recordsDeleteBody),
      actions: [
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
        ),
        Builder(
          builder: (context) => TextButton(
            style: TextButton.styleFrom(foregroundColor: Atelier.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.recordsDelete),
          ),
        ),
      ],
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = context.watch<RecordsStore>();

    return Scaffold(
      appBar: AppBar(title: Text(l.recordsTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: store.refresh,
          color: brassOf(context),
          child: store.records.isEmpty && !store.refreshing
              ? _EmptyState(l: l)
              : ListView.separated(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(Sp.x6),
                  itemCount: store.records.length + (store.loading ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: Sp.x3),
                  itemBuilder: (context, i) {
                    if (i >= store.records.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(Sp.x4),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final r = store.records[i];
                    return Dismissible(
                      key: ValueKey('record-${r.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(r),
                      onDismissed: (_) =>
                          context.read<RecordsStore>().delete(r.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: Sp.x6),
                        decoration: BoxDecoration(
                          color: Atelier.danger.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(Corners.card),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Atelier.danger),
                      ),
                      child: _RecordCard(record: r),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final MeasureRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final female = record.gender == '2';

    return ContourCard(
      padding: const EdgeInsets.all(Sp.x4),
      onTap: () => context.push(
        '/records/${record.id}',
        extra: MeasureRecordSeed.of(record),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brassOf(context).withValues(alpha: 0.12),
            ),
            child: Icon(
              female ? Icons.female_rounded : Icons.male_rounded,
              size: 22,
              color: brassOf(context),
            ),
          ),
          const SizedBox(width: Sp.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.customerName?.isNotEmpty == true
                      ? record.customerName!
                      : '—',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (record.tel?.isNotEmpty == true) record.tel!,
                    if (record.operationTime?.isNotEmpty == true)
                      record.operationTime!,
                  ].join('  ·  '),
                  style: TextStyle(
                    fontSize: 12,
                    fontFeatures: Numerals.features,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.22),
        Icon(Icons.straighten_rounded,
            size: 44, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
        const SizedBox(height: Sp.x5),
        Text(
          l.recordsEmpty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Sp.x2),
        Text(
          l.recordsEmptySub,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Sp.x8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Sp.x12),
          child: TickRuler(height: 10),
        ),
      ],
    );
  }
}
