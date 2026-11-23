# NightOwlner Stabilization and Release Design

## 1. Resumo

Este trabalho converte a implementação existente do NightOwlner em uma versão compilável e verificável no Android. A alteração fica limitada à correção de erros, revisão das telas principais, validação das integrações reais, implantação das regras Firebase e fechamento da qualidade da release.

## 2. Escopo

Incluído:

- Corrigir o conflito de compilação em `lib/view/calendar_page.dart` relacionado a `day(day)`.
- Remover variáveis e campos não utilizados apontados pelo analyzer.
- Corrigir construções de `if` sem bloco que possam afetar legibilidade ou análise.
- Confirmar que imagens usam `ImagePicker`, `Firebase Storage` e URLs persistidas no projeto.
- Confirmar que localização usa permissão solicitada sob demanda e `geolocator`.
- Revisar detalhes do projeto, formulário/lista de tarefas e calendário.
- Implantar `firestore.rules` e `storage.rules` no projeto Firebase configurado.
- Executar testes, análise estática, build Android debug e validação manual em Android quando houver dispositivo disponível.
- Criar commits por fases e revisar o diff final.

Fora do escopo:

- Novos produtos ou telas além das fases já implementadas.
- Migração de arquitetura ou banco de dados.
- Alteração do tema aprovado ou dos requisitos funcionais existentes.
- Publicação em Play Store.

## 3. Arquitetura e abordagem

O código permanece organizado em modelos, repositórios, providers, views e widgets. Correções serão mínimas e localizadas. A estabilização deve preservar os caminhos existentes:

- Projetos e tarefas: `users/{uid}/projects/{projectId}/tasks/{taskId}`.
- Imagens: `projects/{uid}/{projectId}/images/{fileName}`.
- Regras: autenticação obrigatória e propriedade pelo `request.auth.uid`.
- API de sabedoria: ZenQuotes, depois Advice Slip e depois fallback local.

## 4. Integrações reais

### Imagens

A implementação deve permitir seleção pelo usuário, limitar a cinco imagens, comprimir na seleção, fazer upload no Storage e persistir URLs no Firestore. Falhas devem ser informadas sem afirmar sucesso indevido.

### Localização

A localização deve ser solicitada somente após ação explícita do usuário. Permissão negada ou serviço indisponível deve produzir mensagem acionável e não bloquear o restante do formulário.

### API e fallback

A pílula do dashboard deve usar o cache da sessão, buscar a API primária e o fallback conforme especificado e mostrar conteúdo local quando todas as redes falharem.

## 5. Qualidade e release

A validação mínima é:

- `flutter test` sem falhas.
- `flutter analyze` sem erros e sem warnings novos.
- `flutter build apk --debug` concluído com exit code 0.
- Firebase CLI autenticado e implantação bem-sucedida das duas regras.
- Checklist manual registrado para CRUD, tarefas, calendário, permissões, upload, API e fallback.
- Commits separados por fases e diff final sem alterações acidentais.

## 6. Critérios de aceite

A worktree é aceita somente quando o código compila, os recursos já implementados foram revisados contra o comportamento real e os comandos de verificação foram executados neste estado. Limitações de hardware ou credenciais devem ser reportadas com precisão, sem presumir que o teste foi realizado.
