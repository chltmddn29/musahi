import 'package:flutter/material.dart';
import 'package:musahi/core/notifications/notification_service.dart';

class NotificationSyncStatus extends StatelessWidget {
  const NotificationSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: NotificationService.syncError,
      builder: (context, error, _) => error == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                Text(error),
                const TextButton(
                  onPressed: NotificationService.synchronizeSubscriptions,
                  child: Text('다시 시도'),
                ),
              ],
            ),
    );
  }
}
