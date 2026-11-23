# NightOwlner — Correção dos Defeitos de Estabilização

## Resumo

Esta especificação define a correção dos cinco problemas restantes identificados na estabilização do NightOwlner:

- suíte completa vermelha no dashboard;
- edição de tarefa concluída sem confirmação;
- risco de exclusão de projeto deixar imagens órfãs;
- calendário que não usa cache/provider reativo;
- validação de prazo que aceita o momento atual.

A correção será localizada nas camadas existentes: tests, views, providers, repositories e validators.

## Escopo

Incluído:

1. Corrigir o teste de dashboard.
2. Confirmar a edição de tarefas concluídas.
3. Trocar a ordem de exclusão de projeto para Storage antes de Firestore.
4. Transformar `CalendarProvider` em provider reativo real.
5. Tornar o prazo do projeto estritamente posterior ao momento atual.
6. Remover os warnings de imports da página de formulário.
7. Atualizar ou adicionar testes unitários/widget correspondentes.
8. Configurar um JDK disponível e tentar novamente o build Android debug.

Fora do escopo:

- alteração visual geral;
- novos recursos fora dos problemas descritos;
- migrações de dados;
- publicação em loja;
- implantação adicional de Firebase.

## Comportamento esperado

### Dashboard

- O teste deve registrar `TaskRepository` no mesmo `ProviderScope` usado pela `CalendarPage`.
- O ícone da navegação do calendário deve ser testado com `Icons.calendar_month`.
- `flutter test` deve terminar sem falhas.

### Edição de tarefa concluída

- Tarefas concluídas continuam mostrando o botão de edição.
- Ao acioná-lo, o aplicativo mostra uma confirmação antes de navegar ao formulário.
- Cancelar mantém o usuário na tela de detalhes sem alterações.
- Confirmar abre `TaskFormPage` com a tarefa selecionada.
- Tarefas não concluídas continuam editáveis sem diálogo adicional.

### Exclusão de projeto

- `ProjectProvider.deleteProject` deve limpar a pasta de imagens no Storage primeiro.
- Falha no Storage impede a exclusão no Firestore e propaga a falha ao caller.
- Falha parcial no Storage pode deixar arquivos restantes, mas não deve apagar o projeto enquanto a limpeza completa não tiver sucesso.
- Após a limpeza bem-sucedida, o Firestore exclui as tarefas e o projeto em batch.
- Os testes devem cobrir sucesso e falha do Storage.

### Calendário

- `CalendarProvider` passa a ser um `ChangeNotifier` real gerenciado pelo Provider.
- Recebe `ProjectProvider` e `TaskRepository`, observa usuário e projetos e mantém um cache `tasksByProject`.
- Cancela subscriptions existentes antes de trocar usuário ou quando o provider é descartado.
- Atualiza projetos e tarefas sem subscriptions criadas diretamente pela view.
- `CalendarPage` apenas observa o provider e seleciona eventos por dia.
- Remover ou alterar projetos deve invalidar/atualizar a coleção observada e os eventos derivados.
- `CalendarEvent` mantém os dados necessários para navegação a projeto/tarefa.

### Prazo do projeto

- `validateProjectDueDate` retorna erro para `null` e para qualquer instante menor ou igual a `DateTime.now()`.
- Como a seleção de data pode representar apenas dia, o resultado deve comparar o instante real recebido pelo validador sem introduzir uma regra independente de dia atual.
- Datas futuras continuam válidas.
- Se a data recebida coincide com o instante atual ou é anterior, o validador rejeita.

### Código e qualidade

- Os imports não utilizados de `project_form_page.dart` apontados pelo analyzer serão removidos.
- Nenhum warning novo poderá ser introduzido.
- O build Android será tentado após configurar `JAVA_HOME` para um JDK compatível com o Gradle do projeto.

## Arquitetura

A estrutura continuará sendo:

- `models/`: entidades;
- `repositories/`: Firebase/Storage;
- `providers/`: estado reativo;
- `views/`: composição da UI;
- `utils/validators.dart`: validação;
- `test/`: testes.

O calendário seguirá a mesma separação: a view não conhece streams de tarefas; o provider conhece autenticação, projetos, repository e cache.

## Testes

Cada mudança deve ter cobertura correspondente:

- dashboard: providers necessários e ícone correto;
- tarefa concluída: cancelar e confirmar edição;
- exclusão segura: Storage falha antes do Firestore e Storage sucesso antes do Firestore;
- calendário: criação, atualização e cancelamento de subscriptions, cache e eventos;
- prazo: hoje/antes/agora/futuro conforme o método real de validação;
- imports/analyzer: `flutter analyze` sem warnings novos.

## Verificação final

A implementação será considerada concluída quando:

- `flutter test` terminar com todos os testes aprovados;
- `flutter analyze` terminar sem erros e sem warnings novos;
- o build debug APK for executado; em caso de bloqueio ambiental, o motivo será registrado exatamente;
- `git diff --check` passar;
- não houver arquivos gerados ou mudanças acidentais fora do escopo.
