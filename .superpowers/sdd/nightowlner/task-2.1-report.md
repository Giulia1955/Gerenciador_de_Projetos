# Task 2.1 Report — Modelos

## Status

Implemented and committed on `feature/nightowlner-implementation`.

## Changes

- Added `lib/models/project_location.dart` with `fromMap`, `toMap`, `copyWith`, coordinate validation, and equality support.
- Added `lib/models/project_task.dart` with exact task fields, timestamp conversion, `fromMap`, `toMap`, `copyWith`, and equality support.
- Added `lib/models/project.dart` with exact project fields, nested location handling, image URLs, timestamp conversion, `fromMap`, `toMap`, `copyWith`, and equality support.
- Added model tests in `test/models/project_test.dart` and `test/models/project_task_test.dart`.

## Test-first evidence

Before implementation, `flutter test test/models` failed because the three model source files and public classes did not exist.

After implementation:

- `flutter test test/models`: 6 tests passed.
- `flutter analyze`: no issues found.

## Verification commands

```text
flutter test test/models
flutter analyze
```

## Files

- `lib/models/project_location.dart`
- `lib/models/project_task.dart`
- `lib/models/project.dart`
- `test/models/project_test.dart`
- `test/models/project_task_test.dart`
- `.superpowers/sdd/nightowlner/task-2.1-report.md`
