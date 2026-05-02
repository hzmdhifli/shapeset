import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class SubscriptionProvider with ChangeNotifier {
  bool _isPro = false;
  StreamSubscription? _subscription;

  bool get isPro => _isPro;

  SubscriptionProvider() {
    _loadLocalStatus();
    _initSupabaseSync();
  }

  // Load status from cache for immediate UI response
  Future<void> _loadLocalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('isPro') ?? false;
    notifyListeners();
  }

  // Real-time sync with Supabase
  void _initSupabaseSync() {
    // Listen to Firebase Auth changes to know which user to track
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      _subscription?.cancel(); // Cancel old listeners

      if (firebaseUser != null && firebaseUser.email != null) {
        final email = firebaseUser.email!;
        
        // Listen to the 'profiles' table for this email
        _subscription = Supabase.instance.client
            .from('profiles')
            .stream(primaryKey: ['id'])
            .eq('email', email)
            .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final status = data.first['is_pro'] ?? false;
            if (status != _isPro) {
              setPro(status);
            }
          }
        });
      } else {
        // If logged out, we rely on local status or set to false
        // setPro(false); 
      }
    });
  }

  Future<void> setPro(bool value) async {
    if (_isPro == value) return;
    _isPro = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPro', value);
    notifyListeners();
  }

  bool canAccessDay(String dayNumber) {
    if (_isPro) return true;
    // Allow access only to Day 1
    final dayNum = dayNumber.toLowerCase().replaceAll(RegExp(r'[^0-9]'), '');
    return dayNum == '1';
  }

  bool get canAccessExerciseSelector => _isPro;
  bool get canAccessExport => _isPro;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
