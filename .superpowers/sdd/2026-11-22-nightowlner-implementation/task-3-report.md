# Implementer report — Task 3.1

## Status

Task 3.1 implementada localmente na worktree do NightOwlner. Nenhuma UI foi criada ou alterada.

## Changed files

- `lib/providers/project_provider.dart`: novo provider de projetos.
- `lib/main.dart`: registro de `ProjectRepository` e `ProjectProvider` no `MultiProvider`.
- `test/providers/project_provider_test.dart`: testes de estados, CRUD e subscriptions.
- `.superpowers/sdd/2026-11-22-nightowlner-implementation/task-3-report.md`: este relatório.

## Implementation

`ProjectProvider` usa `ChangeNotifier` e integra:

- Firebase Auth através da stream de UID autenticado.
- `ProjectRepository.watchProjects(uid)` para atualização em tempo real.
- Estados `loading`, `success`, `empty` e `error`.
- Operações criar, atualizar e excluir usando o UID atual.
- Cancelamento da subscription anterior ao trocar de usuário.
- Cancelamento das subscriptions de autenticação e projetos em `dispose()`.

## TDD evidence

A falha vermelha foi observada executando `flutter test test/providers/project_provider_test.dart`: o arquivo `lib/providers/project_provider.dart` e os símbolos do provider ainda não existiam.

Após implementar o provider, o teste específico passou com 4 testes.

Os testes cobrem:

- loading, empty e success;
- criação e exclusão vinculadas ao UID autenticado;
- tratamento de erro da stream;
- cancelamento das subscriptions no descarte.

## Task 3.1 review fixes

### TDD red evidence

Before the implementation change, `flutter test test/providers/project_provider_test.dart` failed with:

- Subscription callbacks for an old UID were not isolated from the current UID.
- CRUD methods without an authenticated UID returned successfully instead of throwing.

The added update test was also included in the regression suite.

### Fix implementation

- Project subscription data and error callbacks now capture the UID used when the subscription was created and ignore callbacks when that UID differs from `_uid`.
- `createProject`, `updateProject`, and `deleteProject` set the provider error and throw `StateError` when `_uid` is null.
- Operation errors for a captured UID are guarded against stale UID changes.

### Final verification

Executed:

```text
flutter test test/providers/project_provider_test.dart
flutter analyze
```

Results:

- 7 provider tests passed.
- `flutter analyze`: `No issues found!`.

## Verification

Executed:

```text
flutter test test/providers/project_provider_test.dart test/repositories/project_repository_test.dart
flutter analyze
```

Results:

- 6 testes passaram.
- `flutter analyze`: `No issues found!`.

## Commit

Será criado um commit local após esta atualização.

## Concerns

- Não há implementação de UI nesta tarefa.
- Os testes de provider usam streams controladas e `FakeFirebaseFirestore`.
- A integração real depende do Firebase Auth e Firestore já configurados no ambiente Android.
