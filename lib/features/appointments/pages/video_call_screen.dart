import 'package:flutter/material.dart';
import 'package:enx_uikit_flutter/enx_uikit_flutter.dart';
import '../../../data/models/appointment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _VideoCallScreenState extends State<VideoCallScreen> {
  EnxVideoView? _enxVideoView;
  bool _isCallActive = true;
  bool _isEndingCall = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  void _initializeVideoCall() {
    if (widget.token.isEmpty) {
      _handleCallEnd('Token is missing');
      return;
    }

    _enxVideoView = EnxVideoView(
      key: ValueKey('enx_${widget.roomId}_${DateTime.now().millisecondsSinceEpoch}'),
      token: widget.token,
      embedUrl: '',
      disconnect: (map) {
        print('🔴 Disconnected: $map');
        _handleCallEnd('Call ended');
      },
      connectError: (map) {
        print('❌ Connection error: $map');
        _handleCallEnd('Connection error');
      },
      onPageSlide: (eventName, isShow) {
        print('📄 Page slide: $eventName, isShow: $isShow');
      },
      onUserDataReceived: (map) {
        print('👤 User data received: $map');
      },
      connectToRoom: (map) {
        print('🔗 Connect to room called: $map');
      },
      onCaptureView: (base64bitmap) {
        print('📸 Screenshot captured');
      },
    );
  }

  void _handleCallEnd([String? reason]) {
    if (_isDisposed || !_isCallActive || _isEndingCall) return;
    _performEndCall(reason);
  }

  void _performEndCall([String? reason]) {
    if (_isEndingCall) return;
    setState(() => _isEndingCall = true);
    widget.callBloc.add(EndCall(widget.roomId, widget.callId));
  }

  void _callFullyEnded([String? reason]) {
    if (_isDisposed || !_isCallActive) return;
    setState(() => _isCallActive = false);
    if (reason != null && reason.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    // ✅ Give the SDK time to release resources before popping
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.callBloc,
      child: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded) {
            _callFullyEnded(state.message);
          } else if (state is CallError) {
            _callFullyEnded('Error ending call: ${state.error}');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                icon: _isEndingCall
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.call_end, color: Colors.red),
                onPressed: _isEndingCall ? null : () => _handleCallEnd('Call ended by user'),
              ),
            ],
          ),
          body: _isCallActive && _enxVideoView != null
              ? _enxVideoView!
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call_end, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  _isCallActive ? 'Loading...' : 'Call Ended',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isCallActive = false;
    _enxVideoView = null;
    super.dispose();
  }
}