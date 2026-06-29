// =============================================================================
// screens/scan_screen.dart
// Core ML flow: pick image → OCR → edit → save
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scan_entry.dart';
import '../providers/scan_provider.dart';
import '../widgets/category_badge.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _titleCtrl   = TextEditingController();
  final _textCtrl    = TextEditingController();
  final _noteCtrl    = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  EntryCategory _category = EntryCategory.note;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onScanDone(String text, String? imagePath) {
    _textCtrl.text = text;
    // Auto-suggest category from content
    final lower = text.toLowerCase();
    if (lower.contains('total') || lower.contains('\$') || lower.contains('receipt')) {
      setState(() => _category = EntryCategory.receipt);
    } else if (lower.contains('name') && lower.contains('dob') ||
               lower.contains('id number') || lower.contains('license')) {
      setState(() => _category = EntryCategory.id);
    } else if (lower.contains('chapter') || lower.contains('paragraph') ||
               lower.contains('section')) {
      setState(() => _category = EntryCategory.document);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<ScanProvider>();

    await prov.addEntry(
      title:       _titleCtrl.text,
      scannedText: _textCtrl.text,
      userNote:    _noteCtrl.text,
      category:    _category,
      imagePath:   prov.lastImagePath,
    );
    prov.clearScan();

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:  Text('Entry saved!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<ScanProvider>();
    final scheme = Theme.of(context).colorScheme;

    // Sync OCR result to text field
    if (prov.scanState == ScanState.done &&
        prov.lastScannedText != null &&
        _textCtrl.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onScanDone(prov.lastScannedText!, prov.lastImagePath);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Scan'),
        actions: [
          if (_textCtrl.text.isNotEmpty)
            TextButton.icon(
              onPressed: _save,
              icon:  const Icon(Icons.save_outlined),
              label: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image source buttons ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _SourceButton(
                        icon:    Icons.photo_library_outlined,
                        label:   'Choose Photo',
                        onTap:   prov.isScanning
                            ? null
                            : prov.scanFromGallery,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SourceButton(
                        icon:    Icons.camera_alt_outlined,
                        label:   'Take Photo',
                        onTap:   prov.isScanning
                            ? null
                            : prov.scanFromCamera,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Scan status ──────────────────────────────────────────
                _ScanStatusBanner(prov: prov),

                // ── Image preview ────────────────────────────────────────
                if (prov.lastImagePath != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(prov.lastImagePath!),
                      width:  double.infinity,
                      height: 180,
                      fit:    BoxFit.cover,
                    ),
                  ),
                ],

                // ── Editable fields (only shown after scan or manually) ──
                if (prov.scanState == ScanState.done ||
                    _textCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Title
                  const Text('Title',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'Give this scan a name…',
                      border:   OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      isDense:  true,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category selector
                  const Text('Category',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing:     8,
                    runSpacing:  8,
                    children: EntryCategory.values.map((cat) {
                      final selected = _category == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding:  const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:  selected
                                ? scheme.primary
                                : scheme.primaryContainer
                                    .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? scheme.primary
                                  : scheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat.icon,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 5),
                              Text(cat.label,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: selected
                                          ? Colors.white
                                          : scheme.onSurface)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Scanned / extracted text (editable)
                  Row(
                    children: [
                      const Text('Extracted Text',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (_textCtrl.text.isNotEmpty)
                        Text(
                          '${_textCtrl.text.trim().split(RegExp(r'\s+')).length} words',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _textCtrl,
                    maxLines:   8,
                    decoration: InputDecoration(
                      hintText: 'Scanned text appears here — you can edit it…',
                      border:   OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Text cannot be empty';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // User note
                  const Text('My Note',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _noteCtrl,
                    maxLines:   3,
                    decoration: InputDecoration(
                      hintText: 'Add your own notes or comments…',
                      border:   OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width:  double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _save,
                      icon:  const Icon(Icons.save_outlined),
                      label: const Text('Save Entry',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],

                // ── Manual entry option (before scan) ───────────────────
                if (prov.scanState == ScanState.idle &&
                    _textCtrl.text.isEmpty) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {});
                        _textCtrl.text = ' ';
                        _textCtrl.clear();
                      },
                      icon:  const Icon(Icons.edit_outlined),
                      label: const Text('Or type manually instead'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Source button ─────────────────────────────────────────────────────────────

class _SourceButton extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final VoidCallback? onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      onPressed: onTap,
      icon:  Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

// ── Scan status banner ────────────────────────────────────────────────────────

class _ScanStatusBanner extends StatelessWidget {
  final ScanProvider prov;
  const _ScanStatusBanner({required this.prov});

  @override
  Widget build(BuildContext context) {
    return switch (prov.scanState) {
      ScanState.picking || ScanState.scanning => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text(
                  prov.scanState == ScanState.picking
                      ? 'Selecting image…'
                      : '🔍 Running on-device text recognition…',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ],
            ),
          ),
      ScanState.done => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Text recognized — review and edit below',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
          ),
      ScanState.error => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:        Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prov.lastError ?? 'Text recognition failed',
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],
            ),
          ),
      _ => const SizedBox.shrink(),
    };
  }
}
