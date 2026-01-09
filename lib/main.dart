import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/services/MetaMaskWalletScreen.dart';
import 'package:myinvestment/utils/app_config.dart';
import 'package:myinvestment/res/database/local_database.dart';
import 'package:myinvestment/res/dependency_locator.dart';
import 'package:myinvestment/res/services/meta_mask_service.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:myinvestment/view_model/deposit_provider.dart';
import 'package:myinvestment/view_model/investment_controller.dart';
import 'package:myinvestment/view_model/pan_provider.dart';
import 'package:myinvestment/view_model/transaction_controller.dart';
import 'package:myinvestment/view_model/user_plan_provoder.dart';
import 'package:myinvestment/view_model/wallet_controller.dart';
import 'package:provider/provider.dart';
import 'view/auth/screen/auth_wrapper.dart';
import 'view_model/auth_provider.dart';
import 'view_model/home_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize AppConfig FIRST
    debugPrint('🔧 Initializing AppConfig...');
    await AppConfig.init();
    debugPrint('✅ AppConfig initialized');

    // Initialize Local Database
    debugPrint('🔧 Initializing Local Database...');
    await AppLocalData.init();
    debugPrint('✅ Local Database initialized');

    // Initialize Dependencies
    debugPrint('🔧 Initializing Dependencies...');
    await DependencyLocator().init();
    debugPrint('✅ Dependencies initialized');

    // Initialize MetaMask Service
    debugPrint('🔧 Initializing MetaMask Service...');
    final metaMaskService = MetaMaskService();
    await metaMaskService.initialize();
    debugPrint('✅ All services initialized successfully');

    runApp(MyApp(metaMaskService: metaMaskService));
  } catch (e, stackTrace) {
    debugPrint('❌ FATAL ERROR during initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // Run app with error state
    runApp(MyApp(initializationError: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  final MetaMaskService? metaMaskService;
  final String? initializationError;

  const MyApp({
    Key? key,
    this.metaMaskService,
    this.initializationError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            authRepository: DependencyLocator().authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            homeRepository: DependencyLocator().homeRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
        ChangeNotifierProvider(
          create: (_) => DepositProvider(
            planRepository: DependencyLocator().planRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              PlanProvider(planRepository: DependencyLocator().planRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UserPlanController(
            planRepository: DependencyLocator().planRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletController(
            walletRepository: DependencyLocator().walletRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionController(
            transactionRepository: DependencyLocator().transactionRepository,
          ),
        ),
        // Use the pre-initialized MetaMask service
        ChangeNotifierProvider.value(
          value: metaMaskService ?? MetaMaskService(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Investment App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColor.primaryColor,
              scaffoldBackgroundColor: Colors.black,
              brightness: Brightness.dark,
              fontFamily: 'Inter',
            ),
            home: MetaMaskWalletScreen()/*initializationError != null
                ? InitializationErrorScreen(error: initializationError!)
                : AuthWrapper()*/,
          );
        },
      ),
    );
  }
}

// Error screen to show if initialization fails
class InitializationErrorScreen extends StatelessWidget {
  final String error;

  const InitializationErrorScreen({Key? key, required this.error})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Initialization Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  // You might want to use a package like restart_app
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}