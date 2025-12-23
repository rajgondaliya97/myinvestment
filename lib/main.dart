import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/database/local_database.dart';
import 'package:myinvestment/res/dependency_locator.dart';
import 'package:myinvestment/view_model/deposit_provider.dart';
import 'package:myinvestment/view_model/investment_controller.dart';
import 'package:provider/provider.dart';
import 'view/auth/screen/auth_wrapper.dart';
import 'view_model/auth_provider.dart';
import 'view_model/home_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await AppLocalData.init();

  // Initialize Dependencies (API services, repositories, etc.)
  await DependencyLocator().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(authRepository: DependencyLocator().authRepository)),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
        ChangeNotifierProvider(create: (_) => DepositProvider()),
      ],
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Investment App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Color(0xFF00FF00),
              scaffoldBackgroundColor: Colors.black,
              brightness: Brightness.dark,
              fontFamily: 'Inter',
            ),
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}
