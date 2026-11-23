class Validators {
  Validators._();

  static String? validateProjectName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'O nome do projeto é obrigatório';
    }
    final length = name.trim().length;
    if (length < 3 || length > 80) {
      return 'O nome do projeto deve ter entre 3 e 80 caracteres';
    }
    return null;
  }

  static String? validateProjectDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'A descrição do projeto é obrigatória';
    }
    final length = description.trim().length;
    if (length < 10 || length > 500) {
      return 'A descrição do projeto deve ter entre 10 e 500 caracteres';
    }
    return null;
  }

  static String? validateProjectDueDate(DateTime? dueDate) {
    if (dueDate == null) {
      return 'A data limite do projeto é obrigatória';
    }
    final today = DateTime.now();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    if (dueDay.isBefore(todayDay)) {
      return 'A data limite do projeto não pode ser anterior a hoje';
    }
    return null;
  }

  static String? validateTaskName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'O nome da tarefa é obrigatório';
    }
    final length = name.trim().length;
    if (length < 3 || length > 80) {
      return 'O nome da tarefa deve ter entre 3 e 80 caracteres';
    }
    return null;
  }

  static String? validateTaskDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'A descrição da tarefa é obrigatória';
    }
    final length = description.trim().length;
    if (length < 5 || length > 240) {
      return 'A descrição da tarefa deve ter entre 5 e 240 caracteres';
    }
    return null;
  }

  static String? validateAssigneeName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'O nome do responsável é obrigatório';
    }
    final length = name.trim().length;
    if (length < 2 || length > 80) {
      return 'O nome do responsável deve ter entre 2 e 80 caracteres';
    }
    return null;
  }

  static String? validateTaskDueDate(
    DateTime? taskDueDate,
    DateTime projectDueDate,
  ) {
    if (taskDueDate == null) {
      return 'A data limite da tarefa é obrigatória';
    }
    if (taskDueDate.isAfter(projectDueDate)) {
      return 'A data limite da tarefa não pode ser posterior à data limite do projeto';
    }
    return null;
  }

  static String? validateLatitude(double latitude) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      return 'A latitude deve estar entre -90 e 90';
    }
    return null;
  }

  static String? validateLongitude(double longitude) {
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      return 'A longitude deve estar entre -180 e 180';
    }
    return null;
  }
}
