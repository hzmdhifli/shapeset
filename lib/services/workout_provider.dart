import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/program.dart';

class CompletedSession {
  final String programId;
  final String dayId;
  final String dayName;
  final DateTime date;
  final List<String> musclesTrained;

  CompletedSession({
    required this.programId,
    required this.dayId,
    required this.dayName,
    required this.date,
    required this.musclesTrained,
  });

  Map<String, dynamic> toJson() => {
    'programId': programId,
    'dayId': dayId,
    'dayName': dayName,
    'date': date.toIso8601String(),
    'musclesTrained': musclesTrained,
  };

  factory CompletedSession.fromJson(Map<String, dynamic> json) => CompletedSession(
    programId: json['programId'],
    dayId: json['dayId'],
    dayName: json['dayName'],
    date: DateTime.parse(json['date']),
    musclesTrained: List<String>.from(json['musclesTrained']),
  );
}

class WorkoutProvider with ChangeNotifier {
  List<CompletedSession> _history = [];
  String? _activeProgramId;

  List<CompletedSession> get history => _history;
  String? get activeProgramId => _activeProgramId;

  WorkoutProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('workout_history');
    if (historyJson != null) {
      final List<dynamic> decoded = json.decode(historyJson);
      _history = decoded.map((item) => CompletedSession.fromJson(item)).toList();
    }
    _activeProgramId = prefs.getString('active_program_id');
    notifyListeners();
  }

  Future<void> setActiveProgram(String programId) async {
    if (_activeProgramId == programId) return;
    
    _activeProgramId = programId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_program_id', _activeProgramId!);
    notifyListeners();
  }

  Future<void> completeSession(CompletedSession session) async {
    _history.add(session);
    _activeProgramId = session.programId;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_history', json.encode(_history.map((s) => s.toJson()).toList()));
    await prefs.setString('active_program_id', _activeProgramId!);
    
    notifyListeners();
  }

  bool isDayCompleted(String programId, String dayId) {
    return _history.any((s) => s.programId == programId && s.dayId == dayId);
  }

  CompletedSession? getLastCompletedSession() {
    if (_history.isEmpty) return null;
    return _history.last;
  }

  int getWeekCompletionCount(String programId) {
    // Simplified: count completed days for this program in the last 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return _history.where((s) => s.programId == programId && s.date.isAfter(sevenDaysAgo)).length;
  }
}
