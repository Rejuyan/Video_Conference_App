class JitsiConfig {
  /// The Jitsi domain to connect to.
  /// - For public demo: "meet.jit.si" (shows a 5-minute disconnect warning in iframe embeds)
  /// - For Jitsi as a Service (JaaS): "8x8.vc"
  /// - For self-hosted: "your-jitsi-domain.com"
  static const String jitsiDomain = "meet.jit.si";

  /// JaaS App ID (Only required if you are using 8x8 Jitsi as a Service)
  /// Leave empty if you are using a standard public or self-hosted server.
  static const String jaasAppId = "";

  /// Resolved Server URL
  static String get serverUrl => "https://$jitsiDomain";

  /// Resolved External API script URL
  static String get externalApiScriptUrl => "https://$jitsiDomain/external_api.js";

  /// Formats the room name for the Jitsi client, appending JaaS App ID if active
  static String getFormattedRoom(String roomCode) {
    if (jaasAppId.isNotEmpty) {
      return "$jaasAppId/$roomCode";
    }
    return roomCode;
  }
}
