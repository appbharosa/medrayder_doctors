import 'package:doctors/utils/services/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart' as di;
import 'core/manager/user_manager.dart';
import 'features/auth/login/bloc/login_bloc.dart';
import 'features/auth/login/pages/login_page.dart';
import 'features/auth/otp/bloc/otp_bloc.dart';
import 'features/home/home_page/home_page.dart';
import 'firebase_options.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize push notifications
  await FirebaseNotificationService.initialize();



  await di.init();
  await di.sl<UserManager>().loadUser();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (_) => di.sl<LoginBloc>()),
        BlocProvider<OtpBloc>(create: (_) => di.sl<OtpBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Doctor App',
        debugShowCheckedModeBanner: false,
        home: _getInitialScreen(),
      ),
    );
  }

  Widget _getInitialScreen() {
    final userManager = di.sl<UserManager>();
    final user = userManager.currentUser;

    if (user != null && user.accessToken.isNotEmpty) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
