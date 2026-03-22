import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signInWithPhone(String phone) async {
    await _supabase.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyPhoneOTP(String phone, String otp) async {
    return await _supabase.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
