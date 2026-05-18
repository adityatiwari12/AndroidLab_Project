import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

// Platform metadata — icon, brand colour, URL hint
const _platforms = [
  _Platform('LinkedIn',   Icons.work_outline,    Color(0xFF0077B5), 'linkedin.com/in/username'),
  _Platform('GitHub',     Icons.code,             Color(0xFF181717), 'github.com/username'),
  _Platform('LeetCode',   Icons.code_off,         Color(0xFFFFA116), 'leetcode.com/u/username'),
  _Platform('Codeforces', Icons.terminal,         Color(0xFF1F8ACB), 'codeforces.com/profile/handle'),
  _Platform('CodeChef',   Icons.restaurant,       Color(0xFF6B40B6), 'codechef.com/users/handle'),
  _Platform('Portfolio',  Icons.language,         AppColors.primary, 'https://yoursite.com'),
];

class _Platform {
  final String name;
  final IconData icon;
  final Color color;
  final String hint;
  const _Platform(this.name, this.icon, this.color, this.hint);
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser!;
    final activities = ref.watch(activitiesProvider);
    final coding = ref.watch(codingProvider);
    final links = ref.watch(profileLinksProvider);

    final linkedCount = links.length;
    int completeness = 40;
    if (activities.isNotEmpty) completeness += 15;
    if (coding.isNotEmpty) completeness += 15;
    completeness += (linkedCount * 5).clamp(0, 30);
    completeness = completeness.clamp(0, 100);

    final missing = _platforms
        .where((p) => !links.containsKey(p.name))
        .map((p) => p.name)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Banner + avatar ──────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 20,
                  child: Stack(
                    children: [
                      Container(
                        width: 84, height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        ),
                        child: Center(
                          child: Text(user.avatarInitials,
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28)),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name ────────────────────────────────────────────────────
                  Text(user.fullName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('${user.displayClass}  ·  Roll: ${user.rollNumber}',
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),

                  // ── Completeness ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Profile Completeness',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                            Text('$completeness%',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completeness / 100, minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                        if (missing.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 6,
                            children: missing.take(3).map((name) => _MissingChip(
                              label: 'Add $name',
                              onTap: () => _showEditSheet(context, ref, _platforms.firstWhere((p) => p.name == name), links[name]),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Online Presence ──────────────────────────────────────────
                  Text('Online Presence',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.0,
                    ),
                    itemCount: _platforms.length,
                    itemBuilder: (_, i) {
                      final p = _platforms[i];
                      final url = links[p.name];
                      return _PlatformTile(
                        platform: p,
                        url: url,
                        onTap: () => _showEditSheet(context, ref, p, url),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Quick stats ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Activities', value: '${activities.length}')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(label: 'Coding', value: '${coding.length}')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(label: 'Approved',
                        value: '${activities.where((a) => a.status.name == 'approved').length}')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Logout ───────────────────────────────────────────────────
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                    label: Text('Logout', style: GoogleFonts.dmSans(color: AppColors.error, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, _Platform p, String? current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditLinkSheet(platform: p, current: current, ref: ref),
    );
  }
}

// ── Edit link bottom sheet ────────────────────────────────────────────────────

class _EditLinkSheet extends ConsumerStatefulWidget {
  final _Platform platform;
  final String? current;
  final WidgetRef ref;

  const _EditLinkSheet({required this.platform, required this.current, required this.ref});

  @override
  ConsumerState<_EditLinkSheet> createState() => _EditLinkSheetState();
}

class _EditLinkSheetState extends ConsumerState<_EditLinkSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.current ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final url = _ctrl.text.trim();
    if (url.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(profileLinksProvider.notifier).update(widget.platform.name, url);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.platform.name} link saved!',
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _remove() async {
    setState(() => _saving = true);
    await ref.read(profileLinksProvider.notifier).remove(widget.platform.name);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.platform.name} link removed',
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
      backgroundColor: AppColors.textSecondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.platform;
    final isLinked = widget.current != null && widget.current!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: p.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(p.icon, color: p.color, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.textPrimary)),
                  Text(isLinked ? 'Edit your link' : 'Add your link',
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Input
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: p.name,
              hintText: p.hint,
              prefixIcon: Icon(Icons.link_rounded, color: p.color, size: 20),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _ctrl.clear()),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              if (isLinked) ...[
                OutlinedButton.icon(
                  onPressed: _saving ? null : _remove,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: (_saving || _ctrl.text.trim().isEmpty) ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(isLinked ? 'Update' : 'Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _PlatformTile extends StatelessWidget {
  final _Platform platform;
  final String? url;
  final VoidCallback onTap;

  const _PlatformTile({required this.platform, required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final linked = url != null && url!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: linked ? platform.color.withOpacity(0.35) : AppColors.border,
            width: linked ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(platform.icon, size: 18, color: linked ? platform.color : AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(platform.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textPrimary)),
                  Text(
                    linked ? url! : 'Tap to add',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: linked ? platform.color : AppColors.textMuted,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              linked ? Icons.edit_rounded : Icons.add_rounded,
              size: 14,
              color: linked ? platform.color : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MissingChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 12)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.primary)),
          Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
