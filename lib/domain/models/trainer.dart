class Trainer {
  final int id;
  final String name;
  final String lastName;
  final String dni;
  final String cv;
  final List<int> activities;

  Trainer({
    required this.id,
    required this.name,
    required this.lastName,
    required this.dni,
    required this.cv,
    required this.activities,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['idTrainer'],
      name: json['nombre'],
      lastName: json['apellidos'],
      dni: json['DNI'],
      cv: json['cv'],
      activities: List<int>.from(json['actividades']),
    );
  }

  String get fullName => '$name $lastName';
} 