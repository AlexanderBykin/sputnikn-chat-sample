import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'event_message_reply_content_model_v1.dart';

part 'event_message_content_model_v1.g.dart';

@JsonSerializable(explicitToJson: true)
class EventMessageContentModelV1 {
  final version = 1;
  final EventMessageReplyContentModelV1? replyContent;
  final String content;

  EventMessageContentModelV1({
    this.replyContent,
    required this.content,
  });

  factory EventMessageContentModelV1.fromJson(Map<String, dynamic> json) {
    return _$EventMessageContentModelV1FromJson(json);
  }

  factory EventMessageContentModelV1.deserialize(String value) {
    return EventMessageContentModelV1.fromJson(json.decode(value));
  }

  bool get isEmpty => content.isEmpty && replyContent?.content.isEmpty == true;

  Map<String, dynamic> toJson() {
    return _$EventMessageContentModelV1ToJson(this);
  }

  String serialize() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventMessageContentModelV1 &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode => (replyContent?.hashCode ?? 0) ^ content.hashCode;
}
