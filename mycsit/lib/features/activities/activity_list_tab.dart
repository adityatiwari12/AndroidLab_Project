import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/enums.dart';
import '../../providers/data_provider.dart';
import '../../shared/widgets/entry_card.dart';
import 'add_activity_sheet.dart';

class ActivityListTab extends ConsumerStatefulWidget {
  const ActivityListTab({super.key});

  @override
  ConsumerState<ActivityListTab> createState() => _ActivityListTabState();
}

class _ActivityListTabState extends ConsumerState<ActivityListTab> {
  ActivityType? _typeFilter;
  EntryStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(activitiesProvider);

    final filtered = all.where((a) {
      if (_typeFilter != null && a.type != _typeFilter) return false;
      if (_statusFilter != null && a.status != _statusFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Activity Log',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddActivitySheet(),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _typeFilter == null,
                  onTap: () => setState(() => _typeFilter = null),
                ),
                for (final t in ActivityType.values)
                  _FilterChip(
                    label: t.label,
                    color: AppColors.forType(t.name),
                    selected: _typeFilter == t,
                    onTap: () => setState(() => _typeFilter = _typeFilter == t ? null : t),
                  ),
              ],
            ),
          ),

          // Status segmented
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _StatusTab(label: 'All', selected: _statusFilter == null, onTap: () => setState(() => _statusFilter = null)),
                const SizedBox(width: 8),
                _StatusTab(label: 'Pending', color: AppColors.warning, selected: _statusFilter == EntryStatus.pending, onTap: () => setState(() => _statusFilter = _statusFilter == EntryStatus.pending ? null : EntryStatus.pending)),
                const SizedBox(width: 8),
                _StatusTab(label: 'Approved', color: AppColors.success, selected: _statusFilter == EntryStatus.approved, onTap: () => setState(() => _statusFilter = _statusFilter == EntryStatus.approved ? null : EntryStatus.approved)),
                const SizedBox(width: 8),
                _StatusTab(label: 'Rejected', color: AppColors.error, selected: _statusFilter == EntryStatus.rejected, onTap: () => setState(() => _statusFilter = _statusFilter == EntryStatus.rejected ? null : EntryStatus.rejected)),
              ],
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No entries match your filters.',
                          style: GoogleFonts.dmSans(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => ActivityEntryCard(
                      activity: filtered[i],
                      onTap: () => context.push('/activities/${filtered[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: selected ? c : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? c : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _StatusTab({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? c : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? c : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
