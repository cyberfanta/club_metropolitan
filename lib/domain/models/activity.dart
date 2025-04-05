class Activity {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int trainerId;
  final List<int> enrolledMembers;
  final String day;
  final String time;

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
    required this.time,
    this.trainerName,
    this.trainerLastName,
  });

  // To compare if two activities have the same schedule
  bool conflictsWith(Activity other) {
    return day.toLowerCase() == other.day.toLowerCase() && time == other.time;
  }

  // To check if a user is enrolled
  bool isMemberEnrolled(int memberId) {
    return enrolledMembers.contains(memberId);
  }

  // Factory constructor to create an activity from JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['idActividadColectiva'],
      name: json['nombreActividadColectiva'],
      description: json['descripcion'],
      imageUrl: json['imagen'],
      trainerId: json['entrenadorResponsable'],
      enrolledMembers: List<int>.from(json['sociosInscritos']),
      day: json['diaClase'],
      time: json['horaClase'],
    );
  }

  // Method to get the corrected image path
  String get imageAssetPath {
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
}
