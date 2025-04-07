import 'trainer.dart';

class Activity {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int trainerId;
  final List<int> enrolledMembers;
  final String day;
  final String startTime;
  final String endTime;
  final int capacity;
  final String location;

  // Additional fields for UI
  String? trainerName;
  String? trainerLastName;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.trainerId,
    required this.enrolledMembers,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.location,
    this.trainerName,
    this.trainerLastName,
  });

  // To compare if two activities have the same schedule
  bool conflictsWith(Activity other) {
    if (day.toLowerCase() != other.day.toLowerCase()) {
      return false;
    }

    // Compare schedules using numerical time values
    final selfStartMinutes = startHour * 60 + startMinute;
    final selfEndMinutes = endHour * 60 + endMinute;
    final otherStartMinutes = other.startHour * 60 + other.startMinute;
    final otherEndMinutes = other.endHour * 60 + other.endMinute;

    // There's a conflict if any part of the schedule overlaps
    return (selfStartMinutes < otherEndMinutes &&
        selfEndMinutes > otherStartMinutes);
  }

  // To check if a user is enrolled
  bool isMemberEnrolled(int memberId) {
    return enrolledMembers.contains(memberId);
  }

  // Getters for start and end hours and minutes
  int get startHour {
    try {
      final parts = startTime.split(':');

      return int.parse(parts[0]);
    } catch (e) {
      return 0;
    }
  }

  int get startMinute {
    try {
      final parts = startTime.split(':');

      return int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  int get endHour {
    try {
      final parts = endTime.split(':');

      return int.parse(parts[0]);
    } catch (e) {
      return 0;
    }
  }

  int get endMinute {
    try {
      final parts = endTime.split(':');

      return int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  // Trainer getter for simplified access
  Trainer get trainer {
    return Trainer(
      id: trainerId,
      name: trainerName ?? 'Unknown',
      lastName: trainerLastName ?? '',
      dni: '',
      cv: '',
      activities: [],
    );
  }

  // Factory constructor to create an activity from JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    // Extract start and end time from the time string (format: "HH:MM - HH:MM")
    final String timeString = json['horaClase'] ?? '';
    String startTime = '';
    String endTime = '';

    if (timeString.contains('-')) {
      List<String> timeParts =
          timeString.split('-').map((s) => s.trim()).toList();
      startTime = timeParts.isNotEmpty ? timeParts[0] : '00:00';
      endTime = timeParts.length > 1 ? timeParts[1] : '00:00';
    } else if (timeString.isNotEmpty) {
      // If there is only one time, assume it's the start and provide a default end time
      startTime = timeString.trim();

      // Try to calculate an end time by adding 1 hour to the start time
      try {
        if (startTime.contains(':')) {
          List<String> hourMin = startTime.split(':');
          int hour = int.parse(hourMin[0]);
          int min = hourMin.length > 1 ? int.parse(hourMin[1]) : 0;

          hour = (hour + 1) % 24; // Add 1 hour, 24-hour cycle
          endTime = '$hour:${min.toString().padLeft(2, '0')}';
        } else {
          endTime = startTime; // If we can't parse, use the same value
        }
      } catch (e) {
        endTime = '$startTime+1h'; // Fallback
      }
    } else {
      // If there is no time data, set default values
      startTime = '00:00';
      endTime = '00:00';
    }

    return Activity(
      id: json['idActividadColectiva'],
      name: json['nombreActividadColectiva'],
      description: json['descripcion'],
      imageUrl: json['imagen'],
      trainerId: json['entrenadorResponsable'],
      enrolledMembers: List<int>.from(json['sociosInscritos']),
      day: json['diaClase'],
      startTime: startTime,
      endTime: endTime,
      capacity: json['capacidad'] ?? 20,
      // Default capacity to 20 if not provided
      location:
          json['ubicacion'] ??
          'Sala principal', // Default location if not provided
    );
  }

  // For backward compatibility
  String get time => '$startTime - $endTime';

  // Method to get the corrected image path
  String get imagePath {
    // We fix the path for erroneous image references
    String path = imageUrl;

    // Fix error in source data (simages/ -> images/)
    if (path.startsWith('simages/')) {
      path = path.replaceFirst('simages/', 'images/');
    }

    // Make sure the path starts with 'assets/'
    if (!path.startsWith('assets/')) {
      path = 'assets/$path';
    }

    return path;
  }

  // For backward compatibility
  String get imageAssetPath => imagePath;
}
