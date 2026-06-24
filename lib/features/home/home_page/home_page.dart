import 'package:doctors/features/bank_details/pages/bank_details_page.dart';
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
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = di.sl<DashboardBloc>();
    final user = di.sl<UserManager>().currentUser;
    if (user != null) {
      _dashboardBloc.add(FetchDashboard(user.type));
    }
    // Fetch notifications to get unread count
    final notificationBloc = di.sl<NotificationBloc>()..add(const FetchNotifications());
    notificationBloc.stream.listen((state) {
      if (state is NotificationLoaded) {
        setState(() {
          _unreadCount = state.data.result.unreadCount;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // Get NotificationBloc instance and fetch initial notifications
    final notificationBloc = di.sl<NotificationBloc>()..add(const FetchNotifications());

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardBloc),
        BlocProvider.value(value: notificationBloc),
      ],
      child: Scaffold(
        drawer: _buildDrawer(context),
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: SvgPicture.asset(
            'assets/med.svg',  // Update path to your SVG
            height: 32,                         // Adjust as needed
            width: 100,                         // Adjust as needed
          ),
          centerTitle: true,
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
                      icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0A8FDC)),
                      onPressed: () async {
                        // Navigate to NotificationPage
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationPage()),
                        );
                        // Refresh notifications to update unread count
                        if (result == true) {
                          context.read<NotificationBloc>().add(const FetchNotifications());
                        }
                      },
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              unread > 99 ? '99+' : unread.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(state.data);
            } else if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.error),
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
            // DashboardInitial
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardResponseModel data) {
    final userInfo = data.result.userInfo;
    final quickActions = data.result.quickActions;
    final todayAppointments = data.result.todayAppointments;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Card (same as before, but ensure it matches the screenshot)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A8FDC), Color(0xFF0A6FB3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A8FDC).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: userInfo.image.isNotEmpty
                      ? NetworkImage(userInfo.image)
                      : null,
                  child: userInfo.image.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Color(0xFF0A8FDC))
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Good Morning", // or dynamic greeting based on time
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        userInfo.doctorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userInfo.specialityId, // or speciality name
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Stats Row – Four cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        context,
                        "Today's Appointments",
                        data.result.appointmentsCount.toString(),
                        'assets/appointment.svg',
                        const Color(0xFF0A8FDC),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        context,
                        "Patients This Month",
                        data.result.todayAppointments.toString(),
                        'assets/appointment.svg',
                        const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        context,
                        "Earnings This Month",
                        "₹${data.result.appointmentsCount.toStringAsFixed(0)}",
                        'assets/saving.svg',
                        const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        context,
                        "Your Rating",
                        data.result.appointmentsCount.toStringAsFixed(1) + " ★",
                        'assets/customer-review.svg',
                        const Color(0xFFFFC107),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Quick Actions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all actions
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Color(0xFF0A8FDC)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Actions Grid
          SizedBox(
            height: 180, // adjust as needed
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return _quickActionCard(
                  context,
                  action.name,
                  action.icon, // map to IconData
                  action.route,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 4. Today's Appointments Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Appointments",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all appointments
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(color: Color(0xFF0A8FDC)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Appointments List
          todayAppointments.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "No appointments for today",
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: todayAppointments.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final appointment = todayAppointments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A8FDC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF0A8FDC),
                      size: 28,
                    ),
                  ),
                  title: Text(
                    appointment.patientName ?? 'Patient',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                appointment.time ?? '--:--',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.medical_services,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                appointment.type ?? 'Consultation',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: appointment.status == 'Completed'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status ?? 'Upcoming',
                      style: TextStyle(
                        color: appointment.status == 'Completed'
                            ? Colors.green
                            : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Drawer - same as before, but logout uses auth repository
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A8FDC), Color(0xFF0A6FB3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 45,
                    color: Color(0xFF0A8FDC),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Dr. John Smith",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Cardiologist",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "⭐ 4.9 Rating",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.person_outline, "Doctor Profile", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorProfilePage()),
                  );
                }),
                _drawerItem(Icons.account_balance_wallet_outlined, "Wallet", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletHistoryPage()),
                  );
                }),
                _drawerItem(Icons.account_balance_outlined, "Bank Account", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BankAccountScreen()),
                  );
                }),
                _drawerItem(Icons.currency_rupee, "My Earnings", () {
                  Navigator.pop(context);
                }),
                _drawerItem(Icons.settings_outlined, "Settings", () {
                  Navigator.pop(context);
                }),
                _drawerItem(Icons.calendar_today, "Appointments", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                  );
                }),
                const Divider(),
                _drawerItem(Icons.logout, "Logout", () async {
                  // Close the drawer first
                  Navigator.pop(context);

                  // Show custom logout confirmation dialog with Container buttons
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Message
                            const Text(
                              'Are you sure you want to logout?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Buttons row (Container-based)
                            Row(
                              children: [
                                // Cancel Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context, false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Logout Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context, true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  // If user confirmed logout
                  if (shouldLogout == true) {
                    // Clear session
                    await di.sl<UserManager>().clearUser();

                    // Navigate to LoginPage using MaterialPageRoute
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                }, isRed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {bool isRed = false}) {
    return ListTile(
      leading: Icon(icon, color: isRed ? Colors.red : const Color(0xFF0A8FDC)),
      title: Text(
        title,
        style: TextStyle(
          color: isRed ? Colors.red : const Color(0xFF1A1A2E),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _statCard(
      BuildContext context,
      String title,
      String value,
      String svgAsset,      // path to SVG asset
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              svgAsset,
              height: 20,
              width: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard(
      BuildContext context,
      String title,
      String iconName,
      String route,
      ) {
    return GestureDetector(
      onTap: () {
        // Navigate based on route
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigate to $title')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A8FDC).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _getIconData(iconName),
                color: const Color(0xFF0A8FDC),
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'appointments':
        return Icons.calendar_today;
      case 'patients':
        return Icons.people;
      case 'prescriptions':
        return Icons.medical_services;
      case 'reports':
        return Icons.analytics;
      default:
        return Icons.star;
    }
  }
}