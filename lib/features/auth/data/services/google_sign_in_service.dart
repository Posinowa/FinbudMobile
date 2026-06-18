import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // iOS client ID — Info.plist'teki GIDClientID ile aynı olmalı
    clientId: '1048418570560-6gdut5dp98tihud7un2lr7tm50eegi1f.apps.googleusercontent.com',
    // Web client ID — iOS ve Android için idToken üretiminde kullanılır (aynı Firebase projesi)
    serverClientId: '1048418570560-h0b2vam3kds8cfqbp3q5po18m0ovqu7q.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// Google hesabıyla giriş yapar ve server'a gönderilecek ID token'ı döner.
  /// Kullanıcı iptal ederse veya hata olursa null döner.
  static Future<String?> signIn() async {
    try {
      // Önceki oturumu temizle (her seferinde hesap seçimi göster)
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        print('[GoogleSignIn] account null — kullanıcı iptal etti');
        return null;
      }

      print('[GoogleSignIn] account alındı: ${account.email}');
      final auth = await account.authentication;
      print('[GoogleSignIn] idToken: ${auth.idToken != null ? "VAR" : "NULL"}');
      print('[GoogleSignIn] accessToken: ${auth.accessToken != null ? "VAR" : "NULL"}');
      return auth.idToken;
    } catch (e) {
      print('[GoogleSignIn] HATA: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
