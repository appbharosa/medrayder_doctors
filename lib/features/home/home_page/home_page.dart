import 'package:doctors/features/bank_details/pages/bank_details_page.dart';
import 'package:doctors/features/booking_history/pages/booking_history_screen.dart';
import 'package:doctors/features/profile/pages/doctor_profile_page.dart';
import 'package:doctors/features/wallet/pages/wallet_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/manager/user_manager.dart';
import '../../../data/models/dashboard_response_model.dart';
import '../../appointments/pages/appointments_screen.dart';
import '../../auth/login/pages/login_page.dart';
import '../../notification/bloc/notification_bloc.dart';
import '../../notification/bloc/notification_event.dart';
import '../../notification/bloc/notification_state.dart';
import '../../notification/pages/notification_page.dart';
import '../availability_bloc/availability_bloc.dart';
import '../availability_bloc/availability_event.dart';
import '../availability_bloc/availability_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DashboardBloc _dashboardBloc;
  late final AvailabilityBloc _availabilityBloc;
  int _unreadCount = 0;
  String _greeting = 'Good Morning';

  @override
  void initState() {
    super.initState();
    _setGreeting();

    _dashboardBloc = di.sl<DashboardBloc>();
    _availabilityBloc = di.sl<AvailabilityBloc>()..add(FetchAvailability());

    final user = di.sl<UserManager>().currentUser;

    if (user != null) {
      _dashboardBloc.add(FetchDashboard(user.type));
    }

    final notificationBloc = di.sl<NotificationBloc>()..add(const FetchNotifications());

    notificationBloc.stream.listen((state) {
      if (state is NotificationLoaded) {
        setState(() {
          _unreadCount = state.data.result.unreadCount;
        });
      }
    });
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationBloc = di.sl<NotificationBloc>()..add(const FetchNotifications());

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardBloc),
        BlocProvider.value(value: notificationBloc),
        BlocProvider.value(value: _availabilityBloc), // ✅ added
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        drawer: _buildDrawer(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: SvgPicture.asset(
            'assets/med.svg',
            height: 34,
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                int unread = 0;
                if (state is NotificationLoaded) {
                  unread = state.data.result.unreadCount;
                }
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        );
                        if (result == true) {
                          context.read<NotificationBloc>().add(const FetchNotifications());
                        }
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF0A8FDC),
                        size: 28,
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread > 99 ? '99+' : unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            // Optional: handle dashboard error with snackbar
            if (state is DashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardLoaded) {
              return _buildDashboard(state.data);
            }
            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 15),
                    Text(state.error),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        final user = di.sl<UserManager>().currentUser;
                        if (user != null) {
                          context.read<DashboardBloc>().add(FetchDashboard(user.type));
                        }
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // Dashboard content with availability toggle
  // ───────────────────────────────────────────────
  Widget _buildDashboard(DashboardResponseModel data) {
    final userInfo = data.result.userInfo;

    return RefreshIndicator(
      onRefresh: () async {
        final user = di.sl<UserManager>().currentUser;
        if (user != null) {
          _dashboardBloc.add(FetchDashboard(user.type));
          await Future.delayed(const Duration(milliseconds: 500));
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            // ─── AVAILABILITY TOGGLE ROW ───
            BlocBuilder<AvailabilityBloc, AvailabilityState>(
              builder: (context, state) {
                bool isAvailable = false;
                String statusText = 'Offline';
                bool isLoading = false;

                if (state is AvailabilityLoading || state is AvailabilityInitial) {
                  isLoading = true;
                } else if (state is AvailabilityLoaded) {
                  isAvailable = state.availability.isAvailable;
                  statusText = isAvailable ? 'Online' : 'Offline';
                } else if (state is AvailabilityError) {
                  // Fallback to offline
                  isAvailable = false;
                  statusText = 'Offline';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          if (isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0A8FDC),
                              ),
                            )
                          else
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Switch(
                            value: isAvailable,
                            onChanged: isLoading
                                ? null
                                : (value) {
                              _availabilityBloc.add(ToggleAvailability(value));
                            },
                            activeColor: const Color(0xFF0A8FDC),
                            inactiveThumbColor: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // ─── USER PROFILE CARD ───
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A8FDC), Color(0xFF086AA7)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A8FDC).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    backgroundImage: userInfo.image.isNotEmpty
                        ? NetworkImage(userInfo.image)
                        : null,
                    child: userInfo.image.isEmpty
                        ? const Icon(Icons.person, size: 36, color: Color(0xFF0A8FDC))
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userInfo.doctorName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            userInfo.specialityId,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── STATS GRID ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 1.10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _modernCard(
                    title: "Appointments",
                  //  value: data.result.appointmentsCount.toString(),
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF0A8FDC),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppointmentsScreen(),
                        ),
                      );
                    },
                  ),
                  _modernCard(
                    title: "Booking History",
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _modernCard(
                    title: "Profile",

                    icon: Icons.person,
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DoctorProfilePage(),
                        ),
                      );
                    },
                  ),
                  _modernCard(
                    title: "Wallet",

                    icon: Icons.wallet,
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WalletHistoryPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── OVERVIEW CARD ───
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A8FDC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Color(0xFF0A8FDC),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Overview",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Manage appointments, reports and prescriptions easily.",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _overviewItem(
                        "Earnings",
                        "₹${data.result.earningThisMonth}",
                        Icons.currency_rupee_rounded,
                      ),
                      _overviewItem(
                        "Ratings",
                        data.result.todayRatings.toString(),
                        Icons.star_rounded,
                      ),
                      _overviewItem(
                        "Patients",
                        data.result.patientsThisMonth.toString(),
                        Icons.people,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper Widgets (unchanged) ───
  Widget _modernCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewItem(String title, String value, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF0A8FDC).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF0A8FDC)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  // ─── DRAWER (unchanged) ───
  Widget _buildDrawer(BuildContext context) {
    final user = di.sl<UserManager>().currentUser;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A8FDC), Color(0xFF086AA7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.image != null && user!.image!.isNotEmpty
                      ? NetworkImage(user.image!)
                      : null,
                  child: user?.image == null || user!.image!.isEmpty
                      ? const Icon(Icons.person, size: 35)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(
                  user?.name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.phone ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _drawerItem(
                  Icons.person_outline,
                  "Doctor Profile",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorProfilePage(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  Icons.calendar_month,
                  "Appointments",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppointmentsScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  Icons.account_balance_wallet_outlined,
                  "Wallet",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WalletHistoryPage(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  Icons.comment_bank,
                  "Bank Details",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BankAccountScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _drawerItem(
                  Icons.logout,
                  "Logout",
                      () async {
                    await di.sl<UserManager>().clearUser();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  isRed: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool isRed = false,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isRed ? Colors.red : const Color(0xFF0A8FDC),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isRed ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}