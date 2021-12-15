import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'event_system_content_model_v1.g.dart';

enum EventSystemActionType {
  unknown,
  @JsonValue("change_avatar")
  changeAvatar,
  @JsonValue("change_title")
  changeTitle,
  @JsonValue("user_invite")
  userInvite,
  @JsonValue("user_join")
  userJoin,
  @JsonValue("user_leave")
  userLeave,
  @JsonValue("user_kick")
  userKick,
  @JsonValue("user_ban")
  userBan,
}

@JsonSerializable()
class EventSystemContentModelV1 {
  @JsonKey(unknownEnumValue: EventSystemActionType.unknown)
  final EventSystemActionType action;
  final String srcUserId;
  final String? dstUserId;
  final String? fromContent;
  final String? toContent;

  EventSystemContentModelV1({
    required this.action,
    required this.srcUserId,
    this.dstUserId,
    this.fromContent,
    this.toContent,
  });

  factory EventSystemContentModelV1.fromJson(Map<String, dynamic> json) {
    return _$EventSystemContentModelV1FromJson(json);
  }

  factory EventSystemContentModelV1.deserialize(String value) {
    return EventSystemContentModelV1.fromJson(json.decode(value));
  }

  String buildContent() => _$EventSystemActionTypeEnumMap[action] ?? "";

  Map<String, dynamic> toJson() {
    return _$EventSystemContentModelV1ToJson(this);
  }
}
