// =============================================================================
// providers/scan_provider.dart
// Central state with detailed console logging
// =============================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/scan_entry.dart';
import '../services/ocr_service.dart';
import '../services/storage_service.dart';

enum ScanState { idle, picking, scanning, done, error }

void debugLog(String message) {
  // ignore: avoid_print
  print('[ScanLog] $message');
}

class ScanProvider extends ChangeNotifier {
  final OcrService     _ocr     = OcrService();
  final StorageService _storage = StorageService();
  final ImagePicker    _picker  = ImagePicker();
  final Uuid           _uuid    = const Uuid();

  List<ScanEntry> _entries       = [];
  String?         _filterCategory;
  String          _searchQuery   = '';
  ScanState       _scanState     = ScanState.idle;
  String?         _lastError;
  String?         _lastScannedText;
  String?         _lastImagePath;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<ScanEntry> get entries {
    var list = List<ScanEntry>.from(_entries);
    if (_filterCategory != null) {
      final cat = EntryCategory.values
          .firstWhere((c) => c.name == _filterCategory,
              orElse: () => EntryCategory.note);
      list = list.where((e) => e.category == cat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.scannedText.toLowerCase().contains(q) ||
          e.userNote.toLowerCase().contains(q)).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<ScanEntry> get allEntries      => List.unmodifiable(_entries);
  ScanState       get scanState       => _scanState;
  String?         get lastError       => _lastError;
  String?         get lastScannedText => _lastScannedText;
  String?         get lastImagePath   => _lastImagePath;
  String          get searchQuery     => _searchQuery;
  String?         get filterCategory  => _filterCategory;
  bool            get isScanning      => _scanState == ScanState.scanning;
  int             get totalEntries    => _entries.length;
  int             get totalWords      =>
      _entries.fold(0, (sum, e) => sum + e.wordCount);

  Map<EntryCategory, int> get categoryCounts {
    final map = <EntryCategory, int>{};
    for (final cat in EntryCategory.values) {
      map[cat] = _entries.where((e) => e.category == cat).length;
    }
    return map;
  }

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> loadEntries() async {
    debugLog('💾 [Storage] Loading entries from SharedPreferences...');
    _entries = await _storage.loadEntries();
    debugLog('💾 [Storage] Loaded ${_entries.length} entries');
    for (final e in _entries) {
      debugLog('  📋 Entry: "${e.title}" | ${e.category.label} | ${e.wordCount} words | ${e.createdAt}');
    }
    notifyListeners();
  }

  // ── Scan ──────────────────────────────────────────────────────────────────
  Future<void> scanFromGallery() async {
    debugLog('🖼️  [Scan] User tapped "Choose Photo" (gallery)');
    await _pickAndScan(ImageSource.gallery);
  }

  Future<void> scanFromCamera() async {
    debugLog('📸 [Scan] User tapped "Take Photo" (camera)');
    await _pickAndScan(ImageSource.camera);
  }

  Future<void> _pickAndScan(ImageSource source) async {
    _scanState     = ScanState.picking;
    _lastError     = null;
    _lastScannedText = null;
    _lastImagePath   = null;
    notifyListeners();

    try {
      debugLog('⏳ [Scan] Opening image picker (source: ${source.name})...');
      final picked = await _picker.pickImage(
          source: source, imageQuality: 90);

      if (picked == null) {
        debugLog('⚠️  [Scan] User cancelled image picker — no image selected');
        _scanState = ScanState.idle;
        notifyListeners();
        return;
      }

      _lastImagePath = picked.path;
      debugLog('🖼️  [Scan] Image selected: ${picked.path}');
      debugLog('🖼️  [Scan] Image name: ${picked.name}');

      _scanState = ScanState.scanning;
      notifyListeners();

      final text = await _ocr.recognizeText(picked.path);
      _lastScannedText = text;
      _scanState       = ScanState.done;

    } catch (e) {
      debugLog('❌ [Scan] Error: $e');
      _lastError = e.toString();
      _scanState = ScanState.error;
    }
    notifyListeners();
  }

  void clearScan() {
    debugLog('🧹 [Scan] Clearing scan state');
    _scanState       = ScanState.idle;
    _lastError       = null;
    _lastScannedText = null;
    _lastImagePath   = null;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<void> addEntry({
    required String        title,
    required String        scannedText,
    required String        userNote,
    required EntryCategory category,
    String?                imagePath,
  }) async {
    final now   = DateTime.now();
    final entry = ScanEntry(
      id:          _uuid.v4(),
      title:       title.trim().isEmpty
          ? 'Scan ${_entries.length + 1}'
          : title.trim(),
      scannedText: scannedText,
      userNote:    userNote,
      category:    category,
      createdAt:   now,
      updatedAt:   now,
      imagePath:   imagePath,
    );

    debugLog('💾 [Storage] Saving new entry...');
    debugLog('  📋 Title:    "${entry.title}"');
    debugLog('  📋 Category: ${entry.category.label}');
    debugLog('  📋 Words:    ${entry.wordCount}');
    debugLog('  📋 Note:     "${entry.userNote}"');
    debugLog('  📋 Text preview: "${entry.scannedText.length > 80 ? entry.scannedText.substring(0, 80) + "..." : entry.scannedText}"');

    _entries.add(entry);
    await _storage.saveEntries(_entries);
    debugLog('✅ [Storage] Entry saved. Total entries: ${_entries.length}');
    notifyListeners();
  }

  Future<void> updateEntry(ScanEntry updated) async {
    final idx = _entries.indexWhere((e) => e.id == updated.id);
    if (idx == -1) {
      debugLog('⚠️  [Storage] Update failed — entry ID not found: ${updated.id}');
      return;
    }
    debugLog('✏️  [Storage] Updating entry "${updated.title}"');
    debugLog('  📋 New category: ${updated.category.label}');
    debugLog('  📋 New note:     "${updated.userNote}"');
    _entries[idx] = updated.copyWith(updatedAt: DateTime.now());
    await _storage.saveEntries(_entries);
    debugLog('✅ [Storage] Entry updated');
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    final entry = _entries.firstWhere(
        (e) => e.id == id,
        orElse: () => _entries.first);
    debugLog('🗑️  [Storage] Deleting entry "${entry.title}" (id: $id)');
    _entries.removeWhere((e) => e.id == id);
    await _storage.saveEntries(_entries);
    debugLog('✅ [Storage] Entry deleted. Remaining: ${_entries.length}');
    notifyListeners();
  }

  // ── Filters ───────────────────────────────────────────────────────────────
  void setSearch(String query) {
    debugLog('🔍 [Filter] Search query: "$query"');
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    debugLog('🏷️  [Filter] Category filter: ${category ?? "All"}');
    _filterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    debugLog('🧹 [Filter] Clearing all filters');
    _searchQuery    = '';
    _filterCategory = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugLog('🔒 [Provider] Disposing ScanProvider');
    _ocr.dispose();
    super.dispose();
  }
}
