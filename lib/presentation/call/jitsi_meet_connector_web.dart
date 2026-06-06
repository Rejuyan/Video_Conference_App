import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:vmeet/core/config/jitsi_config.dart';
import 'package:vmeet/core/theme/theme.dart';

Widget buildJitsiView({
  required BuildContext context,
  required String roomCode,
  required String roomName,
  required String displayName,
  required bool initialAudioMuted,
  required bool initialVideoMuted,
  required VoidCallback onClosed,
}) {
  return _WebJitsiWidget(
    roomCode: roomCode,
    roomName: roomName,
    displayName: displayName,
    initialAudioMuted: initialAudioMuted,
    initialVideoMuted: initialVideoMuted,
    onClosed: onClosed,
  );
}

class _WebJitsiWidget extends StatefulWidget {
  final String roomCode;
  final String roomName;
  final String displayName;
  final bool initialAudioMuted;
  final bool initialVideoMuted;
  final VoidCallback onClosed;

  const _WebJitsiWidget({
    required this.roomCode,
    required this.roomName,
    required this.displayName,
    required this.initialAudioMuted,
    required this.initialVideoMuted,
    required this.onClosed,
  });

  @override
  State<_WebJitsiWidget> createState() => _WebJitsiWidgetState();
}

class _WebJitsiWidgetState extends State<_WebJitsiWidget> {
  late final String _viewId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viewId = 'jitsi-meet-view-${DateTime.now().millisecondsSinceEpoch}';
    _loadJitsiScriptAndSetup();
  }

  void _loadJitsiScriptAndSetup() {
    // If Jitsi external API is already loaded in window, run setup directly
    if (js.context['JitsiMeetExternalAPI'] != null) {
      _setupWebJitsi();
      return;
    }

    // Otherwise, dynamically inject the script tag based on our config domain
    final script = html.ScriptElement()
      ..src = JitsiConfig.externalApiScriptUrl
      ..type = 'application/javascript'
      ..async = true;

    script.onLoad.listen((_) {
      if (mounted) {
        _setupWebJitsi();
      }
    });

    html.document.head!.append(script);
  }

  void _setupWebJitsi() {
    final elementId = 'jitsi-iframe-dom-${DateTime.now().millisecondsSinceEpoch}';

    // Register web platform view factory
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final element = html.DivElement()
          ..id = elementId
          ..style.width = '100%'
          ..style.height = '100%';
        return element;
      },
    );

    // Register callback for when user hangs up inside Jitsi meeting
    bool isClosed = false;
    js.context['onJitsiMeetingClose'] = () {
      if (!isClosed) {
        isClosed = true;
        widget.onClosed();
      }
    };

    // Delay calling the JS initialization function slightly to ensure the view element is loaded in the DOM
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      
      final formattedRoom = JitsiConfig.getFormattedRoom(widget.roomCode);

      js.context.callMethod('joinJitsiMeetingWeb', [
        JitsiConfig.jitsiDomain,
        elementId,
        formattedRoom,
        widget.displayName,
        widget.roomName,
        widget.initialAudioMuted,
        widget.initialVideoMuted,
      ]);
    });

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: VMeetTheme.primary),
      );
    }
    return HtmlElementView(viewType: _viewId);
  }
}
