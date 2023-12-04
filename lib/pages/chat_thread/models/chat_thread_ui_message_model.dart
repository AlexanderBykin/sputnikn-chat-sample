import 'package:equatable/equatable.dart';

abstract class ChatThreadUIMessageModelBase extends Equatable {
  const ChatThreadUIMessageModelBase(
    this.eventId,
    this.timestamp,
  );

  final String eventId;
  final DateTime timestamp;

  Map<String, dynamic> toMap();

  @override
  List<Object?> get props => [
        eventId,
        timestamp,
      ];
}
