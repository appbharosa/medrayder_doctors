import 'package:doctors/features/appointments/pages/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/app_colors/app_colors.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/manager/user_manager.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/create_room_request_model.dart';
import '../../../data/models/join_room_request_model.dart';
import '../../prescription/pages/prescription_detail_screen.dart';
import '../../prescription/pages/prescription_screen.dart';
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
  String? _currentCallId;
  AppointmentModel? _currentAppointment;
  bool _canStartCall = true;

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
    // _appointmentBloc.close();
    // _callBloc.close();
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

  void _startVideoCall(BuildContext context, AppointmentModel appointment) {
    if (!_canStartCall) {
      _showSnackBar(context, 'Please wait a moment before starting another call');
      return;
    }
    final user = UserManager().currentUser;
    if (user == null) {
      _showSnackBar(context, 'User not logged in');
      return;
    }
    if (appointment.userId == 0 || appointment.id == 0) {
      _showSnackBar(context, 'Invalid appointment data');
      return;
    }
    _currentAppointment = appointment;
    final request = CreateRoomRequestModel(
      type: user.type,
      doctorId: user.id,
      patientId: appointment.userId,
      appointmentId: appointment.id,
      duration: 30,
    );
    _callBloc.add(StartVideoCall(request));
  }  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _appointmentBloc),
        BlocProvider.value(value: _callBloc),
      ],
      child: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallRoomCreated) {
            // Dismiss loading dialog (shown in _startVideoCall)
            Navigator.pop(context);

            final result = state.data; // CreateRoomResult
            _currentCallId = result.callId;

            final appointment = _currentAppointment;
            if (appointment == null) {
              _showSnackBar(context, 'Appointment not found');
              _canStartCall = true;
              return;
            }

            // ✅ Navigate directly using the doctor token from create-room
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoCallScreen(
                  key: ValueKey('video_${DateTime.now().millisecondsSinceEpoch}_${appointment.id}'),
                  token: result.doctorToken,   // 👈 doctor token
                  roomId: result.roomId,
                  callId: result.callId,
            //      callBloc: _callBloc,
                  appointment: appointment,
                ),
              ),
            ).then((_) {
              _callBloc.add(ResetCallState());
              _currentAppointment = null;
              _currentCallId = null;

              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) _canStartCall = true;
              });

              final user = UserManager().currentUser;
              if (user != null) {
                _appointmentBloc.add(FetchAppointments(type: user.type));
              }
            });
          } else if (state is CallError) {
            Navigator.pop(context);
            _showSnackBar(context, state.error);
            _callBloc.add(ResetCallState());
            _canStartCall = true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Active Appointments',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
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

  Widget _buildAppointmentsList(
      BuildContext context,
      AppointmentLoaded state, {
        bool isLoadingMore = false,
      }) {
    if (state.appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No active appointments found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
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

  Widget _buildAppointmentCard(
      BuildContext context,
      AppointmentModel appointment,
      ) {
    final bool isOnline = appointment.consultType.toLowerCase() == 'online';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          /// TOP HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xff1565C0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// BOOKING ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Booking ID",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.bookingId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),

                /// ONLINE / OFFLINE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.lightBlue.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOnline
                            ? Icons.video_call_rounded
                            : Icons.local_hospital_rounded,
                        size: 15,
                        color: isOnline
                            ? Colors.blue.shade800
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        appointment.consultType.toUpperCase(),
                        style: TextStyle(
                          color: isOnline
                              ? Colors.blue.shade800
                              : Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [

                /// PATIENT INFO
                Row(
                  children: [

                    /// IMAGE
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CachedNetworkImage(
                          imageUrl: appointment.patientImage.isNotEmpty
                              ? appointment.patientImage
                              : 'https://via.placeholder.com/150',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            appointment.patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff222222),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 15,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${appointment.patientGender} • ${appointment.patientDob}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (appointment.bloodGroup.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.bloodtype,
                                  size: 15,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Blood Group : ${appointment.bloodGroup}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// INFO CONTAINERS
                Row(
                  children: [

                    Expanded(
                      child: _modernInfoCard(
                        icon: Icons.calendar_month_rounded,
                        title: "Date",
                        value: appointment.date,
                        iconColor: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _modernInfoCard(
                        icon: Icons.access_time_filled_rounded,
                        title: "Time",
                        value: appointment.time,
                        iconColor: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _modernInfoCard(
                        icon: Icons.currency_rupee_rounded,
                        title: "Fee",
                        value: appointment.fee.toString(),
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                if (appointment.qualification.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [

                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xff1565C0),
                          size: 20,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            appointment.qualification,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff1565C0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                /// BUTTONS
                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _startVideoCall(context, appointment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.video_call_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          "Video Call",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final user = UserManager().currentUser;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrescriptionScreen(
                                bookingId: appointment.bookingId,
                                doctorType: user?.type ?? 'online',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.medical_services, color: Colors.white, size: 20),
                        label: const Text(
                          "Prescription",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    // Expanded(
                    //   child: ElevatedButton.icon(
                    //     onPressed: () =>
                    //         _showCancelConfirmation(context, appointment),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.red.shade500,
                    //       elevation: 0,
                    //       padding: const EdgeInsets.symmetric(vertical: 14),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(14),
                    //       ),
                    //     ),
                    //     icon: const Icon(
                    //       Icons.cancel_rounded,
                    //       color: Colors.white,
                    //       size: 18,
                    //     ),
                    //     label: const Text(
                    //       "Cancel",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 12),

                /// VIEW DETAILS BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      final user = UserManager().currentUser;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrescriptionDetailsScreen(
                            bookingId: appointment.bookingId,
                            doctorType: user?.type ?? 'online',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xff1565C0), width: 1.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(color: Color(0xff1565C0), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xff222222),
            ),
          ),
        ],
      ),
    );
  }
}