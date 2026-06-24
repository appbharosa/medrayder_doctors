import 'dart:async';

import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:enx_uikit_flutter/utilities/enx_setting.dart';
import 'package:flutter/material.dart';
import 'package:enx_uikit_flutter/enx_uikit_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/di/injection.dart' as di;
import '../../../data/models/appointment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/call_repository.dart';
import '../call_bloc/call_bloc.dart';
import '../call_bloc/call_event.dart';
import '../call_bloc/call_state.dart';


class VideoCallScreen extends StatefulWidget {
  final String token;
  final String roomId;
  final String callId;
  final AppointmentModel appointment;
  final CallBloc callBloc;

  const VideoCallScreen({
    Key? key,
    required this.token,
    required this.roomId,
    required this.callId,
    required this.appointment,
    required this.callBloc,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with WidgetsBindingObserver {
  EnxVideoView? _enxVideoView;
  bool _isCallActive = true;
  bool _isEndingCall = false;
  bool _isDisposed = false;
  bool _permissionsGranted = false;
  bool _permissionChecked = false;
  bool _isSpeakerOn = true;
  late final CallRepository _callRepository;
  bool _viewCreated = false;

  @override
  void initState() {
    super.initState();
    _callRepository = di.sl<CallRepository>();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _isCallActive = false;
    try { EnxRtc.disconnect(); } catch (_) {}
    _enxVideoView = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Optional: handle resume
    }
  }

  // ─── Permissions ──────────────────────────────────────────────
  Future<void> _checkPermissions() async {
    try {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
      final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

      if (cameraGranted && micGranted) {
        if (!mounted) return;
        setState(() {
          _permissionsGranted = true;
          _permissionChecked = true;
        });
        _createVideoView();
      } else {
        if (!mounted) return;
        setState(() {
          _permissionsGranted = false;
          _permissionChecked = true;
        });
        _showPermissionDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _permissionsGranted = false;
        _permissionChecked = true;
      });
    }
  }

  void _showPermissionDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Camera and microphone permissions are needed for video calls.\n\n'
              'Please grant them in your device settings and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ─── Create EnableX View (once) ──────────────────────────────
  void _createVideoView() {
    if (_viewCreated || widget.token.isEmpty) {
      if (widget.token.isEmpty) _handleCallEnd('Token missing');
      return;
    }

    try {
      _enxVideoView = EnxVideoView(
        // Stable key to avoid recreation
        key: ValueKey('enx_${widget.roomId}_${widget.callId}'),
        token: widget.token,
        embedUrl: '',
        disconnect: (map) {
          debugPrint('Disconnected: $map');
          if (!_isDisposed) {
            _callFullyEnded('Call ended');
          }
        },
        connectError: (map) {
          debugPrint('Connect error: $map');
          if (!_isDisposed) {
            _handleCallEnd(map['msg']?.toString() ?? 'Connection failed');
          }
        },
        connectToRoom: (map) {
          debugPrint('Connected successfully');
          // Do NOT call setState here – keeps UI stable
        },
        onPageSlide: (_, __) {},
        onUserDataReceived: (_) {},
        onCaptureView: (_) {},
      );

      _viewCreated = true;
      // Only setState once to show the view
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('EnableX init error: $e');
      _handleCallEnd('Video initialization failed');
    }
  }

  // ─── Speaker Toggle ───────────────────────────────────────────
  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    debugPrint('Speaker: ${_isSpeakerOn ? 'ON' : 'OFF'}');
  }

  // ─── End Call Logic ──────────────────────────────────────────
  void _handleCallEnd([String? reason]) {
    if (_isDisposed || !_isCallActive || _isEndingCall) return;
    _performEndCall(reason);
  }

  void _performEndCall([String? reason]) {
    if (_isEndingCall) return;
    setState(() => _isEndingCall = true);

    try {
      widget.callBloc.add(EndCall(widget.roomId, widget.callId));
    } catch (_) {
      _callEndApiViaRepository();
    }

    Future.delayed(const Duration(seconds: 566), () {
      if (_isCallActive && !_isDisposed) {
        _callFullyEnded('Call ended (timeout)');
      }
    });
  }

  Future<void> _callEndApiViaRepository() async {
    try {
      await _callRepository.endCall(widget.roomId, widget.callId);
      _callFullyEnded('Call ended');
    } catch (_) {
      _callFullyEnded('Call ended');
    }
  }

  void _callFullyEnded([String? reason]) {
    if (_isDisposed || !_isCallActive) return;
    setState(() {
      _isCallActive = false;
      _isEndingCall = false;
    });
    try { EnxRtc.disconnect(); } catch (_) {}

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ─── UI ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_permissionsGranted) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.no_photography, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Permissions required', style: TextStyle(color: Colors.grey, fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: widget.callBloc,
      child: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded || state is CallError) {
            _callFullyEnded();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => _handleCallEnd('Call ended by user'),
            ),
            title: Text(
              widget.appointment.patientName,
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: _toggleSpeaker,
              ),
              IconButton(
                icon: _isEndingCall
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.call_end, color: Colors.red),
                onPressed: _isEndingCall ? null : () => _handleCallEnd('Call ended by user'),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: _enxVideoView != null
                ? SizedBox.expand(child: _enxVideoView!)
                : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Joining Room...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}