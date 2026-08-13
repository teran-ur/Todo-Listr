import 'package:equatable/equatable.dart';

enum SyncOperation { create, update, delete }

enum SyncEntityType { task, group, settings }

class SyncQueueItem extends Equatable {
  final String queueId;
  final String userId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;
  final String? lastError;

  const SyncQueueItem({
    required this.queueId,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
    this.lastError,
  });

  SyncQueueItem copyWith({
    String? queueId,
    String? userId,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperation? operation,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    int? retryCount,
    String? lastError,
  }) {
    return SyncQueueItem(
      queueId: queueId ?? this.queueId,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'queueId': queueId,
      'userId': userId,
      'entityType': entityType.name,
      'entityId': entityId,
      'operation': operation.name,
      'payload': payload,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      queueId: map['queueId'] as String,
      userId: map['userId'] as String,
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == map['entityType'],
        orElse: () => SyncEntityType.task,
      ),
      entityId: map['entityId'] as String,
      operation: SyncOperation.values.firstWhere(
        (e) => e.name == map['operation'],
        orElse: () => SyncOperation.create,
      ),
      payload: (map['payload'] as Map<String, dynamic>?) ?? const {},
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      retryCount: map['retryCount'] as int? ?? 0,
      lastError: map['lastError'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        queueId,
        userId,
        entityType,
        entityId,
        operation,
        payload,
        timestamp,
        retryCount,
        lastError,
      ];
}
