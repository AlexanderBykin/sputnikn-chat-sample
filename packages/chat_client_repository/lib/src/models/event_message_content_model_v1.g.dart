// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_message_content_model_v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventMessageContentModelV1 _$EventMessageContentModelV1FromJson(
        Map<String, dynamic> json) =>
    EventMessageContentModelV1(
      replyContent: json['replyContent'] == null
          ? null
          : EventMessageReplyContentModelV1.fromJson(
              json['replyContent'] as Map<String, dynamic>),
      content: json['content'] as String,
    );

Map<String, dynamic> _$EventMessageContentModelV1ToJson(
        EventMessageContentModelV1 instance) =>
    <String, dynamic>{
      'replyContent': instance.replyContent?.toJson(),
      'content': instance.content,
    };
