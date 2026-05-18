import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/enums.dart';
import '../../providers/data_provider.dart';
import '../../shared/widgets/entry_card.dart';
import 'add_coding_sheet.dart';

class CodingScreen extends ConsumerStatefulWidget {
  const CodingScreen({super.key});

  @override
  ConsumerState<CodingScreen> createState() => _CodingScreenState();
}

class _CodingScreenState extends ConsumerState<CodingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(codingProvider);
    final milestones = all.where((c) => c.type == CodingType.milestone).toList();
    final contests = all.where((c) => c.type == CodingType.contest).toList();
    final problems = all.where((c) => c.type == CodingType.notableProblem).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Coding Activity', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Milestones (${milestones.length})'),
            Tab(text: 'Contests (${contests.length})'),
            Tab(text: 'Problems (${problems.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddCodingSheet(),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _CodingList(entries: milestones),
          _CodingList(entries: contests),
          _CodingList(entries: problems),
        ],
      ),
    );
  }
}

class _CodingList extends StatelessWidget {
  final List entries;
  const _CodingList({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.code_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No entries yet.', style: GoogleFonts.dmSans(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (_, i) => CodingEntryCard(entry: entries[i]),
    );
  }
}
