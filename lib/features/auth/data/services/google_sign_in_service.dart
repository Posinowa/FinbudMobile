import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // iOS client ID — Info.plist'teki GIDClientID ile aynı olmalı
    clientId: '1048418570560-6gdut5dp98tihud7un2lr7tm50eegi1f.apps.googleusercontent.com',
    // Web/server client ID — backend'e gönderilen ID token için
    serverClientId: '197224562444-4jrgp0ng8vs9el2rvenc93o0qaff09c4.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// Google hesabıyla giriş yapar ve server'a gönderilecek ID token'ı döner.
  /// Kullanıcı iptal ederse veya hata olursa null döner.
  static Future<String?> signIn() async {
    try {
      // Önceki oturumu temizle (her seferinde hesap seçimi göster)
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
