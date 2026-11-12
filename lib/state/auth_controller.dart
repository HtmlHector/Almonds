import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo) {
    _signedIn = _repo.currentUser != null;
    _sub = _repo.changes.listen((state) {
      final now = state.session != null;
      if (now != _signedIn) {
        _signedIn = now;
        username = '';
        if (now) loadProfile();
        notifyListeners();
      }
    });
    if (_signedIn) loadProfile();
  }

  final AuthRepository _repo;
  late final StreamSubscription<AuthState> _sub;

  bool _signedIn = false;
  bool busy = false;
  String? error;
  String username = '';

  bool get signedIn => _signedIn;
  String get email => _repo.currentUser?.email ?? '';
  String? get userId => _repo.currentUser?.id;

  Future<void> loadProfile() async {
    try {
      username = await _repo.username();
      notifyListeners();
    } catch (_) {
      /* profile is cosmetic; ignore */
    }
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      error = e.message;
    } on PostgrestException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Something went wrong. Check your connection and try again.';
    } finally {
      busy = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> signIn(String email, String password) =>
      _run(() => _repo.signIn(email.trim(), password));

  Future<bool> signUp(String email, String password, String username) =>
      _run(() => _repo.signUp(email.trim(), password, username.trim()));

  Future<bool> changeUsername(String name) => _run(() async {
    await _repo.updateUsername(name.trim());
    username = name.trim();
  });

  Future<void> signOut() => _repo.signOut();

  Future<bool> deleteAccount() => _run(_repo.deleteAccount);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
