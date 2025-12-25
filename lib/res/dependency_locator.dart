

import '../api_services/api_service.dart';
import '../repo/auth_repo.dart';
import '../repo/plan_repo.dart';
import '../repo/profile_repo.dart';
import '../repo/wallet_repo.dart';

class DependencyLocator {
  static final DependencyLocator _instance = DependencyLocator._internal();
  factory DependencyLocator() => _instance;
  DependencyLocator._internal();

  late ApiService apiService;
  late AuthRepository authRepository;
  late PlanRepository planRepository;
  late ProfileRepository profileRepository;
  late WalletRepository walletRepository;


  Future<void> init() async {
    // Initialize API Service
    apiService = ApiService();
    authRepository = AuthRepository(apiService: apiService);
    planRepository = PlanRepository(apiService: apiService);
    walletRepository = WalletRepository(apiService: apiService);

    print('✅ All dependencies initialized');
  }
}
