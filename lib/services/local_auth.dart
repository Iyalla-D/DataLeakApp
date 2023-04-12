import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometrics() async {
  final localAuth = LocalAuthentication();
  bool didAuthenticate = false;

  // Check if biometric authentication is available
  bool canCheckBiometrics = await localAuth.canCheckBiometrics;

  if (canCheckBiometrics) {
    // Get available biometrics
    final List<BiometricType> availableBiometrics =
        await localAuth.getAvailableBiometrics();

    // Check if fingerprint authentication is available
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      // Authenticate with biometrics
      didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate to proceed',
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: true,
      );
    }
  }

  return didAuthenticate;
}
