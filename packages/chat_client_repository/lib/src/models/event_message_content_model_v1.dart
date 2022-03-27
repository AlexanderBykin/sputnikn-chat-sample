import 'dart:convert';

import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_message_content_model_v1.g.dart';

@JsonSerializable(explicitToJson: true)
class EventMessageContentModelV1 extends Equatable {
  const EventMessageContentModelV1({
    this.replyContent,
    required this.content,
  });

  final version = 1;
  final EventMessageReplyContentModelV1? replyContent;
  final String content;

  factory EventMessageContentModelV1.fromJson(Map<String, dynamic> json) {
    return _$EventMessageContentModelV1FromJson(json);
  }

  factory EventMessageContentModelV1.deserialize(String value) {
    return EventMessageContentModelV1.fromJson(
      json.decode(value) as Map<String, dynamic>,
    );
  }

  bool get isEmpty => content.isEmpty && replyContent?.content.isEmpty == true;

  Map<String, dynamic> toJson() {
    return _$EventMessageContentModelV1ToJson(this);
  }

  String serialize() => json.encode(toJson());

  @override
  List<Object?> get props => [
        replyContent,
        content,
      ];
}
