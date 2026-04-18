import 'exercise.dart';
import 'meal.dart';
import 'dart:ui';

enum ProgramType { muscle, loss, endurance, wellness, figure }

class ScheduleDay {
  final String dayNumber;
  final String name;
  final String description;
  final bool isTraining;
  final List<WorkoutExercise> exercises;

  ScheduleDay({
    required this.dayNumber,
    required this.name,
    required this.description,
    required this.isTraining,
    this.exercises = const [],
  });
}

class WorkoutExercise {
  final String name;
  final String detail;
  final double progress; // 0.0 to 1.0
  final String? formGifUrl;

  WorkoutExercise({
    required this.name,
    required this.detail,
    required this.progress,
    this.formGifUrl,
  });
}

class WorkoutSplit {
  final String id;
  final String name;
  final String description;
  final List<ScheduleDay> days;

  WorkoutSplit({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
  });
}

class Program {
  final String id;
  final ProgramType type;
  final String num;
  final String name;
  final String? initials; // For avatar
  final Color? color;     // For avatar background
  final Color? textColor; // For avatar text
  final String alias;
  final String badge;
  final String quote;
  final String description; // Detailed note
  final String setsCount;
  final String style;
  final String intensity;
  final List<String> tags;
  final String imagePath;
  final List<ScheduleDay> schedule;
  final List<Meal> meals;
  final List<WorkoutSplit>? splits;

  Program({
    required this.id,
    required this.type,
    required this.num,
    required this.name,
    this.initials,
    this.color,
    this.textColor,
    required this.alias,
    required this.badge,
    required this.quote,
    this.description = '',
    required this.setsCount,
    required this.style,
    required this.intensity,
    required this.tags,
    required this.imagePath,
    required this.schedule,
    required this.meals,
    this.splits,
  });
}
