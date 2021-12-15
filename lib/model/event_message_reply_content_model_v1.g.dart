// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_message_reply_content_model_v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventMessageReplyContentModelV1 _$EventMessageReplyContentModelV1FromJson(
        Map<String, dynamic> json) =>
    EventMessageReplyContentModelV1(
      userId: json['userId'] as String,
      content: json['content'] as String,
      isForward: json['isForward'] as bool,
      createTimestamp: DateTime.parse(json['createTimestamp'] as String),
    );

Map<String, dynamic> _$EventMessageReplyContentModelV1ToJson(
        EventMessageReplyContentModelV1 instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'content': instance.content,
      'isForward': instance.isForward,
      'createTimestamp': instance.createTimestamp.toIso8601String(),
    };
