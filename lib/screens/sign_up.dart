import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/auth/auth_services.dart';
import 'package:inventory_management/exports/exports.dart';
import 'package:inventory_management/screens/home_page.dart';
import 'package:inventory_management/screens/sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final AuthServices auth;
  late bool _visible;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = AuthServices();
    _visible = true;
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Email address'),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text('Password'),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _visible = !_visible;
                    });
                  },
                  icon: Icon(
                    _visible ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              obscureText: _visible,
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () async {
                final cred = await auth.signUpWithEmail(
                  _emailController.text,
                  _passwordController.text,
                );

                if (cred != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (ctx) => MyHomePage(cred.uid),
                    ),
                  );
                } else {
                  createSnackbar(
                    context: context,
                    message: 'Authentication failed',
                  );
                }
              },
              child: const Text('Sign Up'),
            ),
						const SizedBox(height: 20,),
						RichText(
                text: TextSpan(
                  text: 'Already registered? Login ',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'here',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to the login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignIn(),
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
    );
  }
}
