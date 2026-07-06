import 'package:flutter/foundation.dart';

import '../api/measure_api.dart';
import '../models/models.dart';
import 'session.dart';

/// Paged record list + total count, shared by home badge and records screen.
class RecordsStore extends ChangeNotifier {
  RecordsStore(this._session) {
    _session.addListener(_onSession);
  }

  final Session _session;
  static const pageSize = 20;

  final List<MeasureRecord> records = [];
  int total = 0;
  bool loading = false;
  bool refreshing = false;
  String? error;
  int _page = 1;

  bool get hasMore => records.length < total;

  void _onSession() {
    if (!_session.isAuthenticated) {
      records.clear();
      total = 0;
      _page = 1;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!_session.isAuthenticated) return;
    refreshing = true;
    error = null;
    notifyListeners();
    try {
      final page = await _session.api.records(pageNum: 1, pageSize: pageSize);
      records
        ..clear()
        ..addAll(page.records);
      total = page.total;
      _page = 1;
    } on ApiFailure catch (e) {
      error = e.message;
    } catch (e) {
      error = '$e';
    } finally {
      refreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (loading || !hasMore) return;
    loading = true;
    notifyListeners();
    try {
      final next =
          await _session.api.records(pageNum: _page + 1, pageSize: pageSize);
      _page += 1;
      records.addAll(next.records);
      total = next.total;
    } on ApiFailure catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    await _session.api.deleteRecord(id);
    records.removeWhere((r) => r.id == id);
    total = (total - 1).clamp(0, 1 << 31);
    notifyListeners();
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    super.dispose();
  }
}
