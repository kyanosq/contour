import 'package:contour/design/tape_picker.dart';
import 'package:contour/design/tick_ruler.dart';
import 'package:contour/features/measure/part_grouping.dart';
import 'package:contour/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('TickRuler', () {
    testWidgets('renders and repaints with highlight', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 300,
        child: TickRuler(height: 14, highlightFraction: 0.5,
            highlightColor: Colors.amber),
      )));
      expect(find.byType(TickRuler), findsOneWidget);
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 300,
        child: TickRuler(height: 14, highlightFraction: 0.9,
            highlightColor: Colors.amber),
      )));
      expect(tester.takeException(), isNull);
    });
  });

  group('TapePicker', () {
    testWidgets('drag changes value along the scale', (tester) async {
      double value = 172;
      await tester.pumpWidget(_wrap(StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 340,
          child: TapePicker(
            min: 120,
            max: 220,
            step: 1,
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      )));
      // drag left → value increases (tape moves under fixed needle)
      await tester.drag(find.byType(TapePicker), const Offset(-120, 0));
      await tester.pumpAndSettle();
      expect(value, greaterThan(172));
      final after = value;
      await tester.drag(find.byType(TapePicker), const Offset(240, 0));
      await tester.pumpAndSettle();
      expect(value, lessThan(after));
    });

    testWidgets('snaps to whole steps', (tester) async {
      double value = 65;
      await tester.pumpWidget(_wrap(StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 340,
          child: TapePicker(
            min: 30,
            max: 200,
            step: 0.5,
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      )));
      await tester.drag(find.byType(TapePicker), const Offset(-77, 0));
      await tester.pumpAndSettle();
      expect((value * 2).round() / 2, value); // multiple of 0.5
    });

    testWidgets('clamps at scale boundaries', (tester) async {
      double value = 121;
      await tester.pumpWidget(_wrap(StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 340,
          child: TapePicker(
            min: 120,
            max: 220,
            step: 1,
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      )));
      await tester.drag(find.byType(TapePicker), const Offset(900, 0));
      await tester.pumpAndSettle();
      expect(value, greaterThanOrEqualTo(120));
      expect(value, lessThanOrEqualTo(220));
    });

    testWidgets('external value change recenters the tape', (tester) async {
      final values = <double>[];
      await tester.pumpWidget(_wrap(SizedBox(
        width: 340,
        child: TapePicker(
          min: 120, max: 220, step: 1, value: 172,
          onChanged: values.add,
        ),
      )));
      await tester.pumpWidget(_wrap(SizedBox(
        width: 340,
        child: TapePicker(
          min: 120, max: 220, step: 1, value: 190,
          onChanged: values.add,
        ),
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('part grouping', () {
    test('canonical 21 fields split 9/8/4', () {
      final parts = [
        for (var i = 0; i < 21; i++)
          Part(
            partId: i + 1,
            nameZh: const [
              '胸围', '通裆', '中腰', '领围', '总肩宽', '右腕围', '左腕围', '臀围',
              '腰围', '上臂围', '前肩宽', '左袖长', '左裤长', '右袖长', '右裤长',
              '后衣长', '前腰高', '前腰节长', '后腰高', '后腰节长', '腿根围',
            ][i],
            nameEn: '',
            value: 50,
          ),
      ];
      final groups = groupParts(parts);
      expect(groups, hasLength(3));
      expect(groups[0].kind, PartKind.girth);
      expect(groups[0].parts, hasLength(9));
      expect(groups[1].kind, PartKind.length);
      expect(groups[1].parts, hasLength(8));
      expect(groups[2].kind, PartKind.width);
      expect(groups[2].parts, hasLength(4));
      // 中腰 counts as girth (围), 前腰高/后腰高 as width&height (高)
      expect(groups[0].parts.map((p) => p.nameZh), contains('中腰'));
      expect(groups[2].parts.map((p) => p.nameZh), contains('前腰高'));
    });
  });
}
