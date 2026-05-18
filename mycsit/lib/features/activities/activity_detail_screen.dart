import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../providers/data_provider.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/type_chip.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String id;

  const ActivityDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final activity = activities.where((a) => a.id == id).firstOrNull;

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity Detail')),
        body: const Center(child: Text('Activity not found.')),
      );
    }

    final typeColor = AppColors.forType(activity.type.name);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Activity Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: typeColor, width: 4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TypeChip(label: activity.type.label, typeName: activity.type.name),
                      const Spacer(),
                      StatusBadge(status: activity.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activity.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        activity.formattedDate,
                        style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            if (activity.description.isNotEmpty) ...[
              _SectionCard(
                title: 'Description',
                child: Text(
                  activity.description,
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Rejection reason
            if (activity.status == EntryStatus.rejected && activity.rejectionReason != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity.rejectionReason!,
                            style: GoogleFonts.dmSans(color: AppColors.error, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit & Resubmit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (activity.status == EntryStatus.approved) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success),
                    const SizedBox(width: 10),
                    Text(
                      'Approved by faculty. Counts toward your score.',
                      style: GoogleFonts.dmSans(color: AppColors.success, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Proof
            _SectionCard(
              title: 'Proof',
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    activity.proofPath ?? 'No proof attached',
                    style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const Spacer(),
                  if (activity.proofPath != null)
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View',
                        style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _SectionCard(
              title: 'Submitted',
              child: Text(
                Formatters.dateStr(activity.createdAt),
                style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
