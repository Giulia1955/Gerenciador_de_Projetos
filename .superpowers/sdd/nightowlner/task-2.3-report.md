# Task 2.3 — Repositório Firestore

## Status

Completed in the isolated worktree `nightowlner-implementation`.

## Implemented

- Added `fake_cloud_firestore` 3.1.0 as a development dependency.
- Added `ProjectRepository` with project watch/create/update/delete operations.
- Added `TaskRepository` with task watch/create/update/delete/completion operations.
- Used explicit UID-based collection paths:
  - `users/{uid}/projects/{projectId}`
  - `users/{uid}/projects/{projectId}/tasks/{taskId}`
- Added UTC `updatedAt` values on create and update operations.
- Added repository tests using `FakeFirebaseFirestore`.

## Test-first Evidence

The initial repository test was run before repository implementation and failed at compilation because `lib/repositories/project_repository.dart` and `lib/repositories/task_repository.dart` did not exist.

## Verification

- `flutter pub get`: succeeded.
- `flutter test test/repositories`: 2 tests passed.
- `flutter analyze`: no issues found.

## Files

- `pubspec.yaml`
- `pubspec.lock`
- `lib/repositories/project_repository.dart`
- `lib/repositories/task_repository.dart`
- `test/repositories/project_repository_test.dart`

## Concerns

- None observed.
