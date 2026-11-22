import 'package:apk_auth/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    group('project name', () {
      test('requires a name', () {
        expect(Validators.validateProjectName(null), 'O nome do projeto é obrigatório');
        expect(Validators.validateProjectName('   '), 'O nome do projeto é obrigatório');
      });

      test('requires between 3 and 80 characters', () {
        expect(Validators.validateProjectName('Ab'), 'O nome do projeto deve ter entre 3 e 80 caracteres');
        expect(Validators.validateProjectName('A' * 81), 'O nome do projeto deve ter entre 3 e 80 caracteres');
        expect(Validators.validateProjectName('ABC'), isNull);
        expect(Validators.validateProjectName('A' * 80), isNull);
      });
    });

    group('project description', () {
      test('requires a description', () {
        expect(Validators.validateProjectDescription(null), 'A descrição do projeto é obrigatória');
        expect(Validators.validateProjectDescription(''), 'A descrição do projeto é obrigatória');
      });

      test('requires between 10 and 500 characters', () {
        expect(Validators.validateProjectDescription('123456789'), 'A descrição do projeto deve ter entre 10 e 500 caracteres');
        expect(Validators.validateProjectDescription('A' * 501), 'A descrição do projeto deve ter entre 10 e 500 caracteres');
        expect(Validators.validateProjectDescription('A' * 10), isNull);
        expect(Validators.validateProjectDescription('A' * 500), isNull);
      });
    });

    group('project due date', () {
      test('is required', () {
        expect(Validators.validateProjectDueDate(null), 'A data limite do projeto é obrigatória');
      });

      test('cannot be before now', () {
        expect(Validators.validateProjectDueDate(DateTime.now().subtract(const Duration(days: 1))), 'A data limite do projeto não pode ser anterior a hoje');
        expect(Validators.validateProjectDueDate(DateTime.now().add(const Duration(days: 1))), isNull);
      });
    });

    group('task name', () {
      test('requires a name', () {
        expect(Validators.validateTaskName(null), 'O nome da tarefa é obrigatório');
        expect(Validators.validateTaskName('  '), 'O nome da tarefa é obrigatório');
      });

      test('requires between 3 and 80 characters', () {
        expect(Validators.validateTaskName('AB'), 'O nome da tarefa deve ter entre 3 e 80 caracteres');
        expect(Validators.validateTaskName('A' * 81), 'O nome da tarefa deve ter entre 3 e 80 caracteres');
        expect(Validators.validateTaskName('ABC'), isNull);
      });
    });

    group('task description', () {
      test('requires a description', () {
        expect(Validators.validateTaskDescription(null), 'A descrição da tarefa é obrigatória');
      });

      test('requires between 5 and 240 characters', () {
        expect(Validators.validateTaskDescription('1234'), 'A descrição da tarefa deve ter entre 5 e 240 caracteres');
        expect(Validators.validateTaskDescription('A' * 241), 'A descrição da tarefa deve ter entre 5 e 240 caracteres');
        expect(Validators.validateTaskDescription('A' * 5), isNull);
        expect(Validators.validateTaskDescription('A' * 240), isNull);
      });
    });

    group('assignee name', () {
      test('requires a name', () {
        expect(Validators.validateAssigneeName(null), 'O nome do responsável é obrigatório');
        expect(Validators.validateAssigneeName(' '), 'O nome do responsável é obrigatório');
      });

      test('requires between 2 and 80 characters', () {
        expect(Validators.validateAssigneeName('A'), 'O nome do responsável deve ter entre 2 e 80 caracteres');
        expect(Validators.validateAssigneeName('A' * 81), 'O nome do responsável deve ter entre 2 e 80 caracteres');
        expect(Validators.validateAssigneeName('AB'), isNull);
        expect(Validators.validateAssigneeName('A' * 80), isNull);
      });
    });

    group('task due date', () {
      final projectDueDate = DateTime(2030, 1, 10);

      test('is required', () {
        expect(Validators.validateTaskDueDate(null, projectDueDate), 'A data limite da tarefa é obrigatória');
      });

      test('cannot be after the project due date', () {
        expect(Validators.validateTaskDueDate(DateTime(2030, 1, 11), projectDueDate), 'A data limite da tarefa não pode ser posterior à data limite do projeto');
        expect(Validators.validateTaskDueDate(projectDueDate, projectDueDate), isNull);
        expect(Validators.validateTaskDueDate(DateTime(2030, 1, 9), projectDueDate), isNull);
      });
    });

    group('coordinates', () {
      test('validates latitude range', () {
        expect(Validators.validateLatitude(-90), isNull);
        expect(Validators.validateLatitude(90), isNull);
        expect(Validators.validateLatitude(-90.1), 'A latitude deve estar entre -90 e 90');
        expect(Validators.validateLatitude(90.1), 'A latitude deve estar entre -90 e 90');
        expect(Validators.validateLatitude(double.nan), 'A latitude deve estar entre -90 e 90');
      });

      test('validates longitude range', () {
        expect(Validators.validateLongitude(-180), isNull);
        expect(Validators.validateLongitude(180), isNull);
        expect(Validators.validateLongitude(-180.1), 'A longitude deve estar entre -180 e 180');
        expect(Validators.validateLongitude(180.1), 'A longitude deve estar entre -180 e 180');
        expect(Validators.validateLongitude(double.nan), 'A longitude deve estar entre -180 e 180');
      });
    });
  });
}
