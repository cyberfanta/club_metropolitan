class UiTextEs {
  String get title {
    return "Club Metropolitan App Challenge";
  }

  String get yes {
    return "Sí";
  }

  String get no {
    return "No";
  }

  String get appCloseTitleText {
    return "ADVERTENCIA";
  }

  String get appCloseSubText {
    return "¿Estás seguro?";
  }

  String get appCloseContext {
    return "Estás a punto de cerrar la aplicación.";
  }

  // User Activities View
  String get myActivities {
    return "Mis Actividades";
  }

  String get noActivitiesEnrolled {
    return "No tienes actividades inscritas";
  }

  String get exploreActivities {
    return "Explorar actividades";
  }

  String get viewAllActivities {
    return "Ver todas las actividades";
  }

  // All Activities View
  String get allActivities {
    return "Todas las Actividades";
  }

  String get searchActivities {
    return "Buscar por nombre, día o entrenador";
  }

  String get noActivitiesFound {
    return "No se encontraron actividades";
  }

  String get enrolled {
    return "Inscrito";
  }

  String get adjustable {
    return "Ajustable";
  }

  // Activity Detail
  String get trainer {
    return "Entrenador";
  }

  String get description {
    return "Descripción";
  }

  String get cancelEnrollment {
    return "Cancelar inscripción";
  }

  String get enroll {
    return "Inscribirse";
  }

  String get trainerNotAssigned {
    return "Entrenador no asignado";
  }

  String get participants {
    return "participantes";
  }

  String get timeConflict {
    return "Conflicto de horario";
  }

  String get conflictDescription {
    return "Ya estás inscrito en \"{0}\" el {1} de {2} a {3}. Puedes reemplazar esa actividad por esta si lo deseas.";
  }

  // Dialog texts
  String get changeActivity {
    return "¿Cambiar actividad?";
  }

  String get changeActivityQuestion {
    return "¿Deseas cancelar tu inscripción a \"{0}\" e inscribirte a \"{1}\"?";
  }

  String get yesChange {
    return "Sí, cambiar";
  }

  String get changeActivityFor {
    return "Cambiar {0} por esta actividad";
  }

  String get conflictingSchedule {
    return "Horario coincidente";
  }

  String get alreadyEnrolledMessage {
    return "Ya estás inscrito en \"{0}\" el mismo día y hora. Puedes reemplazar esa actividad por esta si lo deseas.";
  }

  // Snackbar messages
  String get enrollmentCancelled {
    return "Has cancelado tu inscripción a {0}";
  }

  String get enrollmentSuccessful {
    return "Te has inscrito a {0}";
  }

  String get activityChanged {
    return "Has cambiado {0} por {1}";
  }

  // Days of the week
  String getDayName(String dayKey) {
    switch (dayKey.toLowerCase()) {
      case 'lunes':
        return 'Lunes';
      case 'martes':
        return 'Martes';
      case 'miercoles':
        return 'Miércoles';
      case 'jueves':
        return 'Jueves';
      case 'viernes':
        return 'Viernes';
      case 'sabado':
        return 'Sábado';
      case 'domingo':
        return 'Domingo';
      default:
        return dayKey;
    }
  }

  String get cancelEnrollmentTitle => 'Cancelar Inscripción';
  String get cancelEnrollmentQuestion => '¿Estás seguro que deseas cancelar tu inscripción en {0}?';
  String get yesCancel => 'Sí, Cancelar';
}
