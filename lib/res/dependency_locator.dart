

import '../api_services/api_service.dart';
import '../repo/auth_repo.dart';

class DependencyLocator {
  static final DependencyLocator _instance = DependencyLocator._internal();
  factory DependencyLocator() => _instance;
  DependencyLocator._internal();

  late ApiService apiService;
  late AuthRepository authRepository;
/*

  // Repositories
  late HomePageRepo homePageRepo;
  late TicketBookingRepository ticketBookingRepository;
  late AuthRepository authRepository;
  late UserRepository userRepository;
  late AutoSyncDataServiceRepo autoSyncRepo;
  late QrScanRepository qrScanRepository;
  late SplashRepository splashRepository;

  // Services
  late ApiService apiService;
  late AutoSyncService autoSyncService;
*/

  Future<void> init() async {
    // Initialize API Service
    apiService = ApiService();
    authRepository = AuthRepository(apiService: apiService);
/*
    // Initialize Repositories
    homePageRepo = HomePageRepo(apiService: apiService);
    ticketBookingRepository = TicketBookingRepository(apiService: apiService);
    authRepository = AuthRepository(apiService: apiService);
    userRepository = UserRepository(apiService: apiService);
    autoSyncRepo = AutoSyncDataServiceRepo(apiService: apiService);
    qrScanRepository = QrScanRepository(apiService: apiService);
    splashRepository = SplashRepository(apiService: apiService);

    // Initialize Auto Sync Service
    autoSyncService = AutoSyncService();
    autoSyncService.initialize();
*/
    print('✅ All dependencies initialized');
  }
}
