import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_message_reply_content_model_v1.g.dart';

@JsonSerializable()
class EventMessageReplyContentModelV1 extends Equatable {
  const EventMessageReplyContentModelV1({
    required this.userId,
    required this.content,
    required this.isForward,
    required this.createTimestamp,
  });

  final String userId;
  final String content;
  final bool isForward;
  final DateTime createTimestamp;

  factory EventMessageReplyContentModelV1.fromJson(Map<String, dynamic> json) {
    return _$EventMessageReplyContentModelV1FromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$EventMessageReplyContentModelV1ToJson(this);
  }

  @override
  List<Object?> get props => [
    userId,
    content,
    isForward,
    createTimestamp,
  ];
}
