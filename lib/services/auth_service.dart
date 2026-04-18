import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Returns the currently signed-in Firebase user, or null.
  static User? get currentUser => _auth.currentUser;

  /// Sign in with Google — opens native account picker, exchanges credential
  /// with Firebase, and saves profile data locally.
  static Future<User?> signInWithGoogle() async {
    // Force sign out of any existing session to ensure the account picker shows
    await _googleSignIn.signOut();
    
    // Trigger the Google account picker
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    // Get auth details from the selected Google account
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a Firebase credential using the Google tokens
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign into Firebase with the Google credential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;
    if (user != null) {
      await _saveUserToPrefs(user);
    }
    return user;
  }

  /// Sign in with Apple — exchanges credentials with Firebase.
  static Future<User?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final AuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;
    if (user != null) {
      await _saveUserToPrefs(user);
    }
    return user;
  }

  /// Sign out from both Firebase and Google
  static Future<void> signOut() async {
    try {
      // disconnect() forces the account picker to show up next time
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Don't clear everything, just the login state
  }

  /// Saves the signed-in user's info to SharedPreferences for UI use
  static Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', user.displayName ?? 'Athlete');
    await prefs.setString('userEmail', user.email ?? '');
    if (user.photoURL != null) {
      await prefs.setString('userPhoto', user.photoURL!);
    }
    await prefs.setBool('isLoggedIn', true);
  }
}
