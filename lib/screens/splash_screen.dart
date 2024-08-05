import 'package:flutter/material.dart';
import 'package:inventory_management/exports/exports.dart';
import 'package:inventory_management/screens/home_page.dart';
import 'package:inventory_management/screens/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Text(
							'Initializing...',
						),
					],
				),
			),
    );
  }

  _checkUserLoggedIn() async {
    await Future.delayed(const Duration(seconds: 3));
    final sharedPrefs = await SharedPreferences.getInstance();
    final status = sharedPrefs.getString(LOGIN_STATUS);
    status != null
        ? await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => MyHomePage(status),
            ),
          )
        : await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => SignIn(),
            ),
          );
  }
}
