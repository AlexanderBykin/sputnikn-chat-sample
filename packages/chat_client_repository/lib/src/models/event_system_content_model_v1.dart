import 'dart:convert';

import 'package:chat_client_repository/chat_client_repository.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_system_content_model_v1.g.dart';

@JsonSerializable()
class EventSystemContentModelV1 {
  const EventSystemContentModelV1({
    required this.action,
    required this.srcUserId,
    this.dstUserId,
    this.fromContent,
    this.toContent,
  });

  @JsonKey(unknownEnumValue: EventSystemActionType.unknown)
  final EventSystemActionType action;
  final String srcUserId;
  final String? dstUserId;
  final String? fromContent;
  final String? toContent;

  factory EventSystemContentModelV1.fromJson(Map<String, dynamic> json) {
    return _$EventSystemContentModelV1FromJson(json);
  }

  factory EventSystemContentModelV1.deserialize(String value) {
    return EventSystemContentModelV1.fromJson(
      json.decode(value) as Map<String, dynamic>,
    );
  }

  String buildContent() => _$EventSystemActionTypeEnumMap[action] ?? '';

  Map<String, dynamic> toJson() {
    return _$EventSystemContentModelV1ToJson(this);
  }
}
