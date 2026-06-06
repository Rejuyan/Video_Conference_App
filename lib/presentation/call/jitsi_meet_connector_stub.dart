import 'package:flutter/material.dart';

Widget buildJitsiView({
  required BuildContext context,
  required String roomCode,
  required String roomName,
  required String displayName,
  required bool initialAudioMuted,
  required bool initialVideoMuted,
  required VoidCallback onClosed,
}) {
  return const Center(child: Text("Jitsi Meet not supported on this platform"));
}
