import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/services/web_wallet_service.dart';
import 'package:myinvestment/res/services/wallet_import_screen.dart' hide WalletDashboardScreen;
import 'package:myinvestment/res/services/wallet_dashboard_screen.dart';
import 'package:myinvestment/utils/app_config.dart';
import 'package:myinvestment/res/database/local_database.dart';
import 'package:myinvestment/res/dependency_locator.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:myinvestment/view/auth/screen/auth_wrapper.dart';
import 'package:myinvestment/view_model/deposit_provider.dart';
import 'package:myinvestment/view_model/investment_controller.dart';
import 'package:myinvestment/view_model/pan_provider.dart';
import 'package:myinvestment/view_model/transaction_controller.dart';
import 'package:myinvestment/view_model/user_plan_provoder.dart';
import 'package:myinvestment/view_model/wallet_controller.dart';
import 'package:provider/provider.dart';
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

    // Create Web3 Wallet Service
    debugPrint('🔧 Creating Web3 Wallet Service...');
    final web3WalletService = Web3WalletService();
    debugPrint('✅ Web3 Wallet Service created');

    debugPrint('✅ All services initialized successfully');

    runApp(MyApp(web3WalletService: web3WalletService));
  } catch (e, stackTrace) {
    debugPrint('❌ FATAL ERROR during initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    runApp(MyApp(initializationError: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  final Web3WalletService? web3WalletService;
  final String? initializationError;

  const MyApp({
    Key? key,
    this.web3WalletService,
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
        // Provide Web3 Wallet Service
        ChangeNotifierProvider.value(
          value: web3WalletService ?? Web3WalletService(),
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
           /* home: initializationError != null
                ? InitializationErrorScreen(error: initializationError!)
                : const Web3WalletInitializer(),
            routes: {
              '/import': (context) => const WalletImportScreen(),
              '/dashboard': (context) => const WalletDashboardScreen(),
            },*/
            home: WalletImportScreen(),
          );
        },
      ),
    );
  }
}

// Initialize Web3 Wallet and check for saved wallet
class Web3WalletInitializer extends StatefulWidget {
  const Web3WalletInitializer({Key? key}) : super(key: key);

  @override
  State<Web3WalletInitializer> createState() => _Web3WalletInitializerState();
}

class _Web3WalletInitializerState extends State<Web3WalletInitializer> {
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    try {
      final walletService = Provider.of<Web3WalletService>(context, listen: false);

      debugPrint('🔧 Initializing Web3 Wallet service...');
      await walletService.initialize();
      debugPrint('✅ Web3 Wallet service initialized');

      // Check if wallet is already connected (from saved key)
      if (walletService.isConnected) {
        debugPrint('✅ Found saved wallet, navigating to dashboard');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WalletDashboardScreen(),
            ),
          );
        }
      } else {
        debugPrint('ℹ️ No saved wallet found, showing import screen');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WalletImportScreen(),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Wallet initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Initializing Wallet Service...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return InitializationErrorScreen(error: _error!);
    }

    // This should not be reached as we navigate away
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

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
              Text(
                'Initialization Failed',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart app
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Web3WalletInitializer(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
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