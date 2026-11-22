# Task 1.2 Report — Shell principal

## Status

Completed in the isolated worktree:

`/home/giulia-mezaroba/Documentos/faculdade-ubuntu/Faculdade-Codigos/firebase/apk_auth/.worktrees/nightowlner-implementation`

Branch: `feature/nightowlner-implementation`

## Implementation

- Replaced the authenticated `HomePage` route usage with `DashboardShell`.
- Updated `AuthPage` to return `DashboardShell` whenever `FirebaseAuth.instance.authStateChanges()` supplies an authenticated user, preserving unauthenticated routing to `LoginPage`.
- Added `DashboardShell` using Material 3 `NavigationBar` with exactly three destinations:
  - Projetos
  - Calendário
  - Perfil
- Added `ProjectsPage` as the initial tab with:
  - A `NightOwlner` header.
  - A widget-built owl icon with a repeating scale animation; no asset was added.
  - An approved daily-wisdom pill placeholder without external API calls.
  - A genuine empty-state project area with no simulated or persisted projects.
  - A prominent `Novo projeto` floating action button placeholder.
- Added `CalendarPage` with a basic empty state and no simulated events.
- Added `ProfilePage` with authenticated-user email content and the existing `FirebaseAuth.instance.signOut()` behavior.
- Preserved Firebase sign-out behavior and preserved the authentication stream route behavior.
- Replaced the previous basic `HomePage` implementation with a compatibility wrapper around `DashboardShell`.

## Theme and Constraints

- The implementation uses the existing Material 3 dark theme and approved palette:
  - Background `#070D18`
  - Card `#151F32`
  - Deep blue `#0D1B33`
  - Accent `#D6A84B`
- No purple theme colors were introduced.
- No Firestore CRUD or external API call was implemented.
- No persisted or simulated project data was added.

## Files Changed

- Added `lib/view/dashboard_shell.dart`
- Added `lib/view/projects_page.dart`
- Added `lib/view/calendar_page.dart`
- Added `lib/view/profile_page.dart`
- Modified `lib/view/home_page.dart`
- Modified `lib/view/auth_page.dart`
- Added `test/dashboard_shell_test.dart`

## Validation

- `flutter analyze`: passed with `No issues found!`.
- `flutter test test/dashboard_shell_test.dart`: passed; 1 test passed.
- Verified the dashboard opens on the Projects tab.
- Verified the `NavigationBar` exposes exactly three destinations.
- Verified switching to Calendar reaches the Calendar empty state.
- Dependency resolution reports newer package versions exist, but no dependency constraints were changed for this task.
- No Android emulator or physical-device runtime launch was available in the validation session.

## Self-review

- Confirmed that only the dashboard shell and three tab pages are part of Task 1.2.
- Confirmed that the Firebase authentication stream remains responsible for switching between login and authenticated content.
- Confirmed that the profile sign-out action remains connected directly to `FirebaseAuth.instance.signOut()`.
- Confirmed that the project view contains no sample projects or persisted-data assumptions.
- Confirmed that the calendar view contains no project/task CRUD or external integration.
- Confirmed that the wisdom pill is text-only placeholder UI and performs no network call.
- Confirmed that the animated owl is built entirely from Flutter widgets.
- Confirmed that the report itself is written inside the isolated worktree.

## Concerns

- The add-project button is intentionally non-functional because project CRUD belongs to later tasks.
- The wisdom pill is intentionally static and does not yet fetch or cache daily wisdom.
- The Calendar tab is intentionally empty; `table_calendar` and real event markers belong to a later task.
- The Profile tab uses the current authenticated Firebase user when available and remains safe in isolated widget-test environments.
- A full Android runtime smoke test was not performed; static analysis and a focused widget test passed.
