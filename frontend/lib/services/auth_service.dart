import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import 'user_service.dart';

/// Handles every authentication concern for MaxilloAI:
/// - Email/password registration (captures full name, age, gender at signup)
/// - Email/password login with optional "remember me"
/// - Forgot password (email reset link)
/// - Google Sign-In
/// - Sign out / delete account
///
/// On every successful registration or first social sign-in, a full
/// profile document is created in Firestore via [UserService] so that
/// ALL of the user's details are stored and available on the Profile
/// screen and throughout the app.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => _auth.currentUser != null;

  /// Registers a brand-new patient account and stores every collected
  /// detail (name, age, gender, email) in Firestore immediately.
  Future<AppUser> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Could not create account. Please try again.',
      );
    }

    await user.updateDisplayName(fullName);

    final appUser = AppUser(
      uid: user.uid,
      fullName: fullName,
      email: email.trim(),
      age: age,
      gender: gender,
    );

    await _userService.createUserProfile(appUser);
    return appUser;
  }

  Future<AppUser?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) return null;
    return _userService.getOrCreateUserProfile(
      uid: uid,
      email: email.trim(),
      fallbackName: credential.user?.displayName ?? 'MaxilloAI User',
    );
  }

  Future<AppUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) return null;

    return _userService.getOrCreateUserProfile(
      uid: user.uid,
      email: user.email ?? googleUser.email,
      fallbackName: user.displayName ?? googleUser.displayName ?? 'MaxilloAI User',
      photoUrl: user.photoURL ?? googleUser.photoUrl,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut().catchError((_) {}),
    ]);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _userService.deleteUserData(user.uid);
    await user.delete();
  }

  /// Maps FirebaseAuthException codes to friendly, patient-facing copy.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return error.toString();
  }
}
