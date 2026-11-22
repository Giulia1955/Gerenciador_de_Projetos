# NightOwlner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Completar o NightOwlner em Flutter com autenticação Firebase, projetos e tarefas persistidos, calendário, localização, imagens, API de sabedoria e tema aprovado.

**Architecture:** Use ChangeNotifier com Provider, repositórios por integração externa e modelos Dart centralizados. Entregas serão implementadas por fases independentes, com teste antes da implementação e validação após cada fase.

**Tech Stack:** Flutter, Material 3, Firebase Auth, Cloud Firestore, Firebase Storage, Provider, table_calendar, geolocator, image_picker, http.

## Global Constraints

- Plataforma principal Android.
- Tema quase preto `#070D18`, azul escuro e amarelo queimado `#D6A84B`.
- Persistência principal no Firebase já configurado no projeto.
- Operações CRUD completas para projetos e tarefas.
- `table_calendar` obrigatório em uma aba própria.
- ZenQuotes API obrigatória, com Advice Slip como fallback e frase local.
- Nenhum segredo ou chave privada deve ser versionado.

---

# Fase 1 — Base visual e navegação

**Resultado:** app autenticado abre com tema aprovado, navegação por abas e placeholders funcionais.

### Task 1.1: Dependências e tema

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/theme/app_theme.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1:** Adicionar Provider e os pacotes de recursos principais:
  - `provider`
  - `cloud_firestore`
  - `firebase_storage`
  - `table_calendar`
  - `geolocator`
  - `image_picker`
  - `http`
- [ ] **Step 2:** Atualizar `AppTheme` com superfícies, cor primária, cor secundária e estilos de AppBar, cards, inputs, chips e navegação.
- [ ] **Step 3:** Configurar `MultiProvider` no `main.dart` após Firebase ser inicializado.
- [ ] **Step 4:** Executar `flutter pub get` e `flutter analyze`.
- [ ] **Step 5:** Confirmar que o app continua compilando.

### Task 1.2: Shell principal

**Files:**
- Create: `lib/view/dashboard_shell.dart`
- Create: `lib/view/projects_page.dart`
- Create: `lib/view/calendar_page.dart`
- Create: `lib/view/profile_page.dart`
- Modify: `lib/view/home_page.dart`
- Modify: `lib/view/auth_page.dart`

- [ ] **Step 1:** Substituir o dashboard básico por `DashboardShell` com `NavigationBar`.
- [ ] **Step 2:** Criar as três páginas base: Projetos, Calendário e Perfil.
- [ ] **Step 3:** Implementar cabeçalho NightOwlner com coruja animada e saudação.
- [ ] **Step 4:** Adicionar estados vazios visuais sem dados ainda simulados.
- [ ] **Step 5:** Executar o app no Android disponível e conferir a navegação.

# Fase 2 — Modelos e persistência

**Resultado:** regras de dados e repositórios Firetore testáveis.

### Task 2.1: Modelos

**Files:**
- Create: `lib/models/project.dart`
- Create: `lib/models/project_task.dart`
- Create: `lib/models/project_location.dart`
- Create: `test/models/project_test.dart`
- Create: `test/models/project_task_test.dart`

- [ ] **Step 1:** Escrever testes para serialização e limites mínimos dos modelos.
- [ ] **Step 2:** Executar os testes e confirmar que falham por tipos ainda inexistentes.
- [ ] **Step 3:** Implementar `ProjectLocation`, `ProjectTask` e `Project` com `fromMap`, `toMap` e `copyWith`.
- [ ] **Step 4:** Definir conversão segura de `Timestamp` para `DateTime`.
- [ ] **Step 5:** Executar os testes até ficarem verdes.

### Task 2.2: Validações

**Files:**
- Create: `lib/utils/validators.dart`
- Create: `test/utils/validators_test.dart`

- [ ] **Step 1:** Escrever testes para nome, descrição, responsável e prazos de projeto/tarefa.
- [ ] **Step 2:** Confirmar falha inicial.
- [ ] **Step 3:** Implementar validadores puros com mensagens em português.
- [ ] **Step 4:** Validar coordenadas latitude/longitude.
- [ ] **Step 5:** Confirmar todos os testes passando.

### Task 2.3: Repositório Firestore

**Files:**
- Create: `lib/repositories/project_repository.dart`
- Create: `lib/repositories/task_repository.dart`
- Create: `test/repositories/project_repository_test.dart`

- [ ] **Step 1:** Definir interfaces para streams e operações CRUD.
- [ ] **Step 2:** Escrever testes usando fake_cloud_firestore ou uma implementação fake de mesma interface.
- [ ] **Step 3:** Implementar subcoleção `users/{uid}/projects/{projectId}/tasks/{taskId}`.
- [ ] **Step 4:** Atualizar `updatedAt` em todas as operações relevantes.
- [ ] **Step 5:** Executar testes e `flutter analyze`.

# Fase 3 — CRUD de projetos

**Resultado:** projetos reais podem ser criados, exibidos, editados e excluídos.

### Task 3.1: Provider de projetos

**Files:**
- Create: `lib/providers/project_provider.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1:** Escrever testes de estado para carregar, criar e excluir projetos.
- [ ] **Step 2:** Implementar `ProjectProvider` com estados loading, success, empty e error.
- [ ] **Step 3:** Registrar o provider no `MultiProvider`.
- [ ] **Step 4:** Cancelar subscriptions ao descartar o provider.
- [ ] **Step 5:** Executar testes.

### Task 3.2: Formulário de projeto

**Files:**
- Create: `lib/view/project_form_page.dart`
- Create: `lib/components/project_fields.dart`
- Create: `lib/components/app_date_field.dart`

- [ ] **Step 1:** Implementar formulário com nome, descrição e prazo.
- [ ] **Step 2:** Conectar os validadores aos campos.
- [ ] **Step 3:** Implementar modo criar/editar e bloqueio durante submissão.
- [ ] **Step 4:** Mostrar erros amigáveis do provider/repositório.
- [ ] **Step 5:** Executar teste manual no Android.

### Task 3.3: Cards e detalhes

**Files:**
- Create: `lib/components/project_card.dart`
- Create: `lib/view/project_detail_page.dart`
- Modify: `lib/view/projects_page.dart`

- [ ] **Step 1:** Mostrar projetos em grade de cartões.
- [ ] **Step 2:** Exibir descrição, prazo e hora da última atualização.
- [ ] **Step 3:** Implementar navegação para detalhes e edição.
- [ ] **Step 4:** Confirmar exclusão em diálogo antes de chamar o repositório.
- [ ] **Step 5:** Verificar CRUD completo no Android.

# Fase 4 — Tarefas

**Resultado:** tarefas podem ser gerenciadas dentro de cada projeto.

### Task 4.1: Provider e repositório de tarefas

**Files:**
- Create: `lib/providers/task_provider.dart`
- Modify: `lib/repositories/task_repository.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1:** Escrever testes para criação, conclusão e exclusão.
- [ ] **Step 2:** Implementar streams e estados da lista de tarefas.
- [ ] **Step 3:** Restringir tarefas ao projeto selecionado.
- [ ] **Step 4:** Atualizar `updatedAt` do projeto ao alterar tarefa.
- [ ] **Step 5:** Executar testes.

### Task 4.2: Interface de tarefas

**Files:**
- Create: `lib/view/task_form_page.dart`
- Create: `lib/components/task_tile.dart`
- Modify: `lib/view/project_detail_page.dart`

- [ ] **Step 1:** Criar formulário com nome, descrição, responsável e prazo.
- [ ] **Step 2:** Validar prazo igual ou anterior ao prazo do projeto.
- [ ] **Step 3:** Adicionar ações editar, concluir/reabrir e excluir.
- [ ] **Step 4:** Confirmar que a lista atualiza em tempo real.
- [ ] **Step 5:** Testar CRUD completo no Android.

# Fase 5 — Calendário

**Resultado:** prazos reais aparecem em uma aba própria baseada em `table_calendar`.

### Task 5.1: Provider do calendário

**Files:**
- Create: `lib/providers/calendar_provider.dart`
- Modify: `lib/view/calendar_page.dart`

- [ ] **Step 1:** Escrever teste para agrupar projetos e tarefas por data.
- [ ] **Step 2:** Implementar cálculo de eventos por dia.
- [ ] **Step 3:** Separar eventos de projeto e tarefa por tipo.
- [ ] **Step 4:** Invalidar cache ao detectar alteração no Firestore.
- [ ] **Step 5:** Confirmar testes verdes.

### Task 5.2: Tela de calendário

**Files:**
- Modify: `lib/view/calendar_page.dart`
- Create: `lib/components/calendar_event_tile.dart`

- [ ] **Step 1:** Adicionar `TableCalendar` com marcadores e seleção de dia.
- [ ] **Step 2:** Mostrar lista de projetos/tarefas da data selecionada.
- [ ] **Step 3:** Diferenciar tipos com cor e ícone.
- [ ] **Step 4:** Navegar para detalhes ao tocar em um evento.
- [ ] **Step 5:** Validar navegação e marcadores em dados reais.

# Fase 6 — Imagens, GPS e API

**Resultado:** recursos móveis exigidos ficam integrados ao app.

### Task 6.1: Upload de imagens

**Files:**
- Create: `lib/repositories/storage_repository.dart`
- Create: `lib/providers/media_provider.dart`
- Modify: `lib/view/project_form_page.dart`
- Modify: `lib/view/project_detail_page.dart`

- [ ] **Step 1:** Adicionar `image_picker` e seleção de até cinco imagens.
- [ ] **Step 2:** Comprimir ou redimensionar antes do upload.
- [ ] **Step 3:** Uploadar em `projects/{uid}/{projectId}/images/{fileName}`.
- [ ] **Step 4:** Persistir URLs no projeto e remover arquivos ao excluir projeto.
- [ ] **Step 5:** Testar sucesso, cancelamento e falha no Android.

### Task 6.2: Localização GPS

**Files:**
- Create: `lib/repositories/location_repository.dart`
- Modify: `lib/view/project_form_page.dart`
- Modify: `lib/view/project_detail_page.dart`

- [ ] **Step 1:** Solicitar permissão apenas após toque no botão.
- [ ] **Step 2:** Obter localização atual pelo `geolocator`.
- [ ] **Step 3:** Validar latitude e longitude antes de persistir.
- [ ] **Step 4:** Exibir latitude e longitude ou mensagem de erro.
- [ ] **Step 5:** Testar permissão concedida e negada no Android.

### Task 6.3: Pílula da coruja

**Files:**
- Create: `lib/repositories/wisdom_repository.dart`
- Create: `lib/providers/wisdom_provider.dart`
- Create: `lib/components/owl_wisdom_pill.dart`
- Modify: `lib/view/projects_page.dart`

- [ ] **Step 1:** Escrever testes de fallback do provedor.
- [ ] **Step 2:** Buscar ZenQuotes com timeout curto.
- [ ] **Step 3:** Buscar Advice Slip em caso de falha.
- [ ] **Step 4:** Exibir fallback local e cachear por sessão/dia.
- [ ] **Step 5:** Integrar coruja animada à pílula do dashboard.

# Fase 7 — Segurança e qualidade

**Resultado:** app pronto para demonstração acadêmica com regras, testes e documentação.

### Task 7.1: Regras Firebase

**Files:**
- Modify: `firestore.rules`
- Modify: `storage.rules`

- [ ] **Step 1:** Restringir leitura e escrita de projetos ao proprietário.
- [ ] **Step 2:** Restringir tarefas ao proprietário do projeto pai.
- [ ] **Step 3:** Restringir uploads ao diretório do usuário.
- [ ] **Step 4:** Implantar regras com Firebase CLI.
- [ ] **Step 5:** Testar acesso autenticado e não autenticado.

### Task 7.2: Testes finais e build

**Files:**
- Create ou modificar testes em `test/`
- Modify: `README.md`

- [ ] **Step 1:** Executar `flutter test`.
- [ ] **Step 2:** Executar `flutter analyze` e corrigir erros relevantes.
- [ ] **Step 3:** Gerar APK de depuração com `flutter build apk --debug`.
- [ ] **Step 4:** Executar os principais fluxos manualmente no Android.
- [ ] **Step 5:** Documentar funcionalidades, configurações Firebase e API no README.

## Critério de encerramento

Todas as fases 1–7 estão concluídas, o app compila no Android e os critérios da especificação foram validados. O plano pode ser executado uma fase por vez, com checkpoint entre fases.