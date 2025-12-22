import 'package:flutter/material.dart';
import 'package:myinvestment/view/auth/screen/auth_wrapper.dart';
import 'package:myinvestment/view/home/screen/home_screen.dart';
import 'package:myinvestment/view_model/auth_provider.dart';
import 'package:myinvestment/view_model/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
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
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF00FF00),
              secondary: Color(0xFF00CC00),
            ),
          ),
          home: HomeScreen(),
        );
      },
    );
  }
}