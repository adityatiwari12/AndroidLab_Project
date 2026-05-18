import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/data_provider.dart';

class AcademicsScreen extends ConsumerWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(academicsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Academics', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_outlined, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No academic records yet.', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Faculty will enter your marks here.', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CGPA trend row
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final r = records[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Sem ${r.semester}', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary)),
                              Text(r.cgpa.toStringAsFixed(1), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Semester accordions
                  ...records.map((r) => _SemesterCard(record: r)),
                ],
              ),
            ),
    );
  }
}

class _SemesterCard extends StatefulWidget {
  final dynamic record;
  const _SemesterCard({required this.record});

  @override
  State<_SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<_SemesterCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final att = r.attendancePercentage;
    final attColor = att >= 85 ? AppColors.success : att >= 75 ? AppColors.warning : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${r.semester}', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Semester ${r.semester}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('CGPA: ${r.cgpa.toStringAsFixed(2)}', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Subjects table
                  if (r.subjects.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(flex: 3, child: Text('Subject', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textMuted))),
                        Text('Marks', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(width: 16),
                        Text('%', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...r.subjects.map<Widget>((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(s.subjectName, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary))),
                          Text('${s.marksObtained}/${s.maxMarks}', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13)),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${s.percentage.toStringAsFixed(0)}%',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: s.percentage >= 80 ? AppColors.success : s.percentage >= 60 ? AppColors.warning : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // Attendance
                  if (r.totalClasses > 0) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Attendance', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('${r.attended} / ${r.totalClasses} classes', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: attColor, width: 4),
                          ),
                          child: Center(
                            child: Text(
                              '${att.toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: attColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
