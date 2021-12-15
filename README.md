# SputnikN Chat sample
A Flutter example of a chat application in which uses the SputnikN Client SDK

### JSON code generation
Project based on `json_serializable` library to help generate boilerplate transport messages source code, this approach is recommended for use in large projects.<br>
For generation we should annotate some serializable class with annotation `@JsonSerializable()`.<br>
More can be found [here](https://pub.dev/packages/json_serializable)

### Generators
General: `flutter pub run build_runner build --delete-conflicting-outputs`<br>
Gen localizations: `flutter gen-l10n`<br>
Gen AppIcons: `flutter pub run flutter_launcher_icons:main`
