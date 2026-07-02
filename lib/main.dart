import 'dart:io';

import 'package:doctors/utils/services/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'core/app_urls/app_urls.dart';
import 'core/di/injection.dart' as di;
import 'core/manager/user_manager.dart';
import 'core/network/dio_client.dart';
import 'features/auth/login/bloc/login_bloc.dart';
import 'features/auth/login/pages/login_page.dart';
import 'features/auth/otp/bloc/otp_bloc.dart';
import 'features/home/home_page/home_page.dart';
import 'firebase_options.dart';
import 'package:get/get.dart' hide Response; // if you're using GetX, else import as GetMaterialApp
import 'package:upgrader/upgrader.dart'; // <-- import upgrader



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Doctor App',
        debugShowCheckedModeBanner: false,
        home: _getInitialScreen(),
        // 👇 Integrate Upgrader
        builder: (context, child) {
          return UpgradeAlert(
            upgrader: Upgrader(
              debugLogging: true,
              debugDisplayAlways: false,
              durationUntilAlertAgain: const Duration(days: 1),
              countryCode: 'in',
              // minAppVersion: '2.0.0',
            ),
            dialogStyle: UpgradeDialogStyle.material,
            child: child ?? const SizedBox.shrink(),
          );
        },
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
