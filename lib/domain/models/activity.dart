class Activity {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int trainerId;
  final List<int> enrolledMembers;
  final String day;
  final String time;
  
  // Campos adicionales para la UI
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

  // Para comparar si dos actividades tienen el mismo horario
  bool conflictsWith(Activity other) {
    return day.toLowerCase() == other.day.toLowerCase() && time == other.time;
  }

  // Para verificar si un usuario está inscrito
  bool isMemberEnrolled(int memberId) {
    return enrolledMembers.contains(memberId);
  }

  // Factory constructor para crear una actividad desde JSON
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

  // Método para obtener la ruta de imagen corregida
  String get imageAssetPath {
    // Corregimos la ruta para referencias a imágenes erróneas
    String path = imageUrl;
    
    // Corregir error en los datos de origen (simages/ -> images/)
    if (path.startsWith('simages/')) {
      path = path.replaceFirst('simages/', 'images/');
    }
    
    // Asegurarnos de que la ruta comience con 'assets/'
    if (!path.startsWith('assets/')) {
      path = 'assets/$path';
    }
    
    return path;
  }
} 