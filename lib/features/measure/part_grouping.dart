import '../../models/models.dart';

enum PartKind { girth, length, width }

class PartGroup {
  PartGroup(this.kind, this.parts);

  final PartKind kind;
  final List<Part> parts;
}

/// Classify a part by its Chinese (fallback English) name. Works for both the
/// demo fixture names and the production protocol names.
PartKind classifyPart(Part p) {
  final zh = p.nameZh;
  // 中腰 is a circumference despite lacking the 围 suffix.
  if (zh.contains('围') || zh == '中腰') return PartKind.girth;
  if (zh.contains('宽') || zh.contains('高')) return PartKind.width;
  if (zh.contains('长') || zh.contains('裆')) return PartKind.length;
  final en = p.nameEn.toLowerCase();
  if (en.contains('girth') ||
      en.contains('chest') ||
      en.contains('waist') && !en.contains('height') ||
      en.contains('hip') ||
      en.contains('neck') ||
      en.contains('wrist') ||
      en.contains('arm') ||
      en.contains('thigh')) {
    return PartKind.girth;
  }
  if (en.contains('width') || en.contains('height') || en.contains('shoulder')) {
    return PartKind.width;
  }
  return PartKind.length;
}

/// Stable grouping: girths, lengths, widths — dropping empty groups.
List<PartGroup> groupParts(List<Part> parts) {
  final girths = <Part>[];
  final lengths = <Part>[];
  final widths = <Part>[];
  for (final p in parts) {
    switch (classifyPart(p)) {
      case PartKind.girth:
        girths.add(p);
      case PartKind.length:
        lengths.add(p);
      case PartKind.width:
        widths.add(p);
    }
  }
  return [
    if (girths.isNotEmpty) PartGroup(PartKind.girth, girths),
    if (lengths.isNotEmpty) PartGroup(PartKind.length, lengths),
    if (widths.isNotEmpty) PartGroup(PartKind.width, widths),
  ];
}
