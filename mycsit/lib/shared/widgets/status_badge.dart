import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/enums.dart';

class StatusBadge extends StatelessWidget {
  final EntryStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status) {
      EntryStatus.approved => (AppColors.success, AppColors.successLight, 'Approved'),
      EntryStatus.rejected => (AppColors.error, AppColors.errorLight, 'Rejected'),
      EntryStatus.pending => (AppColors.warning, AppColors.warningLight, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
