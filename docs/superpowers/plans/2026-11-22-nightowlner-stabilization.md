# NightOwlner Stabilization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stabilize and verify the implemented NightOwlner worktree for Android release-quality testing.

**Architecture:** Preserve the existing Provider, repository, model, view and widget structure. Apply isolated fixes, verify real integrations, deploy Firebase rules, run the complete validation cycle and split commits by phase.

**Tech Stack:** Flutter, Dart, Firebase Auth/Firestore/Storage, Provider, table_calendar, geolocator, image_picker, http.

## Global Constraints

- Work only in `.worktrees/nightowlner-implementation`.
- Preserve Android as the primary target and the existing dark ThemeData.
- Keep project/task data under `users/{uid}/projects/{projectId}/tasks/{taskId}`.
- Keep images under `projects/{uid}/{projectId}/images/{fileName}`.
- Deploy `firestore.rules` and `storage.rules` only after local validation.
- Do not claim manual success unless an Android device or emulator was exercised.

---

### Task 1: Baseline compilation and analyzer evidence

**Files:**
- Inspect: `lib/view/calendar_page.dart`
- Inspect: `lib/**/*.dart`

- [ ] **Step 1:** Run `flutter analyze` in the worktree.
- [ ] **Step 2:** Record all errors and warnings without changing code.
- [ ] **Step 3:** Run `flutter test` to establish the baseline.
- [ ] **Step 4:** Run `flutter build apk --debug` to establish the baseline blocker.

### Task 2: Fix calendar compilation and analyzer warnings

**Files:**
- Modify: `lib/view/calendar_page.dart`
- Test: `test/providers/calendar_provider_test.dart`

- [ ] **Step 1:** Add a regression test that verifies normalized event lookup for project/task dates.
- [ ] **Step 2:** Run `flutter test test/providers/calendar_provider_test.dart`; confirm it passes or add the missing red test only if behavior is absent.
- [ ] **Step 3:** Rename the conflicting `day` callback/local identifier or namespace it, preserving `DateTime` normalization.
- [ ] **Step 4:** Remove the unused `ids` declaration if it exists in calendar code.
- [ ] **Step 5:** Run targeted tests and `dart format lib/view/calendar_page.dart lib/providers/calendar_provider.dart`.

### Task 3: Fix remaining analyzer findings and bare if statements

**Files:**
- Inspect and modify: files reported by `flutter analyze`
- Test: affected widget/unit tests

- [ ] **Step 1:** Run `flutter analyze` and capture exact findings.
- [ ] **Step 2:** For each bare `if`, add an explicit block or replace it with the minimal clear equivalent.
- [ ] **Step 3:** Remove unused declarations/imports instead of suppressing analyzer warnings.
- [ ] **Step 4:** Run `flutter analyze` and verify no findings remain in the worktree.

### Task 4: Review project details and task CRUD

**Files:**
- Modify: `lib/view/project_detail_page.dart`
- Modify: `lib/view/task_form_page.dart`
- Inspect: `lib/components/task_tile.dart`
- Test: `test/view/project_detail_page_test.dart` if present

- [ ] **Step 1:** Verify project detail shows description, due date, update time, location and image URLs.
- [ ] **Step 2:** Verify task create/edit deadlines cannot exceed project deadline.
- [ ] **Step 3:** Verify complete/reopen and delete actions update state and report repository errors.
- [ ] **Step 4:** Add or update focused widget tests for visible empty and task states.
- [ ] **Step 5:** Run affected tests and commit the task/detail phase.

### Task 5: Review project image and location integrations

**Files:**
- Inspect/modify: `lib/view/project_form_page.dart`
- Inspect/modify: `lib/providers/media_provider.dart`
- Inspect/modify: `lib/repositories/storage_repository.dart`
- Inspect/modify: `lib/repositories/location_repository.dart`

- [ ] **Step 1:** Verify image selection is optional, capped at five and compressed with `imageQuality: 82` or equivalent.
- [ ] **Step 2:** Verify upload path is `projects/{uid}/{projectId}/images/{fileName}` and URLs are written to project data.
- [ ] **Step 3:** Verify location permission is requested only by the GPS button and denied/unavailable states are actionable.
- [ ] **Step 4:** Remove any duplicate or dead media/location code and run relevant tests/analyzer.
- [ ] **Step 5:** Commit the integration review phase.

### Task 6: Review API fallback and wisdom cache

**Files:**
- Inspect/modify: `lib/repositories/wisdom_repository.dart`
- Inspect/modify: `lib/providers/wisdom_provider.dart`
- Test: `test/repositories/wisdom_repository_test.dart`

- [ ] **Step 1:** Verify ZenQuotes is first, Advice Slip is second and local fallback is last.
- [ ] **Step 2:** Verify timeout and invalid-response handling do not block dashboard rendering.
- [ ] **Step 3:** Verify cache is memory/session scoped and refreshes for a new day.
- [ ] **Step 4:** Run wisdom tests and analyzer.
- [ ] **Step 5:** Commit the API fallback phase.

### Task 7: Review calendar integration

**Files:**
- Modify: `lib/view/calendar_page.dart`
- Inspect: `lib/providers/calendar_provider.dart`
- Inspect: `lib/components/calendar_event_tile.dart`
- Test: `test/providers/calendar_provider_test.dart`

- [ ] **Step 1:** Verify real projects/tasks are grouped into normalized calendar events.
- [ ] **Step 2:** Verify project/task markers and legend differentiate event types.
- [ ] **Step 3:** Verify tapping an event opens project details or the appropriate task context.
- [ ] **Step 4:** Run calendar tests and analyzer.
- [ ] **Step 5:** Commit the calendar review phase.

### Task 8: Deploy Firebase rules

**Files:**
- Modify/inspect: `firestore.rules`
- Modify/inspect: `storage.rules`
- Inspect: `firebase.json`

- [ ] **Step 1:** Validate the rules allow authenticated owners only and reject cross-user access.
- [ ] **Step 2:** Verify Storage writes reject oversized or non-image uploads.
- [ ] **Step 3:** Run `firebase --version` and `firebase projects:list` only if CLI authentication is available.
- [ ] **Step 4:** Run `firebase deploy --only firestore:rules,storage`.
- [ ] **Step 5:** Record deployment output and commit only local rule changes if deployment produced none.

### Task 9: Complete automated validation cycle

**Files:**
- No additional file changes unless failures require them.

- [ ] **Step 1:** Run `flutter test` and report the count/failures.
- [ ] **Step 2:** Run `flutter analyze` and report errors/warnings/info.
- [ ] **Step 3:** Run `flutter build apk --debug` and report exit status/artifact path.
- [ ] **Step 4:** If failures occur, fix them with TDD and repeat the full cycle.
- [ ] **Step 5:** Commit validated fixes in phase-sized commits.

### Task 10: Android manual validation

**Files:**
- Document findings in: `docs/superpowers/plans/2026-11-22-nightowlner-stabilization.md`

- [ ] **Step 1:** Detect a connected Android device or emulator with `flutter devices`.
- [ ] **Step 2:** If available, run the debug app and test authentication, project CRUD and task CRUD.
- [ ] **Step 3:** Test calendar navigation, location permission grant/deny, image upload/cancel/failure and wisdom API/fallback.
- [ ] **Step 4:** Record pass/fail plus environment limits for every case.
- [ ] **Step 5:** Commit any Android-driven fixes and re-run the full automated cycle.

### Task 11: Final diff and repository review

**Files:**
- Inspect all changed files and commits.

- [ ] **Step 1:** Run `git --no-pager status --short --branch`.
- [ ] **Step 2:** Run `git --no-pager diff --stat` and `git --no-pager diff --check`.
- [ ] **Step 3:** Review commit log and diff between the pre-stabilization commit and HEAD.
- [ ] **Step 4:** Confirm no secrets, build artifacts or unrelated files are included.
- [ ] **Step 5:** Produce an evidence-based final summary of passed checks and remaining environment limitations.

## Execution evidence (2026-11-23)

- Baseline analyzer: 5 unused-import warnings in `lib/view/project_form_page.dart`.
- Baseline tests: 37 passing and 1 failing dashboard widget test; the failure was a missing `TaskRepository` provider plus an outdated calendar-icon assertion.
- Baseline debug APK: blocked because `JAVA_HOME` is unset and no `java` executable is in `PATH`.
- Fixed dashboard test provider setup and calendar app-bar assertion.
- Restored project image and GPS controls, capped at five URLs, with `imageQuality: 82`, the existing Storage repository path, and actionable error states.
- Final analyzer: **No issues found**.
- Final test suite: **38 tests passed**.
- Firebase CLI: authenticated; Firestore rules compiled and deployed successfully to `apk-auth-8d602`.
- Storage deployment: blocked because Firebase Storage is not initialized in `apk-auth-8d602`; the deployment reported the Console setup URL.
- Android manual validation: not performed; `flutter devices` found Linux desktop and Chrome only, with no Android device or emulator.
- Working-tree implementation changes are limited to `lib/view/project_form_page.dart` and `test/dashboard_shell_test.dart`; `assets/icon/tsp.pdf` remains an unrelated untracked file.
