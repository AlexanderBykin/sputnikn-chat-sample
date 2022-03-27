class AppConfig {
  const AppConfig({
    required this.serverMediaUrl,
    required this.serverChatWsUrl,
  });

  final String serverMediaUrl;
  final String serverChatWsUrl;
}
