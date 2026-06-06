import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:vmeet/core/config/jitsi_config.dart';
import 'package:vmeet/core/theme/theme.dart';
import 'package:vmeet/core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildJitsiView({
  required BuildContext context,
  required String roomCode,
  required String roomName,
  required String displayName,
  required bool initialAudioMuted,
  required bool initialVideoMuted,
  required VoidCallback onClosed,
}) {
  return _MobileJitsiWidget(
    roomCode: roomCode,
    roomName: roomName,
    displayName: displayName,
    initialAudioMuted: initialAudioMuted,
    initialVideoMuted: initialVideoMuted,
    onClosed: onClosed,
  );
}

class _MobileJitsiWidget extends StatefulWidget {
  final String roomCode;
  final String roomName;
  final String displayName;
  final bool initialAudioMuted;
  final bool initialVideoMuted;
  final VoidCallback onClosed;

  const _MobileJitsiWidget({
    required this.roomCode,
    required this.roomName,
    required this.displayName,
    required this.initialAudioMuted,
    required this.initialVideoMuted,
    required this.onClosed,
  });

  @override
  State<_MobileJitsiWidget> createState() => _MobileJitsiWidgetState();
}

class _MobileJitsiWidgetState extends State<_MobileJitsiWidget> {
  @override
  void initState() {
    super.initState();
    _setupMobileJitsi();
  }

  void _setupMobileJitsi() async {
    try {
      final jitsiMeet = JitsiMeet();
      
      final formattedRoom = JitsiConfig.getFormattedRoom(widget.roomCode);

      final options = JitsiMeetConferenceOptions(
        room: formattedRoom,
        serverURL: JitsiConfig.serverUrl,
        configOverrides: {
          "startWithAudioMuted": widget.initialAudioMuted,
          "startWithVideoMuted": widget.initialVideoMuted,
          "subject": widget.roomName,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: widget.displayName,
        ),
      );

      // Connect and join the Jitsi conference room
      await jitsiMeet.join(options);
      
      // Notify parent when Jitsi conference concludes/closes
      widget.onClosed();
    } catch (e) {
      debugPrint("Error launching Jitsi Mobile SDK: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not join meeting: $e"),
            backgroundColor: VMeetTheme.destructive,
          ),
        );
      }
      widget.onClosed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: VMeetTheme.primary),
            const SizedBox(height: 20),
            Text(
              "Connecting to Jitsi Room...",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Launching native meeting overlay...",
              style: GoogleFonts.outfit(color: VMeetTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
