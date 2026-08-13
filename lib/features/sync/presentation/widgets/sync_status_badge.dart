import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sync_status.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';

class SyncStatusBadge extends StatelessWidget {
  final String userId;

  const SyncStatusBadge({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncBlocState>(
      builder: (context, state) {
        final status = state.status;

        Color badgeColor = Colors.green;
        IconData icon = Icons.cloud_done;
        String label = 'Synced';

        if (status.state == SyncState.syncing) {
          badgeColor = Colors.blue;
          icon = Icons.sync;
          label = 'Syncing...';
        } else if (status.state == SyncState.offline) {
          badgeColor = Colors.grey;
          icon = Icons.cloud_off;
          label = status.pendingQueueLength > 0
              ? 'Offline (${status.pendingQueueLength} pending)'
              : 'Offline';
        } else if (status.state == SyncState.error) {
          badgeColor = Colors.orange.shade800;
          icon = Icons.sync_problem;
          label = 'Sync Error';
        } else if (status.pendingQueueLength > 0) {
          badgeColor = Colors.blue;
          icon = Icons.cloud_upload;
          label = '${status.pendingQueueLength} pending';
        }

        return Tooltip(
          message: 'Click to trigger manual synchronization',
          child: InkWell(
            key: const Key('sync_status_badge'),
            onTap: () {
              context.read<SyncBloc>().add(TriggerManualSyncRequested(userId));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  status.state == SyncState.syncing
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                          ),
                        )
                      : Icon(icon, size: 14, color: badgeColor),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
