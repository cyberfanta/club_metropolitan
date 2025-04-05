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
    return day.toLowerCase() == other.day.toLowerCase() && 
           startTime == other.startTime &&
           endTime == other.endTime;
  }

  // To check if a user is enrolled
  bool isMemberEnrolled(int memberId) {
    return enrolledMembers.contains(memberId);
  }

  // Factory constructor to create an activity from JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    // Extract start and end time from the time string (format: "HH:MM - HH:MM")
    final String timeString = json['horaClase'] ?? '';
    String startTime = '';
    String endTime = '';
    
    if (timeString.contains('-')) {
      List<String> timeParts = timeString.split('-').map((s) => s.trim()).toList();
      startTime = timeParts.isNotEmpty ? timeParts[0] : '00:00';
      endTime = timeParts.length > 1 ? timeParts[1] : '00:00';
    } else if (timeString.isNotEmpty) {
      // Si solo hay un tiempo, asumimos que es el inicio y le damos un final por defecto
      startTime = timeString.trim();
      
      // Intentar calcular una hora de finalización sumando 1 hora al inicio
      try {
        if (startTime.contains(':')) {
          List<String> hourMin = startTime.split(':');
          int hour = int.parse(hourMin[0]);
          int min = hourMin.length > 1 ? int.parse(hourMin[1]) : 0;
          
          hour = (hour + 1) % 24; // Sumar 1 hora, ciclo de 24h
          endTime = '$hour:${min.toString().padLeft(2, '0')}';
        } else {
          endTime = startTime; // Si no podemos parsear, usamos el mismo valor
        }
      } catch (e) {
        endTime = '${startTime}+1h'; // Fallback
      }
    } else {
      // Si no hay datos de tiempo, establecemos valores por defecto
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
      capacity: json['capacidad'] ?? 20, // Default capacity to 20 if not provided
      location: json['ubicacion'] ?? 'Sala principal', // Default location if not provided
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
