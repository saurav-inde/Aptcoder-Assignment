import 'package:aptcoder/core/services/databse_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Note: You may need to import a package like 'async' or define 'unawaited'
// if you choose to use it exactly as shown in the docs.
// import 'package:pedantic/pedantic.dart';
// Or define a simple unawaited helper if not using an external package:
void unawaited(Future<void>? future) {} // Placeholder/Helper

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Stream for Firebase Auth state changes (useful for your UI)
  Stream<User?> get user => _auth.authStateChanges();

  // ===============================
  //  Initialization (Per Docs)
  // ===============================
  /// Initializes the Google Sign-In client and sets up event listeners.
  /// This should be called once when your application starts.
  void initializeGoogleSignIn({
    String? clientId,
    required String serverClientId,
    // Add handlers as arguments if you want to pass them in
    // required Function(GoogleSignInAuthentication?) handleAuthEvent,
    // required Function(Object) handleError,
  }) {
    // We use unawaited to ensure app startup isn't blocked by initialization.
    unawaited(
      _googleSignIn
          .initialize(clientId: clientId, serverClientId: serverClientId)
          .then((_) {
            // Set up the stream listener for authentication state changes
            _googleSignIn.authenticationEvents
                // The docs use _handleAuthenticationEvent, which is not defined here,
                // but this is where you would hook up your UI state logic.
                .listen((event) {
                  // Example of what a handler might do:
                  // Check event for success/failure and update UI/State management.
                  print('Google Auth Event Received: $event');
                })
                .onError((error) {
                  print('Google Auth Stream Error: $error');
                });

            // Attempt to restore a previous sign-in session silently
            _googleSignIn.attemptLightweightAuthentication();
          }),
    );
  }

  // ===============================
  //  Sign in with Google (Corrected)
  // ===============================

  Future<UserCredential> signInWithGoogle(String? role) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
        .authenticate();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = googleUser?.authentication;

    // Create a new credential
    // 3. Sign in to Firebase
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
    // 4. 🔥 SAVE / UPDATE USER IN FIRESTORE
    await DatabaseService().saveUser(user.uid, {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'role': role ?? 'student', // don't overwrite role
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Once signed in, return the UserCredential
    return userCredential;
  }

  // ===============================
  //  Logout (Google + Firebase)
  // ===============================
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
