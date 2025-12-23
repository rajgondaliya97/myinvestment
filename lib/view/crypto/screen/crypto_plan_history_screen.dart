import 'package:flutter/material.dart';
import 'package:myinvestment/res/app_widget/custom_app_bar.dart';

class CryptoPlanHistoryScreen extends StatefulWidget {
  const CryptoPlanHistoryScreen({super.key});

  @override
  State<CryptoPlanHistoryScreen> createState() => _CryptoPlanHistoryScreenState();
}

class _CryptoPlanHistoryScreenState extends State<CryptoPlanHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
       title: 'Crypto History',
      ),
    );
  }
}
