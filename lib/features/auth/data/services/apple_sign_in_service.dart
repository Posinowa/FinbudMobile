import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInService {
  /// Apple hesabıyla giriş yapar.
  /// Başarılı olursa [AppleSignInResult] döner, iptal veya hata durumunda null döner.
  static Future<AppleSignInResult?> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // identityToken her zaman gelmeli
      final identityToken = credential.identityToken;
      if (identityToken == null) {
        print('[AppleSignIn] identityToken null');
        return null;
      }

      // Email ve isim sadece ilk girişte gelir
      final email = credential.email ?? '';
      final givenName = credential.givenName ?? '';
      final familyName = credential.familyName ?? '';
      final fullName = [givenName, familyName].where((s) => s.isNotEmpty).join(' ');

      print('[AppleSignIn] giriş başarılı — email: ${email.isNotEmpty ? email : "(boş, sonraki giriş)"}');

      return AppleSignInResult(
        identityToken: identityToken,
        email: email,
        fullName: fullName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        print('[AppleSignIn] kullanıcı iptal etti');
      } else {
        print('[AppleSignIn] HATA: ${e.code} — ${e.message}');
      }
      return null;
    } catch (e) {
      print('[AppleSignIn] beklenmeyen HATA: $e');
      return null;
    }
  }
}

class AppleSignInResult {
  final String identityToken;
  final String email;
  final String fullName;

  const AppleSignInResult({
    required this.identityToken,
    required this.email,
    required this.fullName,
  });
}
