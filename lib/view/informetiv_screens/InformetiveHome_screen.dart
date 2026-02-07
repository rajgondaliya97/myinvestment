import 'package:flutter/material.dart';
import 'package:myinvestment/res/app_widget/custom_app_bar.dart';

class InformetiveHomeScreen extends StatefulWidget {
  const InformetiveHomeScreen({super.key});

  @override
  State<InformetiveHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<InformetiveHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBar(),
      body: Column(children: []),
    );
  }
}
