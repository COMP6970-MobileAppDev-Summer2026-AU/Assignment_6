// =============================================================================
// screens/entry_detail_screen.dart
// Full entry detail view with inline editing
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/scan_entry.dart';
import '../providers/scan_provider.dart';
import '../widgets/category_badge.dart';

class EntryDetailScreen extends StatefulWidget {
  final ScanEntry entry;
  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _textCtrl;
  late TextEditingController _noteCtrl;
  late EntryCategory         _category;
  bool                       _editing = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry.title);
    _textCtrl  = TextEditingController(text: widget.entry.scannedText);
    _noteCtrl  = TextEditingController(text: widget.entry.userNote);
    _category  = widget.entry.category;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    if (_textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:  Text('Scanned text cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final updated = widget.entry.copyWith(
      title:       _titleCtrl.text,
      scannedText: _textCtrl.text,
      userNote:    _noteCtrl.text,
      category:    _category,
    );
    await context.read<ScanProvider>().updateEntry(updated);
    if (!mounted) return;
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:  Text('Entry updated'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.entry.scannedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:  Text('Text copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<ScanProvider>().deleteEntry(widget.entry.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final created = DateFormat('MMMM d, yyyy · h:mm a')
        .format(widget.entry.createdAt);
    final updated = DateFormat('MMM d, yyyy · h:mm a')
        .format(widget.entry.updatedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Editing' : 'Entry Detail'),
        actions: [
          if (!_editing) ...[
            IconButton(
              icon:    const Icon(Icons.copy_outlined),
              tooltip: 'Copy text',
              onPressed: _copyToClipboard,
            ),
            IconButton(
              icon:    const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => setState(() => _editing = true),
            ),
            IconButton(
              icon:    Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                // Restore original values
                _titleCtrl.text = widget.entry.title;
                _textCtrl.text  = widget.entry.scannedText;
                _noteCtrl.text  = widget.entry.userNote;
                setState(() {
                  _editing  = false;
                  _category = widget.entry.category;
                });
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saveEdit,
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ───────────────────────────────────────────────────
            if (widget.entry.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(widget.entry.imagePath!),
                  width:  double.infinity,
                  height: 200,
                  fit:    BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Title ────────────────────────────────────────────────────
            _editing
                ? TextField(
                    controller: _titleCtrl,
                    style:      const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : Text(widget.entry.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            // ── Category ─────────────────────────────────────────────────
            if (_editing)
              Wrap(
                spacing:    8,
                runSpacing: 6,
                children: EntryCategory.values.map((cat) {
                  final sel = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel
                            ? scheme.primary
                            : scheme.primaryContainer
                                .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? scheme.primary
                                : scheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Text('${cat.icon} ${cat.label}',
                          style: TextStyle(
                              fontSize: 12,
                              color: sel ? Colors.white : scheme.onSurface)),
                    ),
                  );
                }).toList(),
              )
            else
              CategoryBadge(category: widget.entry.category),

            const SizedBox(height: 12),

            // ── Metadata ─────────────────────────────────────────────────
            Wrap(
              spacing:    12,
              runSpacing: 4,
              children: [
                _MetaChip(
                    icon: Icons.access_time_outlined, label: 'Created $created'),
                _MetaChip(
                    icon: Icons.edit_calendar_outlined,
                    label: 'Updated $updated'),
                _MetaChip(
                    icon:  Icons.text_fields_outlined,
                    label: '${widget.entry.wordCount} words'),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // ── Scanned text ─────────────────────────────────────────────
            Row(
              children: [
                const Text('Extracted Text',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!_editing)
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon:  const Icon(Icons.copy_outlined, size: 14),
                    label: const Text('Copy', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _editing
                ? TextField(
                    controller: _textCtrl,
                    maxLines:   null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        scheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.3)),
                    ),
                    child: Text(widget.entry.scannedText,
                        style: const TextStyle(
                            fontSize: 14, height: 1.6)),
                  ),

            const SizedBox(height: 20),

            // ── User note ─────────────────────────────────────────────────
            const Text('My Note',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _editing
                ? TextField(
                    controller: _noteCtrl,
                    maxLines:   4,
                    decoration: InputDecoration(
                      hintText: 'Add your notes…',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : widget.entry.userNote.isNotEmpty
                    ? Container(
                        width:   double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:  Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Text(widget.entry.userNote,
                            style: const TextStyle(
                                fontSize: 14, height: 1.5)),
                      )
                    : Text('No note added.',
                        style: TextStyle(color: Colors.grey.shade400)),

            if (_editing) ...[
              const SizedBox(height: 24),
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
                  onPressed: _saveEdit,
                  icon:  const Icon(Icons.save_outlined),
                  label: const Text('Save Changes',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
}
