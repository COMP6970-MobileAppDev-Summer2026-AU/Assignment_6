// =============================================================================
// models/scan_entry.dart
// A single journal entry created from a scan or manual input
// =============================================================================

enum EntryCategory {
  note,
  receipt,
  document,
  id,
  other;

  String get label => switch (this) {
        EntryCategory.note     => 'Note',
        EntryCategory.receipt  => 'Receipt',
        EntryCategory.document => 'Document',
        EntryCategory.id       => 'ID / Card',
        EntryCategory.other    => 'Other',
      };

  String get icon => switch (this) {
        EntryCategory.note     => '📝',
        EntryCategory.receipt  => '🧾',
        EntryCategory.document => '📄',
        EntryCategory.id       => '🪪',
        EntryCategory.other    => '📌',
      };
}

class ScanEntry {
  final String        id;
  final String        title;
  final String        scannedText;
  final String        userNote;
  final EntryCategory category;
  final DateTime      createdAt;
  final DateTime      updatedAt;
  final String?       imagePath;

  const ScanEntry({
    required this.id,
    required this.title,
    required this.scannedText,
    required this.userNote,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });

  ScanEntry copyWith({
    String?        title,
    String?        scannedText,
    String?        userNote,
    EntryCategory? category,
    DateTime?      updatedAt,
    String?        imagePath,
  }) =>
      ScanEntry(
        id:          id,
        title:       title       ?? this.title,
        scannedText: scannedText ?? this.scannedText,
        userNote:    userNote    ?? this.userNote,
        category:    category    ?? this.category,
        createdAt:   createdAt,
        updatedAt:   updatedAt   ?? this.updatedAt,
        imagePath:   imagePath   ?? this.imagePath,
      );

  // ── JSON serialization ─────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id':          id,
        'title':       title,
        'scannedText': scannedText,
        'userNote':    userNote,
        'category':    category.index,
        'createdAt':   createdAt.toIso8601String(),
        'updatedAt':   updatedAt.toIso8601String(),
        'imagePath':   imagePath,
      };

  factory ScanEntry.fromJson(Map<String, dynamic> json) => ScanEntry(
        id:          json['id']          as String,
        title:       json['title']       as String,
        scannedText: json['scannedText'] as String,
        userNote:    json['userNote']    as String? ?? '',
        category:    EntryCategory.values[json['category'] as int? ?? 0],
        createdAt:   DateTime.parse(json['createdAt'] as String),
        updatedAt:   DateTime.parse(json['updatedAt'] as String),
        imagePath:   json['imagePath']   as String?,
      );

  /// Word count of scanned text
  int get wordCount =>
      scannedText.trim().isEmpty ? 0 : scannedText.trim().split(RegExp(r'\s+')).length;

  /// Short preview for list display
  String get preview {
    final text = scannedText.trim();
    if (text.isEmpty) return userNote.isNotEmpty ? userNote : 'No content';
    return text.length > 100 ? '${text.substring(0, 100)}…' : text;
  }
}
