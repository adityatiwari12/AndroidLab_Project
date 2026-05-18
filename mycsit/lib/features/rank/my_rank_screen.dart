import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class MyRankScreen extends ConsumerWidget {
  const MyRankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser!;
    final score = ref.watch(scoreProvider);
    final leaderboard = MockData.leaderboard;
    final rank = leaderboard.indexWhere((r) => r['userId'] == user.id) + 1;
    final total = leaderboard.length;

    final components = [
      (label: '🏆 Hackathons', weight: '35%', value: score.hackathonScore, color: AppColors.hackathon),
      (label: '💼 Projects', weight: '25%', value: score.projectScore, color: AppColors.internship),
      (label: '🎓 Academic', weight: '25%', value: score.academicScore, color: AppColors.info),
      (label: '💻 Coding', weight: '15%', value: score.codingScore, color: AppColors.milestone),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Rank', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Rank card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    user.displayClass,
                    style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rank > 0 ? '#$rank of $total' : '—',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Rank',
                    style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '${Formatters.score(score.totalScore)} / 100',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Score breakdown
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Score Breakdown',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  const Divider(height: 1),
                  ...components.asMap().entries.map((e) {
                    final i = e.key;
                    final c = e.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(c.label, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: c.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(c.weight, style: GoogleFonts.dmSans(fontSize: 11, color: c.color, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Formatters.score(c.value),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: c.color),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: c.value / 100,
                                        minHeight: 6,
                                        backgroundColor: c.color.withOpacity(0.12),
                                        valueColor: AlwaysStoppedAnimation(c.color),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < components.length - 1) const Divider(height: 1, indent: 16),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Leaderboard preview
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Class Leaderboard',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  const Divider(height: 1),
                  ...leaderboard.asMap().entries.map((e) {
                    final i = e.key;
                    final row = e.value;
                    final isMe = row['userId'] == user.id;
                    return Container(
                      color: isMe ? AppColors.primaryLight : null,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '#${i + 1}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: i == 0 ? const Color(0xFFFFB800) : i == 1 ? const Color(0xFF9CA3AF) : i == 2 ? const Color(0xFFCD7F32) : AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              row['fullName'],
                              style: GoogleFonts.dmSans(
                                fontWeight: isMe ? FontWeight.w700 : FontWeight.w400,
                                fontSize: 14,
                                color: isMe ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            Formatters.score(row['total'] as double),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: isMe ? AppColors.primary : AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 16),
                    child: Text(
                      'Department leaderboard is visible to faculty.',
                      style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
