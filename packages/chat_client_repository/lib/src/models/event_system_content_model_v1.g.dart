// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_system_content_model_v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSystemContentModelV1 _$EventSystemContentModelV1FromJson(
        Map<String, dynamic> json) =>
    EventSystemContentModelV1(
      action: $enumDecode(_$EventSystemActionTypeEnumMap, json['action'],
          unknownValue: EventSystemActionType.unknown),
      srcUserId: json['srcUserId'] as String,
      dstUserId: json['dstUserId'] as String?,
      fromContent: json['fromContent'] as String?,
      toContent: json['toContent'] as String?,
    );

Map<String, dynamic> _$EventSystemContentModelV1ToJson(
        EventSystemContentModelV1 instance) =>
    <String, dynamic>{
      'action': _$EventSystemActionTypeEnumMap[instance.action],
      'srcUserId': instance.srcUserId,
      'dstUserId': instance.dstUserId,
      'fromContent': instance.fromContent,
      'toContent': instance.toContent,
    };

const _$EventSystemActionTypeEnumMap = {
  EventSystemActionType.unknown: 'unknown',
  EventSystemActionType.changeAvatar: 'change_avatar',
  EventSystemActionType.changeTitle: 'change_title',
  EventSystemActionType.userInvite: 'user_invite',
  EventSystemActionType.userJoin: 'user_join',
  EventSystemActionType.userLeave: 'user_leave',
  EventSystemActionType.userKick: 'user_kick',
  EventSystemActionType.userBan: 'user_ban',
};
