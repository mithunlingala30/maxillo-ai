import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Represents a single in-app notification event.
enum NotificationType {
  predictionComplete,
  reportGenerated,
  recoveryReminder,
  followUpReminder,
  systemUpdate,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.predictionComplete:
        return Icons.check_circle_outline;
      case NotificationType.reportGenerated:
        return Icons.picture_as_pdf_outlined;
      case NotificationType.recoveryReminder:
        return Icons.favorite_border;
      case NotificationType.followUpReminder:
        return Icons.event_available_outlined;
      case NotificationType.systemUpdate:
        return Icons.campaign_outlined;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.predictionComplete:
        return AppColors.success;
      case NotificationType.reportGenerated:
        return AppColors.primaryBlue;
      case NotificationType.recoveryReminder:
        return AppColors.teal;
      case NotificationType.followUpReminder:
        return AppColors.purple;
      case NotificationType.systemUpdate:
        return AppColors.warning;
    }
  }

  Color get bgColor {
    switch (type) {
      case NotificationType.predictionComplete:
        return AppColors.successBg;
      case NotificationType.reportGenerated:
        return AppColors.blueBg;
      case NotificationType.recoveryReminder:
        return AppColors.tealBg;
      case NotificationType.followUpReminder:
        return AppColors.purpleBg;
      case NotificationType.systemUpdate:
        return AppColors.warningBg;
    }
  }

  /// Human-readable relative time label.
  String get timeLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1d ago';
    return '${diff.inDays}d ago';
  }
}
