import 'package:json_annotation/json_annotation.dart';

part 'event_message_reply_content_model_v1.g.dart';

@JsonSerializable()
class EventMessageReplyContentModelV1 {
  final String userId;
  final String content;
  final bool isForward;
  final DateTime createTimestamp;

  EventMessageReplyContentModelV1({
    required this.userId,
    required this.content,
    required this.isForward,
    required this.createTimestamp,
  });

  factory EventMessageReplyContentModelV1.fromJson(Map<String, dynamic> json) {
    return _$EventMessageReplyContentModelV1FromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$EventMessageReplyContentModelV1ToJson(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventMessageReplyContentModelV1 &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode =>
      userId.hashCode ^
      content.hashCode ^
      isForward.hashCode ^
      createTimestamp.hashCode;
}
