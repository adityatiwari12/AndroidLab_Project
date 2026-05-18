import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/notification_model.dart';
import '../../providers/data_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
            child: Text('Mark all read', style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('All caught up!', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Text('No notifications.', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return _NotifTile(
                  notification: n,
                  onTap: () => ref.read(notificationsProvider.notifier).markRead(n.id),
                );
              },
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotifTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? null : AppColors.primaryLight.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.dmSans(
                      fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.relativeTime(notification.createdAt),
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.account: return (Icons.account_circle_outlined, AppColors.primary);
      case NotificationType.activityApproved: return (Icons.check_circle_outlined, AppColors.success);
      case NotificationType.activityRejected: return (Icons.cancel_outlined, AppColors.error);
      case NotificationType.coding: return (Icons.code_rounded, AppColors.info);
      case NotificationType.general: return (Icons.info_outline, AppColors.textSecondary);
    }
  }
}
