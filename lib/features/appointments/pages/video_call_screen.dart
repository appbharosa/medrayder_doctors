import 'package:flutter/material.dart';
import 'package:enx_uikit_flutter/enx_uikit_flutter.dart';
import '../../../core/app_urls/app_urls.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/network/dio_client.dart';
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
        _handleCallEnd('Call ended by remote');
      },
      connectError: (map) {
        print('❌ Connection error: $map');
        _handleCallEnd('Connection error: ${map['msg']}');
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

    // Attempt to use the BLoC, but catch if it's closed
    bool apiCalled = false;
    try {
      widget.callBloc.add(EndCall(widget.roomId, widget.callId));
      apiCalled = true;
      print('✅ EndCall event added to BLoC');
    } catch (e) {
      print('❌ BLoC is closed, falling back to direct API call: $e');
      // Fallback: call the API directly
      _callEndApiDirectly();
    }

    // Fallback: if the BLoC doesn't respond within 5 seconds, force close
    Future.delayed(const Duration(seconds: 5), () {
      if (_isCallActive && !_isDisposed) {
        _callFullyEnded('Call ended (timeout)');
      }
    });
  }

  // Direct API call as fallback
  Future<void> _callEndApiDirectly() async {
    print('🔴 END CALL REQUEST (direct): roomId=${widget.roomId}, callId=${widget.callId}');
    try {
      final dio = di.sl<DioClient>().dio;
      final response = await dio.delete(
        '${AppUrls.endCall}/${widget.roomId}',
        data: {'room_id': widget.roomId, 'call_id': widget.callId},
      );
      print('🔴 END CALL RESPONSE: ${response.statusCode}');
      _callFullyEnded('Call ended successfully');
    } catch (e) {
      print('❌ Direct API call failed: $e');
      _callFullyEnded('Call ended (fallback)');
    }
  }

  void _callFullyEnded([String? reason]) {
    if (_isDisposed || !_isCallActive) return;
    setState(() {
      _isCallActive = false;
      _isEndingCall = false;
    });
    if (mounted && reason != null && reason.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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