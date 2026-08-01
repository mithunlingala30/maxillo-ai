import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<AppState>().notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        titleTextStyle: const TextStyle(
            color: AppColors.heading, fontWeight: FontWeight.w700, fontSize: 17),
        iconTheme: const IconThemeData(color: AppColors.heading),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => context.read<AppState>().clearNotifications(),
              child: const Text('Clear all',
                  style: TextStyle(fontSize: 13, color: AppColors.primaryBlue)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, i) {
                final item = notifications[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SoftCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: item.bgColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(item.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.5)),
                                  ),
                                  if (!item.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(item.body,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.subText)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(item.timeLabel,
                            style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.placeholder)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.softGrey,
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.notifications_none_rounded,
                size: 36, color: AppColors.placeholder),
          ),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.heading)),
          const SizedBox(height: 6),
          const Text(
            'Notifications will appear here after\nyou run a prediction or generate a report.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.subText),
          ),
        ],
      ),
    );
  }
}
