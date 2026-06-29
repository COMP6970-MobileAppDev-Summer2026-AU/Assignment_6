// =============================================================================
// screens/home_screen.dart
// Entry list with search, category filter, stats summary, and scan FAB
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/scan_entry.dart';
import '../providers/scan_provider.dart';
import '../widgets/category_badge.dart';
import 'scan_screen.dart';
import 'entry_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<ScanProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanLog',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        actions: [
          if (prov.searchQuery.isNotEmpty || prov.filterCategory != null)
            TextButton.icon(
              onPressed: prov.clearFilters,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText:   'Search entries…',
                isDense:    true,
                suffixIcon: prov.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => prov.setSearch(''),
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: prov.setSearch,
            ),
          ),

          // ── Category filter chips ──────────────────────────────────────
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  count: prov.totalEntries,
                  selected: prov.filterCategory == null,
                  onTap: () => prov.setFilterCategory(null),
                ),
                ...EntryCategory.values.map((cat) => _FilterChip(
                      label: '${cat.icon} ${cat.label}',
                      count: prov.categoryCounts[cat] ?? 0,
                      selected: prov.filterCategory == cat.name,
                      onTap: () => prov.setFilterCategory(
                          prov.filterCategory == cat.name ? null : cat.name),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Stats row ──────────────────────────────────────────────────
          if (prov.totalEntries > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _StatPill(
                    icon:  Icons.library_books_outlined,
                    label: '${prov.totalEntries} entries',
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon:  Icons.text_fields_outlined,
                    label: '${prov.totalWords} words scanned',
                  ),
                ],
              ),
            ),

          // ── Entry list ─────────────────────────────────────────────────
          Expanded(
            child: prov.entries.isEmpty
                ? _emptyState(context, prov)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: prov.entries.length,
                    itemBuilder: (_, i) =>
                        _EntryCard(entry: prov.entries[i]),
                  ),
          ),
        ],
      ),

      // ── FAB: new scan ────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        ),
        icon:  const Icon(Icons.document_scanner_outlined),
        label: const Text('New Scan',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _emptyState(BuildContext context, ScanProvider prov) {
    final hasFilters =
        prov.searchQuery.isNotEmpty || prov.filterCategory != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.search_off_outlined
                  : Icons.document_scanner_outlined,
              size:  72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No entries match' : 'No scans yet',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try different search terms or clear filters'
                  : 'Tap the scan button to extract text from an image',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: prov.clearFilters,
                icon:  const Icon(Icons.refresh),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Entry card ────────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final ScanEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final prov   = context.read<ScanProvider>();
    final scheme = Theme.of(context).colorScheme;
    final date   = DateFormat('MMM d, yyyy · h:mm a').format(entry.createdAt);

    return Card(
      margin:    const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EntryDetailScreen(entry: entry)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + category
              Row(
                children: [
                  Expanded(
                    child: Text(entry.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  CategoryBadge(category: entry.category, small: true),
                ],
              ),
              const SizedBox(height: 6),

              // Preview text
              Text(entry.preview,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),

              const SizedBox(height: 8),

              // Date + word count + delete
              Row(
                children: [
                  Icon(Icons.access_time_outlined,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(date,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                  const SizedBox(width: 10),
                  Icon(Icons.text_fields_outlined,
                      size: 12, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text('${entry.wordCount}w',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                  const Spacer(),
                  // Quick delete
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: Colors.red.shade300),
                    onPressed: () => _confirmDelete(context, prov),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ScanProvider prov) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text(
            '"${entry.title}" will be permanently removed.'),
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
    if (confirmed == true) {
      await prov.deleteEntry(entry.id);
    }
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String       label;
  final int          count;
  final bool         selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin:  const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text('$label ($count)',
            style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : scheme.onSurface)),
      ),
    );
  }
}

// ── Stat pill ─────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        scheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: scheme.primary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
