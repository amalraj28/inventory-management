import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/auth/auth_services.dart';
import 'package:inventory_management/exports/exports.dart';
import 'package:inventory_management/screens/home_page.dart';
import 'package:inventory_management/screens/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatelessWidget {
  SignIn({super.key});
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  label: Text('Email address'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text('Password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text;
                  final pwd = _passwordController.text;

                  if (email.isEmpty || pwd.isEmpty) {
                    createSnackbar(
                      context: context,
                      message: 'One or more fields are empty',
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  final cred = await _auth.signInWithEmail(email, pwd);
                  if (cred == null || cred.toString().isEmpty) {
                    createSnackbar(
                      context: context,
                      message: 'Failed to sign in. Please try again later',
                    );
                    return;
                  }

                  _handleLogin(context, cred.uid);
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(
                  text: 'Not registered? ',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to the login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUp(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _handleLogin(BuildContext ctx, String uid) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString(LOGIN_STATUS, uid);
    await Navigator.of(ctx).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(uid),
      ),
    );
  }
}
