import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get changes => _client.auth.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String username) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Deletes the signed-in user's account and all their data (cascade).
  Future<void> deleteAccount() async {
    await _client.rpc('delete_my_account');
    await _client.auth.signOut();
  }

  Future<String> username() async {
    final id = currentUser?.id;
    if (id == null) return '';
    final row = await _client
        .from('profiles')
        .select('username')
        .eq('id', id)
        .maybeSingle();
    return (row?['username'] as String?) ?? '';
  }

  Future<void> updateUsername(String username) async {
    final id = currentUser!.id;
    await _client.from('profiles').update({'username': username}).eq('id', id);
  }
}
