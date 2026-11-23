# NightOwlner Defect Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Corrigir os defeitos restantes de dashboard, edição, exclusão, calendário e validação de prazo.

**Architecture:** Mantemos a separação entre repositories, providers, views e validators. O calendário passa a ser um ChangeNotifier com cache de tarefas e subscriptions; exclusão limpa Storage antes de Firestore; a view confirma edição concluída e os testes cobrem cada regressão.

**Tech Stack:** Flutter, Provider, Firebase Firestore/Storage, fake_cloud_firestore, table_calendar, flutter_test.

## Global Constraints

- `flutter test` deve terminar com todos os testes aprovados.
- `flutter analyze` deve terminar sem erros e sem warnings novos.
- Prazo do projeto deve ser estritamente posterior ao momento atual.
- Exclusão de projeto deve limpar Storage antes de excluir dados no Firestore.
- Task concluída requer confirmação antes de abrir o formulário de edição.
- A implementação permanece em `feature/nightowlner-implementation` e usa commits por fase.

---

### Task 1: Corrigir a fixture e o ícone do dashboard

**Files:**
- Modify: `test/dashboard_shell_test.dart:1-52`
- Test: `test/dashboard_shell_test.dart`

**Interfaces:**
- Consumes: `TaskRepository`, `TaskProvider`, `ProjectProvider`, `WisdomProvider`
- Produces: widget dashboard navegável sem dependências ausentes

- [ ] **Step 1: Adicionar `Provider<TaskRepository>.value` ao `MultiProvider`.**

```dart
Provider<TaskRepository>.value(value: taskRepository),
```

- [ ] **Step 2: Trocar a expectativa do ícone por `Icons.calendar_month`.**

```dart
expect(find.byIcon(Icons.calendar_month), findsOneWidget);
```

- [ ] **Step 3: Executar somente o teste do dashboard.**

Run: `flutter test test/dashboard_shell_test.dart`
Expected: PASS

- [ ] **Step 4: Commitar a correção.**

```bash
git add test/dashboard_shell_test.dart
git commit -m "fix: repair dashboard widget test"
```

### Task 2: Confirmar edição de tarefa concluída

**Files:**
- Modify: `lib/view/project_detail_page.dart:20-145`
- Create: `test/view/project_detail_page_test.dart`
- Test: `test/view/project_detail_page_test.dart`

**Interfaces:**
- Consumes: `TaskProvider`, `ProjectProvider`, `TaskTile`, `TaskFormPage`
- Produces: callback de edição confirmado para tarefas concluídas

- [ ] **Step 1: Escrever testes de widget para cancelar e confirmar a edição de uma tarefa concluída.**

Os testes devem construir `ProjectDetailPage(project: ...)` dentro de providers com `ProjectProvider` e `TaskProvider`, trocar o tile para concluído e verificar:

```dart
expect(find.text('Editar tarefa concluída'), findsOneWidget);
```

Ao cancelar:

```dart
expect(find.byType(TaskFormPage), findsNothing);
```

Ao confirmar:

```dart
expect(find.byType(TaskFormPage), findsOneWidget);
```

- [ ] **Step 2: Executar o teste e verificar falha vermelha.**

Run: `flutter test test/view/project_detail_page_test.dart`
Expected: FAIL porque nenhuma confirmação é exibida atualmente.

- [ ] **Step 3: Extrair `_editTask(ProjectTask task, Project project)` com um diálogo que só navega após confirmação.**

Para tarefas não concluídas, chamar navegação diretamente. Para concluídas:

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Editar tarefa concluída'),
    content: Text('Editar “${task.name}”?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Editar'),
      ),
    ],
  ),
);
```

Somente com `confirmed == true && mounted` executar `Navigator.push` para `TaskFormPage`.

- [ ] **Step 4: Usar `_editTask(task, project)` no `onEdit` do `TaskTile`.**

- [ ] **Step 5: Executar o teste e o teste do dashboard.**

Run: `flutter test test/view/project_detail_page_test.dart test/dashboard_shell_test.dart`
Expected: PASS

- [ ] **Step 6: Commitar.**

```bash
git add lib/view/project_detail_page.dart test/view/project_detail_page_test.dart
git commit -m "fix: confirm editing completed tasks"
```

### Task 3: Tornar exclusão de projeto segura entre Storage e Firestore

**Files:**
- Modify: `lib/providers/project_provider.dart:88-108`
- Modify: `test/providers/project_provider_test.dart`
- Modify: `test/repositories/project_repository_test.dart`
- Test: `test/providers/project_provider_test.dart`

**Interfaces:**
- Consumes: `StorageRepository.deleteProjectFolder(uid, projectId)` e `ProjectRepository.deleteProject(uid, projectId)`
- Produces: preservação do projeto no Firestore quando Storage falhar

- [ ] **Step 1: Criar uma implementação fake mínima de `StorageRepository` adequada ao teste.**

Como `StorageRepository` depende de `FirebaseStorage`, criar uma classe fake ou criar testes com subclassing quando possível. A classe pode sobrescrever:

```dart
Future<void> deleteProjectFolder(String uid, String projectId)
```

O test deve registrar chamadas e permitir que o método lance `StateError('Storage unavailable')`.

- [ ] **Step 2: Escrever testes no provider que falham na ordem atual.**

Teste de falha:

```dart
await expectLater(
  provider.deleteProject('project-1'),
  throwsA(isA<StateError>()),
);
expect(repositoryContainsProject, isTrue);
expect(storageDeleteCalled, isTrue);
```

Teste de sucesso deve verificar que o projeto deixa de existir após Storage e Firestore serem executados.

- [ ] **Step 3: Executar os testes e confirmar vermelho.**

Run: `flutter test test/providers/project_provider_test.dart`
Expected: A falha de Storage ou a ordem não produzida pelas expectativas falha antes da implementação.

- [ ] **Step 4: Trocar a ordem em `ProjectProvider.deleteProject`.**

```dart
await _storageRepository?.deleteProjectFolder(uid, projectId);
await _repository.deleteProject(uid, projectId);
```

- [ ] **Step 5: Executar os testes do provider e repository.**

Run: `flutter test test/providers/project_provider_test.dart test/repositories/project_repository_test.dart`
Expected: PASS

- [ ] **Step 6: Commitar.**

```bash
git add lib/providers/project_provider.dart test/providers/project_provider_test.dart test/repositories/project_repository_test.dart
git commit -m "fix: delete project storage before firestore"
```

### Task 4: Implementar calendário reativo no provider

**Files:**
- Modify: `lib/providers/calendar_provider.dart:1-55`
- Modify: `lib/view/calendar_page.dart:1-110`
- Modify: `lib/main.dart:20-55`
- Modify: `test/dashboard_shell_test.dart`
- Modify: `test/providers/calendar_provider_test.dart`

**Interfaces:**
- `CalendarProvider(ProjectProvider projectProvider, TaskRepository taskRepository)`
- Exposes: `List<Project> get projects`, `Map<String, List<ProjectTask>> get tasksByProject`, `Map<DateTime, List<CalendarEvent>> get events`
- Lifecycle: `initialize()`, `_syncProjects()`, `_replaceTaskSubscriptions()`, `dispose()`

- [ ] **Step 1: Escrever testes para cache e subscriptions reativas.**

Usar `StreamController<List<Project>>` e `StreamController<List<ProjectTask>>`, observando:

- ao receber projeto, provider cria watch da tarefa;
- ao receber tarefas, `events` é atualizado e `notifyListeners()` ocorre;
- remover projeto cancela ou deixa de incluir seu evento;
- `dispose()` cancela todas as subscriptions.

- [ ] **Step 2: Executar o teste e confirmar que o provider atual não satisfaz a API.**

Run: `flutter test test/providers/calendar_provider_test.dart`
Expected: FAIL por constructor e cache não existentes.

- [ ] **Step 3: Implementar subscriptions no `CalendarProvider`.**

O provider deve:

1. ouvir `ProjectProvider` via `addListener(_syncProjects)`;
2. pegar `_projectProvider.uid` e os projetos atuais;
3. cancelar subscriptions ausentes quando os projetos mudarem;
4. criar uma subscription por projeto;
5. atualizar `_tasksByProject[projectId]`, remover entradas antigas e chamar `notifyListeners()`;
6. cancelar todas as subscriptions no `dispose()` e remover o listener do `ProjectProvider`.

Preservar `groupEvents` e `CalendarEvent` existentes.

- [ ] **Step 4: Simplificar `CalendarPage` para observar `context.watch<CalendarProvider>().events`.**

Remover `dart:async`, `_subscriptions`, `_tasksByProject`, `_watchTasks` e `didChangeDependencies`.

- [ ] **Step 5: Registrar `CalendarProvider` em `main.dart` como `ChangeNotifierProxyProvider2<ProjectProvider, TaskRepository, CalendarProvider>`.**

Se `ProjectProvider` ainda não estiver pronto, o provider deve aguardar `uid == null` e não criar subscriptions.

- [ ] **Step 6: Registrar `CalendarProvider` no `dashboard_shell_test.dart` com os providers necessários.**

- [ ] **Step 7: Executar os testes de calendário e dashboard.**

Run: `flutter test test/providers/calendar_provider_test.dart test/dashboard_shell_test.dart`
Expected: PASS

- [ ] **Step 8: Commitar.**

```bash
git add lib/providers/calendar_provider.dart lib/view/calendar_page.dart lib/main.dart test/dashboard_shell_test.dart test/providers/calendar_provider_test.dart
git commit -m "feat: make calendar provider reactive"
```

### Task 5: Corrigir validação de prazo do projeto

**Files:**
- Modify: `lib/utils/validators.dart:26-36`
- Modify: `test/utils/validators_test.dart:44-58`
- Test: `test/utils/validators_test.dart`

- [ ] **Step 1: Atualizar o teste para rejeitar o instante atual.**

```dart
test('cannot be at or before now', () {
  final now = DateTime.now();
  expect(
    Validators.validateProjectDueDate(now),
    'A data limite do projeto deve ser posterior ao momento atual',
  );
  expect(
    Validators.validateProjectDueDate(now.add(const Duration(microseconds: 1))),
    isNull,
  );
});
```

- [ ] **Step 2: Executar o teste e confirmar falha vermelha.**

Run: `flutter test test/utils/validators_test.dart`
Expected: FAIL porque o instante atual é atualmente aceito.

- [ ] **Step 3: Implementar comparação estrita.**

```dart
if (!dueDate.isAfter(DateTime.now())) {
  return 'A data limite do projeto deve ser posterior ao momento atual';
}
```

- [ ] **Step 4: Executar o teste.**

Run: `flutter test test/utils/validators_test.dart`
Expected: PASS

- [ ] **Step 5: Commitar.**

```bash
git add lib/utils/validators.dart test/utils/validators_test.dart
git commit -m "fix: require future project deadlines"
```

### Task 6: Limpeza de imports e verificação completa

**Files:**
- Modify: `lib/view/project_form_page.dart`
- Test: suíte completa

- [ ] **Step 1: Executar `flutter analyze` antes da edição para registrar warnings restantes.**

Run: `flutter analyze`
Expected: 5 warnings de imports não usados em `project_form_page.dart`, conforme relatório atual.

- [ ] **Step 2: Remover somente imports explicitamente apontados como não usados.**

- [ ] **Step 3: Executar verificação completa.**

Run: `flutter test && flutter analyze && git diff --check`
Expected: testes aprovados, analyze sem warnings novos, diff válido.

- [ ] **Step 4: Configurar JDK e tentar o build.**

Executar:

```bash
java -version
ls -1 /usr/lib/jvm 2>/dev/null
```

Selecionar JDK compatível no diretório disponível e exportar `JAVA_HOME` somente para o comando:

```bash
export JAVA_HOME=<caminho-do-jdk>
export PATH="$JAVA_HOME/bin:$PATH"
flutter build apk --debug
```

- [ ] **Step 5: Registrar o resultado do build sem presumir sucesso ambiental.**

- [ ] **Step 6: Revisar diff e commitar a limpeza.**

```bash
git add lib/view/project_form_page.dart
git diff --cached --check
git commit -m "chore: remove unused project form imports"
```

- [ ] **Step 7: Revisar status e resumo final da worktree.**

```bash
git --no-pager status --short --branch
git --no-pager diff origin/main...HEAD --stat
```
