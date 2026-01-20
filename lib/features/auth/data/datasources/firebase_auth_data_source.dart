import 'package:firebase_auth/firebase_auth.dart';
import 'package:gig_task_manager/core/errors/auth_exception.dart';
import 'package:gig_task_manager/features/auth/domain/entities/user_entity.dart';

abstract class FirebaseAuthDataSource {
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<UserEntity?> watchAuthState();

  UserEntity? getCurrentUser();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthDataSourceImpl(this.firebaseAuth);

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('User is null');
      }
      return UserEntity(uid: user.uid, email: user.email ?? '');
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Unexpected error: $e');
    }
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('User is null');
      }
      return UserEntity(uid: user.uid, email: user.email ?? '');
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Unexpected error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserEntity(uid: user.uid, email: user.email ?? '');
    });
  }

  @override
  UserEntity? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserEntity(uid: user.uid, email: user.email ?? '');
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('No user found with this email.');
      case 'invalid-credential':
        return const AuthException('Invalid email or password.');
      case 'wrong-password':
        return const AuthException('Wrong password provided.');
      case 'email-already-in-use':
        return const AuthException(
          'An account already exists with this email.',
        );
      case 'invalid-email':
        return const AuthException('Invalid email address.');
      case 'weak-password':
        return const AuthException('Password is too weak.');
      case 'user-disabled':
        return const AuthException('This user account has been disabled.');
      case 'too-many-requests':
        return const AuthException(
          'Too many requests. Please try again later.',
        );
      case 'operation-not-allowed':
        return const AuthException('This operation is not allowed.');
      case 'network-request-failed':
        return const AuthException('Please check your internet connection.');
      default:
        return AuthException(
          'Authentication failed: ${e.message ?? "Unknown error"}',
        );
    }
  }
}
