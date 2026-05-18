import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/coding_model.dart';
import '../../data/models/enums.dart';
import 'status_badge.dart';
import 'type_chip.dart';

class ActivityEntryCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onTap;

  const ActivityEntryCard({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.forType(activity.type.name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TypeChip(
                          label: activity.type.label,
                          typeName: activity.type.name,
                        ),
                        const Spacer(),
                        StatusBadge(status: activity.status),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity.title,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.formattedDate,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CodingEntryCard extends StatelessWidget {
  final CodingActivityModel entry;

  const CodingEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final platformColor = _platformColor(entry.platform.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: platformColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  entry.platform.label[0],
                  style: GoogleFonts.poppins(
                    color: platformColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.platform.label,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TypeChip(label: entry.type.label, typeName: entry.type.name),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.displayValue,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(status: entry.status),
          ],
        ),
      ),
    );
  }

  Color _platformColor(String p) {
    switch (p) {
      case 'leetcode': return const Color(0xFFFFA116);
      case 'codeforces': return const Color(0xFF1F8ACB);
      case 'codechef': return const Color(0xFF6B40B6);
      default: return AppColors.textSecondary;
    }
  }
}
