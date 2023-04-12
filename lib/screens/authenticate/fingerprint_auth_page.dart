import 'package:data_leak/services/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintAuthPage extends StatefulWidget {
  final VoidCallback onAuthenticated;

  FingerprintAuthPage({required this.onAuthenticated});

  @override
  _FingerprintAuthPageState createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
  bool isAuthenticated = false;
  final LocalAuthentication auth = LocalAuthentication();
  bool isFirstAttempt = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool didAuthenticate = await authenticateWithBiometrics();
      if (didAuthenticate) {
        widget.onAuthenticated();
      } else {
        setState(() {
          isFirstAttempt = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isAuthenticated
            ? const Text("Authentication successful!")
            : !loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Authentication failed."),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          bool didAuthenticate = await authenticateWithBiometrics();
                          if (didAuthenticate) {
                            setState(() {
                              widget.onAuthenticated();
                            });
                          }
                          setState(() {
                            loading = false;
                          });
                        },
                        child: const Text("Try again"),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
