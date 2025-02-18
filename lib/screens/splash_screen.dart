import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_clone/screens/userScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String logoPath;

  @override
  void initState() {
    super.initState();

    List<String> logos = ["assets/logos/logo1.gif", "assets/logos/logo2.gif"];
    logoPath = logos[Random().nextInt(logos.length)];

    Future.delayed(Duration(seconds: 3), () {
      Get.off(() => Userscreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffFCFCFF),
        body: Center(
          child: Image.asset(logoPath),
        ),
      ),
    );
  }
}
