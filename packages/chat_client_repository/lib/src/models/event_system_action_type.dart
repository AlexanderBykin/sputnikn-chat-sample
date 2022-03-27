import 'package:json_annotation/json_annotation.dart';

enum EventSystemActionType {
  unknown,
  @JsonValue('change_avatar')
  changeAvatar,
  @JsonValue('change_title')
  changeTitle,
  @JsonValue('user_invite')
  userInvite,
  @JsonValue('user_join')
  userJoin,
  @JsonValue('user_leave')
  userLeave,
  @JsonValue('user_kick')
  userKick,
  @JsonValue('user_ban')
  userBan,
}