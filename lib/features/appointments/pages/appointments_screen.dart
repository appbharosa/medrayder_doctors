import 'package:doctors/features/appointments/pages/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/manager/user_manager.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/create_room_request_model.dart';
import '../../../data/models/join_room_request_model.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import '../call_bloc/call_bloc.dart';
import '../call_bloc/call_event.dart';
import '../call_bloc/call_state.dart';


class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final AppointmentBloc _appointmentBloc;
  late final CallBloc _callBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _appointmentBloc = di.sl<AppointmentBloc>();
    _callBloc = di.sl<CallBloc>();
    final user = UserManager().currentUser;
    if (user != null) {
      _appointmentBloc.add(FetchAppointments(type: user.type));
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      final state = _appointmentBloc.state;
      if (state is AppointmentLoaded && state.hasMore) {
        final user = UserManager().currentUser;
        if (user != null) {
          _appointmentBloc.add(LoadMoreAppointments(
            type: user.type,
            offset: state.appointments.length,
          ));
        }
      }
    }
  }

  // Video Call Logic
  void _startVideoCall(BuildContext context, AppointmentModel appointment) {
    final user = UserManager().currentUser;
    if (user == null) {
      _showSnackBar(context, 'User not logged in');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Create room request
    final request = CreateRoomRequestModel(
      type: user.type,
      doctorId: user.id,
      patientId: appointment.userId,
      appointmentId: appointment.id,
      duration: 30, // Default 30 minutes
    );

    _callBloc.add(StartVideoCall(request));
  }

  // Helper: Show snackbar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Cancel confirmation dialog
  void _showCancelConfirmation(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Consultation'),
        content: Text('Are you sure you want to cancel ${appointment.bookingId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Cancelled ${appointment.bookingId}');
              // TODO: Implement cancellation API call
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _appointmentBloc),
        BlocProvider.value(value: _callBloc),
      ],
      child: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          // Close loading dialog if open
          // We'll use a flag to manage loading state
          // For simplicity, we'll use a global loading overlay with a key.
          if (state is CallRoomCreated) {
            // Room created – now join
            final roomData = state.data;
            final joinRequest = JoinRoomRequestModel(
              roomId: roomData.result.roomId,
              callId: roomData.result.callId,
            );
            context.read<CallBloc>().add(JoinVideoCall(joinRequest));
          } else if (state is CallRoomJoined) {
            // Room joined – navigate to video call
            // Close loading dialog
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoCallScreen(
                  token: state.data.result.token,
                  roomId: state.data.result.roomId,
                  appointment: AppointmentModel(
                    id: 0,
                    bookingId: '',
                    consultType: '',
                    userId: 0,
                    specialityId: 0,
                    doctorId: 0,
                    slotId: 0,
                    time: '',
                    date: '',
                    mobile: '',
                    callStatus: 0,
                    familyMemberId: 0,
                    fee: 0,
                    consultationFee: 0,
                    couponId: 0,
                    couponPercentage: 0,
                    couponDiscount: 0,
                    specialityName: '',
                    doctorName: '',
                    patientImage: '',
                    patientName: 'Patient',
                    patientEmail: '',
                    patientGender: '',
                    patientDob: '',
                    bloodGroup: '',
                    qualification: '',
                  ),
                ),
              ),
            );
          } else if (state is CallError) {
            Navigator.pop(context);
            _showSnackBar(context, state.error);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Active Appointments'),
            backgroundColor: const Color(0xff1565C0),
            foregroundColor: Colors.white,
          ),
          body: BlocConsumer<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentError) {
                _showSnackBar(context, state.error);
              }
            },
            builder: (context, state) {
              if (state is AppointmentLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AppointmentLoaded) {
                return _buildAppointmentsList(context, state);
              } else if (state is AppointmentLoadMoreLoading) {
                return _buildAppointmentsList(
                  context,
                  AppointmentLoaded(
                    appointments: state.existingAppointments,
                    hasMore: true,
                    currentPage: state.currentPage,
                  ),
                  isLoadingMore: true,
                );
              } else if (state is AppointmentError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.error),
                      ElevatedButton(
                        onPressed: () {
                          final user = UserManager().currentUser;
                          if (user != null) {
                            context.read<AppointmentBloc>().add(FetchAppointments(type: user.type));
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context, AppointmentLoaded state, {bool isLoadingMore = false}) {
    if (state.appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active appointments found', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = UserManager().currentUser;
        if (user != null) {
          context.read<AppointmentBloc>().add(FetchAppointments(type: user.type));
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: state.appointments.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.appointments.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final appointment = state.appointments[index];
          return _buildAppointmentCard(context, appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Booking ID & Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.bookingId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1565C0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: appointment.consultType == 'online'
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.consultType.toUpperCase(),
                    style: TextStyle(
                      color: appointment.consultType == 'online'
                          ? Colors.blue.shade800
                          : Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Patient info row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    imageUrl: appointment.patientImage.isNotEmpty
                        ? appointment.patientImage
                        : 'https://via.placeholder.com/60',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment.patientGender} · ${appointment.patientDob}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        appointment.bloodGroup.isNotEmpty
                            ? 'Blood Group: ${appointment.bloodGroup}'
                            : '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Details chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _infoChip(Icons.calendar_today, appointment.date),
                _infoChip(Icons.access_time, appointment.time),
                _infoChip(Icons.medical_services, appointment.specialityName),
                _infoChip(Icons.person, appointment.doctorName),
                _infoChip(Icons.attach_money, '₹${appointment.fee}'),
                if (appointment.couponDiscount > 0)
                  _infoChip(Icons.local_offer, '₹${appointment.couponDiscount} off'),
              ],
            ),
            if (appointment.qualification.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Qualification: ${appointment.qualification}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons row: Video Call & Cancel Consultation
            Row(
              children: [
                // Video Call button (green)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startVideoCall(context, appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.video_call, color: Colors.white, size: 18),
                    label: const Text(
                      'Video Call',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Cancel Consultation button (red)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCancelConfirmation(context, appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.white, size: 18),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // "View Details" button (full width)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showSnackBar(context, 'Opening details for ${appointment.bookingId}');
                  // TODO: Navigate to appointment details
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff1565C0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(color: Color(0xff1565C0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}