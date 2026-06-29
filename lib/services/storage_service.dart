// =============================================================================
// services/storage_service.dart
// Local persistence using SharedPreferences (JSON encoding)
// =============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_entry.dart';

class StorageService {
  static const String _key = 'scanlog_entries';

  Future<List<ScanEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ScanEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveEntries(List<ScanEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
