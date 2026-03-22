import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _authRepository.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.signUpWithEmail(email, password);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await _authRepository.signInWithGoogle();
      _setLoading(false);
      return success;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during Google Sign In.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPhoneOTP(String phone) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.signInWithPhone(phone);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred while sending OTP.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyPhoneOTP(String phone, String otp) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.verifyPhoneOTP(phone, otp);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during verification.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    notifyListeners();
  }
}
