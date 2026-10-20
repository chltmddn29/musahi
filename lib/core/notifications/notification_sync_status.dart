import 'package:flutter/material.dart';
import 'package:musahi/core/notifications/notification_service.dart';
import 'package:musahi/l10n/app_localizations.dart';

class NotificationSyncStatus extends StatelessWidget {
  const NotificationSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: NotificationService.syncFailed,
      builder: (context, failed, _) => !failed
          ? const SizedBox.shrink()
          : Column(
              children: [
                Text(l10n.notificationSyncFailed),
                TextButton(
                  onPressed: NotificationService.synchronizeSubscriptions,
                  child: Text(l10n.retry),
                ),
              ],
            ),
    );
  }
}
