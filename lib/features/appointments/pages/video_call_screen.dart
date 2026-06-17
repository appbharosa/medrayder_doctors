import 'package:flutter/material.dart';
import 'package:enx_uikit_flutter/enx_uikit_flutter.dart';
import '../../../data/models/appointment_model.dart';

class VideoCallScreen extends StatefulWidget {
  final String token;
  final String roomId;
  final AppointmentModel appointment;

  const VideoCallScreen({
    super.key,
    required this.token,
    required this.roomId,
    required this.appointment,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late EnxVideoView _enxVideoView;
  bool _isCallActive = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  void _initializeVideoCall() {
    // Create the EnableX video view with all required parameters
    _enxVideoView = EnxVideoView(
      token: widget.token,
      embedUrl: '', // not used, pass empty string
      disconnect: (map) {
        // Handle disconnect
        print('🔴 Disconnected: $map');
        _handleCallEnd();
      },
      connectError: (map) {
        // Handle connection error
        print('❌ Connection error: $map');
        _handleCallEnd();
      },
      onPageSlide: (eventName, isShow) {
        // Handle page slide events (optional)
        print('📄 Page slide: $eventName, isShow: $isShow');
      },
      onUserDataReceived: (map) {
        // Handle user data received (optional)
        print('👤 User data received: $map');
      },
      connectToRoom: (map) {
        // This is called when the widget wants to connect.
        // Since we already have the token, we can ignore or use it.
        print('🔗 Connect to room called: $map');
        // If needed, you can trigger a connection here.
      },
      onCaptureView: (base64bitmap) {
        // Handle screenshot capture (optional)
        print('📸 Screenshot captured');
      },
    );
  }

  void _handleCallEnd() {
    if (_isCallActive) {
      setState(() {
        _isCallActive = false;
      });
      // Return to previous screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _handleCallEnd,
        ),
        title: Text(
          widget.appointment.patientName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _handleCallEnd,
          ),
        ],
      ),
      body: _isCallActive
          ? _enxVideoView
          : const Center(
        child: Text(
          'Call Ended',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Note: EnxVideoView handles its own cleanup via the controller.
    super.dispose();
  }
}