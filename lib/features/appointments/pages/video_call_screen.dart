import 'dart:async';

import 'package:enx_flutter_plugin/base.dart';
import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:enx_uikit_flutter/utilities/enx_setting.dart';
import 'package:flutter/material.dart';
import 'package:enx_uikit_flutter/enx_uikit_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/di/injection.dart' as di;
import '../../../data/models/appointment_model.dart';
import 'package:enx_flutter_plugin/enx_player_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../call_bloc/call_bloc.dart';
import '../call_bloc/call_event.dart';
import '../call_bloc/call_state.dart';



class VideoCallScreen extends StatefulWidget {
  final String token;
  final String roomId;
  final String callId;
  final AppointmentModel appointment;

  const VideoCallScreen({
    Key? key,
    required this.token,
    required this.roomId,
    required this.callId,
    required this.appointment,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with WidgetsBindingObserver {
  bool _permissionsGranted = false;
  bool _permissionChecked = false;
  bool _isEndingCall = false;
  bool _isSpeakerOn = true;
  bool _isRoomConnected = false;
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;
  bool _localVideoRendered = false;
  int? _localStreamId;
  int? _remoteStreamId;
  Timer? _endCallTimeoutTimer;
  late final CallBloc _callBloc;
  bool _hasDisconnected = false;

  @override
  void initState() {
    super.initState();
    _callBloc = di.sl<CallBloc>();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
    _addEnxRtcEventHandlers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _endCallTimeoutTimer?.cancel();
    _isEndingCall = true;
    // Only disconnect if not already done and room was connected
    if (!_hasDisconnected && _isRoomConnected) {
      try { EnxRtc.disconnect(); } catch (_) {}
      _hasDisconnected = true;
    }
    super.dispose();
  }

  // ─── Permissions ──────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    final result = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final camera = result[Permission.camera]?.isGranted ?? false;
    final mic = result[Permission.microphone]?.isGranted ?? false;

    if (!mounted) return;

    setState(() {
      _permissionsGranted = camera && mic;
      _permissionChecked = true;
    });

    if (_permissionsGranted) {
      _joinRoom();
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Permissions Required"),
        content: const Text("Please allow camera and microphone permissions."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // ─── Join Room ──────────────────────────────────────────────
  Future<void> _joinRoom() async {
    if (_isEndingCall) return;

    Map<String, dynamic> videoSize = {
      'minWidth': 320,
      'minHeight': 180,
      'maxWidth': 1280,
      'maxHeight': 720,
    };

    Map<String, dynamic> localInfo = {
      'audio': true,
      'video': true,
      'data': true,
      'framerate': 30,
      'maxVideoBW': 1500,
      'minVideoBW': 150,
      'audioMuted': _isAudioMuted,
      'videoMuted': _isVideoMuted,
      'name': widget.appointment.patientName,
      'videoSize': videoSize,
    };

    Map<String, dynamic> roomInfo = {
      'allow_reconnect': true,
      'number_of_attempts': 3,
      'timeout_interval': 15,
    };

    try {
      await EnxRtc.joinRoom(widget.token, localInfo, roomInfo, []);
      debugPrint("✅ Joined room");
      if (mounted) setState(() => _isRoomConnected = true);
      EnxRtc.publish();
    } catch (e) {
      debugPrint("❌ Join error: $e");
      if (mounted) _endCall();
    }
  }

  // ─── EnableX Events ──────────────────────────────────────────
  void _addEnxRtcEventHandlers() {
    EnxRtc.onRoomConnected = (map) {
      debugPrint("Room connected: $map");
      if (mounted) {
        setState(() => _isRoomConnected = true);
        EnxRtc.publish();
      }
    };

    EnxRtc.onPublishedStream = (map) {
      debugPrint("Published: $map");
      final id = _parseInt(map['streamId']);
      if (id != null) {
        _localStreamId = id;
        EnxRtc.setupVideo(0, 0, true, 300, 200);
        setState(() => _localVideoRendered = true);
      }
    };

    EnxRtc.onStreamAdded = (map) {
      debugPrint("Stream added: $map");
      final id = _parseInt(map['streamId']);
      if (id != null && id != _localStreamId) {
        EnxRtc.subscribe(id.toString());
      }
    };

    EnxRtc.onSubscribedStream = (map) {
      debugPrint("Subscribed: $map");
      final id = _parseInt(map['streamId']);
      if (id != null && id != _localStreamId) {
        setState(() => _remoteStreamId = id);
      }
    };

    EnxRtc.onActiveTalkerList = (map) {
      final list = map['activeList'] as List?;
      if (list != null) {
        for (final item in list) {
          final id = _parseInt(item['streamId']);
          if (id != null && id != _localStreamId && _remoteStreamId == null) {
            setState(() => _remoteStreamId = id);
          }
        }
      }
    };

    EnxRtc.onRoomDisConnected = (map) {
      debugPrint("Disconnected: $map");
      _hasDisconnected = true;
      _isRoomConnected = false;
      if (mounted) _endCall();
    };

    EnxRtc.onRoomError = (map) {
      debugPrint("Room error: $map");
      if (mounted) _endCall();
    };

    EnxRtc.onAudioEvent = (map) {
      if (!mounted) return;
      setState(() => _isAudioMuted = map['msg'].toString() == "Audio Off");
    };

    EnxRtc.onVideoEvent = (map) {
      if (!mounted) return;
      setState(() => _isVideoMuted = map['msg'].toString() == "Video Off");
    };

    EnxRtc.onUserDisConnected = (map) {
      final id = _parseInt(map['streamId']);
      if (id != null && id == _remoteStreamId) {
        setState(() => _remoteStreamId = null);
      }
    };
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // ─── End Call ────────────────────────────────────────────────
  void _endCall() {
    if (_isEndingCall) return;
    setState(() => _isEndingCall = true);

    // Add the EndCall event to the BLoC
    try {
      _callBloc.add(EndCall(widget.roomId, widget.callId));
    } catch (e) {
      debugPrint("BLoC end call error: $e");
    }

    // Disconnect from SDK only if room is connected and not already disconnected
    if (!_hasDisconnected && _isRoomConnected) {
      try {
        EnxRtc.disconnect();
        _hasDisconnected = true;
        _isRoomConnected = false;
      } catch (e) {
        debugPrint("Disconnect error: $e");
      }
    }

    // Force pop after timeout (3 seconds)
    _endCallTimeoutTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _callFullyEnded() {
    _endCallTimeoutTimer?.cancel();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ─── Controls ─────────────────────────────────────────────────
  void _toggleAudio() {
    EnxRtc.muteSelfAudio(!_isAudioMuted);
    setState(() => _isAudioMuted = !_isAudioMuted);
  }

  void _toggleVideo() {
    EnxRtc.muteSelfVideo(!_isVideoMuted);
    setState(() => _isVideoMuted = !_isVideoMuted);
  }

  Future<void> _toggleCamera() async {
    try { await EnxRtc.switchCamera(); } catch (e) { debugPrint("Camera switch error: $e"); }
  }

  void _toggleSpeaker() => setState(() => _isSpeakerOn = !_isSpeakerOn);

  // ─── UI ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_permissionsGranted) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Permissions Required", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return BlocProvider.value(
      value: _callBloc,
      child: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded || state is CallError) {
            _callFullyEnded();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Remote video
              if (_remoteStreamId != null)
                Positioned.fill(
                  child: EnxPlayerWidget(
                    _remoteStreamId!,
                    local: false,
                    width: MediaQuery.of(context).size.width.toInt(),
                    height: MediaQuery.of(context).size.height.toInt(),
                    mScalingType: ScalingType.SCALE_ASPECT_FIT,
                  ),
                )
              else
                const Center(
                  child: Text(
                    "Waiting for participant...",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

              // Local preview
              if (_isRoomConnected && _localStreamId != null)
                Positioned(
                  top: 70,
                  right: 16,
                  child: Container(
                    width: 120,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: EnxPlayerWidget(
                        _localStreamId!,
                        local: true,
                        width: 120,
                        height: 170,
                        mScalingType: ScalingType.SCALE_ASPECT_BALANCED,
                      ),
                    ),
                  ),
                ),

              // Top bar
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _endCall,
                      ),
                      Text(
                        widget.appointment.patientName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // ✅ Only one end-call button – red
                      IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.red, size: 32),
                        onPressed: _endCall,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom controls (no duplicate red button)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _controlButton(Icons.mic, _isAudioMuted, _toggleAudio),
                    _controlButton(Icons.videocam, _isVideoMuted, _toggleVideo),
                    // Removed the call_end button from here (only top bar has it)
                    _controlButton(Icons.switch_camera, false, _toggleCamera),
                    _controlButton(Icons.volume_up, _isSpeakerOn, _toggleSpeaker),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, bool isActive, VoidCallback onTap, {bool isRed = false}) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.black54,
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
        ),
        onPressed: onTap,
      ),
    );
  }
}