class Member {
  final int id;
  final String name;
  final String lastName;
  final String dni;

  Member({
    required this.id,
    required this.name,
    required this.lastName,
    required this.dni,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['idPersona'],
      name: json['nombre'],
      lastName: json['apellidos'],
      dni: json['DNI'],
    );
  }

  String get fullName => '$name $lastName';
}
