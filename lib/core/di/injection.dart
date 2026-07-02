import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/appointment_api_service.dart';
import '../../data/datasources/auth_api_service.dart';
import '../../data/datasources/availability_api_service.dart';
import '../../data/datasources/bank_detail_api_service.dart';
import '../../data/datasources/booking_history_api_service.dart';
import '../../data/datasources/call_api_service.dart';
import '../../data/datasources/dashboard_api_service.dart';
import '../../data/datasources/doctor_profile_api_service.dart';
import '../../data/datasources/notification_api_service.dart';
import '../../data/datasources/prescription_api_service.dart';
import '../../data/datasources/terms_api_service.dart';
import '../../data/datasources/wallet_api_service.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/availability_repository_impl.dart';
import '../../data/repositories/bank_detail_repository_impl.dart';
import '../../data/repositories/booking_hostory_repository_implementation.dart';
import '../../data/repositories/call_repository_impl.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/repositories/doctor_profile_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/prescription_repository_implementation.dart';
import '../../data/repositories/terms_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/availability_repository.dart';
import '../../domain/repositories/bank_detail_repository.dart';
import '../../domain/repositories/booking_history_repository.dart';
import '../../domain/repositories/call_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../../domain/repositories/terms_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../features/appointments/bloc/appointment_bloc.dart';
import '../../features/appointments/call_bloc/call_bloc.dart';
import '../../features/auth/login/bloc/login_bloc.dart';
import '../../features/auth/login/terms_bloc/terms_bloc.dart';
import '../../features/auth/otp/bloc/otp_bloc.dart';
import '../../features/bank_details/bloc/bank_detail_bloc.dart';
import '../../features/booking_history/bloc/booking_history_bloc.dart';
import '../../features/home/availability_bloc/availability_bloc.dart';
import '../../features/home/bloc/dashboard_bloc.dart';
import '../../features/notification/bloc/notification_bloc.dart';
import '../../features/prescription/bloc/prescripption_bloc.dart';
import '../../features/profile/bloc/doctor_profile_bloc.dart';
import '../../features/wallet/bloc/wallet_bloc.dart';
import '../manager/user_manager.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // Network
  sl.registerLazySingleton<Dio>(() => DioClient().dio);

  // Managers
  sl.registerLazySingleton<UserManager>(() => UserManager());

  // API Services
  sl.registerLazySingleton<AuthApiService>(() => AuthApiService(sl<Dio>()));
  sl.registerLazySingleton<BankApiService>(() => BankApiService(sl<Dio>()));
  sl.registerLazySingleton<DashboardApiService>(() => DashboardApiService(sl<Dio>()));
  sl.registerLazySingleton<WalletApiService>(() => WalletApiService(sl<Dio>()));
  sl.registerLazySingleton<DoctorProfileApiService>(() => DoctorProfileApiService(sl<Dio>()));
  sl.registerLazySingleton<NotificationApiService>(() => NotificationApiService(sl<Dio>()));
  sl.registerLazySingleton<AppointmentApiService>(() => AppointmentApiService(sl<Dio>()));
  sl.registerLazySingleton<CallApiService>(() => CallApiService(sl<Dio>()));
  sl.registerLazySingleton<AvailabilityApiService>(() => AvailabilityApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<TermsApiService>(() => TermsApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<PrescriptionApiService>(() => PrescriptionApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<BookingHistoryApiService>(
        () => BookingHistoryApiService(sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(apiService: sl<AuthApiService>(), userManager: sl<UserManager>(),
    ),);
  sl.registerLazySingleton<BankRepository>(() => BankRepositoryImpl(apiService: sl<BankApiService>(),
    ),);
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(apiService: sl<DashboardApiService>(),   // now it's registered
    ),);
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(apiService: sl<WalletApiService>()));
  sl.registerLazySingleton<DoctorProfileRepository>(() => DoctorProfileRepositoryImpl(apiService: sl<DoctorProfileApiService>()));
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(apiService: sl<NotificationApiService>()));
  sl.registerLazySingleton<AppointmentRepository>(() => AppointmentRepositoryImpl(apiService: sl<AppointmentApiService>()));
  sl.registerLazySingleton<CallRepository>(() => CallRepositoryImpl(apiService: sl<CallApiService>()));
  sl.registerLazySingleton<AvailabilityRepository>(() => AvailabilityRepositoryImpl(sl<AvailabilityApiService>()),
  );
  sl.registerLazySingleton<TermsRepository>(() => TermsRepositoryImpl(sl<TermsApiService>()),
  );
  sl.registerLazySingleton<PrescriptionRepository>(() => PrescriptionRepositoryImpl(apiService: sl<PrescriptionApiService>()),
  );
  sl.registerLazySingleton<BookingHistoryRepository>(
        () => BookingHistoryRepositoryImpl(apiService: sl<BookingHistoryApiService>()),
  );
  // BLoCs
  sl.registerFactory<LoginBloc>(() => LoginBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory<OtpBloc>(() => OtpBloc(authRepository: sl<AuthRepository>()));
  sl.registerFactory<BankBloc>(() => BankBloc(repository: sl<BankRepository>()));
  sl.registerFactory<DashboardBloc>(() => DashboardBloc(repository: sl<DashboardRepository>()));
  sl.registerFactory<WalletBloc>(() => WalletBloc(repository: sl<WalletRepository>()));
  sl.registerFactory<DoctorProfileBloc>(() => DoctorProfileBloc(repository: sl<DoctorProfileRepository>()));
  sl.registerFactory<NotificationBloc>(() => NotificationBloc(repository: sl<NotificationRepository>()));
  sl.registerFactory<AppointmentBloc>(() => AppointmentBloc(repository: sl<AppointmentRepository>()));
  sl.registerFactory<CallBloc>(() => CallBloc(repository: sl<CallRepository>()));
  sl.registerFactory<AvailabilityBloc>(() => AvailabilityBloc(sl<AvailabilityRepository>()),
  );
  sl.registerFactory<TermsBloc>(() => TermsBloc(sl<TermsRepository>()),
  );
  sl.registerFactory<PrescriptionBloc>(() => PrescriptionBloc(repository: sl<PrescriptionRepository>()),
  );
  sl.registerFactory<BookingHistoryBloc>(
        () => BookingHistoryBloc(repository: sl<BookingHistoryRepository>()),
  );
}