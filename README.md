# SputnikN Chat sample
A Flutter example of a chat application in which uses the SputnikN Client SDK

### Repositories overview
The chat ecosystem consists of several dependent repositories:<br>
- [Database code gen](https://github.com/AlexanderShniperson/sputnikn-chat-codegen-db) - Class generator according to the DB schema, the DB schema is attached;<br>
- [Transport code gen](https://github.com/AlexanderShniperson/sputnikn-chat-codegen-proto) - Transport message generator between Client and Server;<br>
- [Chat server](https://github.com/AlexanderShniperson/sputnikn-chat-server) - High loaded and scalable chat server written with Akka/Ktor/Rest/WebSocket/Protobuf/Jooq;<br>
- [Client chat SDK](https://github.com/AlexanderShniperson/sputnikn-chat-client) - SDK client chat library for embedding in third-party applications written in Flutter;<br>
- [Sample application](https://github.com/AlexanderShniperson/sputnikn-chat-sample) - An example of a chat application using the SDK client library written with Flutter;<br>

### JSON code generation
Project based on `json_serializable` library to help generate boilerplate transport messages source code, this approach is recommended for use in large projects.<br>
For generation we should annotate some serializable class with annotation `@JsonSerializable()`.<br>
More can be found [here](https://pub.dev/packages/json_serializable)

### Generators
General: `flutter pub run build_runner build --delete-conflicting-outputs`<br>
Gen localizations: `flutter gen-l10n`<br>
Gen AppIcons: `flutter pub run flutter_launcher_icons:main`
