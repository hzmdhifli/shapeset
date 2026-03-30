import 'exercise.dart';
import 'meal.dart';

enum ProgramType { muscle, loss, endurance }

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

  WorkoutExercise({
    required this.name,
    required this.detail,
    required this.progress,
  });
}

class Program {
  final String id;
  final ProgramType type;
  final String num;
  final String name;
  final String alias;
  final String badge;
  final String quote;
  final String setsCount;
  final String style;
  final String intensity;
  final List<String> tags;
  final String imagePath;
  final List<ScheduleDay> schedule;
  final List<Meal> meals;

  Program({
    required this.id,
    required this.type,
    required this.num,
    required this.name,
    required this.alias,
    required this.badge,
    required this.quote,
    required this.setsCount,
    required this.style,
    required this.intensity,
    required this.tags,
    required this.imagePath,
    required this.schedule,
    required this.meals,
  });
}
