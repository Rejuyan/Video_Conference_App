import 'package:flutter/material.dart';
import 'jitsi_meet_connector_stub.dart'
    if (dart.library.js_util) 'jitsi_meet_connector_web.dart'
    if (dart.library.io) 'jitsi_meet_connector_mobile.dart';

class CallScreen extends StatelessWidget {
  final String roomCode;
  final String roomName;
  final String displayName;
  final bool initialAudioMuted;
  final bool initialVideoMuted;

  const CallScreen({
    super.key,
    required this.roomCode,
    required this.roomName,
    required this.displayName,
    this.initialAudioMuted = false,
    this.initialVideoMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: buildJitsiView(
          context: context,
          roomCode: roomCode,
          roomName: roomName,
          displayName: displayName,
          initialAudioMuted: initialAudioMuted,
          initialVideoMuted: initialVideoMuted,
          onClosed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
