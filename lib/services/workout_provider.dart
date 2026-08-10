import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/program.dart';
import '../models/mock_data.dart';

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
  Map<String, int> _programRepetitions = {};

  List<CompletedSession> get history => _history;
  String? get activeProgramId => _activeProgramId;
  Map<String, int> get programRepetitions => _programRepetitions;

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
    
    final repsJson = prefs.getString('program_repetitions');
    if (repsJson != null) {
      final Map<String, dynamic> decoded = json.decode(repsJson);
      _programRepetitions = decoded.map((key, value) => MapEntry(key, value as int));
    }
    
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
    
    // Check if program is fully completed
    final program = [...mockPrograms, ...mockFemalePrograms, ...mockSixPackPrograms].firstWhere(
      (p) => p.id == session.programId,
      orElse: () => mockPrograms[0]
    );
    
    final trainingDays = program.schedule.where((day) => day.isTraining).toList();
    final completedDaysCount = _history.where((s) => s.programId == session.programId).length;
    
    if (completedDaysCount >= trainingDays.length) {
      // Program finished! Increment reps and clear history for this program
      _programRepetitions[session.programId] = (_programRepetitions[session.programId] ?? 0) + 1;
      _history.removeWhere((s) => s.programId == session.programId);
      
      await prefs.setString('program_repetitions', json.encode(_programRepetitions));
    }
    
    await prefs.setString('workout_history', json.encode(_history.map((s) => s.toJson()).toList()));
    await prefs.setString('active_program_id', _activeProgramId!);
    
    notifyListeners();
  }

  bool isDayCompleted(String programId, String dayId) {
    return _history.any((s) => s.programId == programId && s.dayId == dayId);
  }

  Future<void> resetSession(String programId, String dayId) async {
    _history.removeWhere((s) => s.programId == programId && s.dayId == dayId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workout_history', json.encode(_history.map((s) => s.toJson()).toList()));
    notifyListeners();
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
