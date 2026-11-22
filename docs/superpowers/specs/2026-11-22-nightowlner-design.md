# NightOwlner Design Specification

## 1. Resumo

NightOwlner é um aplicativo móvel Android de gerenciamento de projetos e tarefas acadêmicos. A primeira versão completa permite autenticar usuários, criar e gerenciar projetos, organizar tarefas, consultar prazos em calendário, registrar imagens e coordenadas GPS e receber uma frase curta diária.

## 2. Plataforma e interface

- Plataforma principal: Android.
- Tema escuro, com fundo quase preto `#070D18`, azul escuro para superfícies e amarelo queimado `#D6A84B` para ações e destaques.
- Navegação inferior: Projetos, Calendário e Perfil.
- Dashboard com saudação, pílula diária da coruja, projetos em quadros e botão flutuante ou destacado de adicionar projeto.
- No cabeçalho aparece uma coruja animada ao lado do nome NightOwlner.
- A interface deve usar Material 3 e estados claros para carregamento, vazio, sucesso e erro.

## 3. Arquitetura

- Gerenciamento de estado com `ChangeNotifier` e `Provider`.
- Separação em modelos, repositórios, providers e páginas/widgets.
- Firebase Authentication para contas existentes e cadastro.
- Cloud Firestore para projetos e tarefas.
- Firebase Storage para imagens associadas aos projetos.
- API HTTP para ZenQuotes, com Advice Slip API como fallback.

### Estrutura funcional principal

- `lib/models/`: `Project`, `Task`, `ProjectLocation` e constantes de serialização.
- `lib/repositories/`: acesso a Authentication, Firestore, Storage e API externa.
- `lib/providers/`: estado de autenticação, projetos, calendário e frase diária.
- `lib/view/`: páginas principais, formulários e detalhes.
- `lib/components/`: widgets compartilhados.

## 4. Modelo de dados

### Projeto

Campos obrigatórios:
- `id: String`
- `ownerId: String`
- `name: String`
- `description: String`
- `dueDate: DateTime`
- `imageUrls: List<String>`
- `location: ProjectLocation?`
- `updatedAt: DateTime`
- `createdAt: DateTime`
- `tasks: List<Task>`

`ProjectLocation` contém `latitude: double`, `longitude: double` e `label: String?`.

### Tarefa

Campos obrigatórios:
- `id: String`
- `name: String`
- `description: String`
- `assigneeName: String`
- `dueDate: DateTime`
- `completed: bool`
- `updatedAt: DateTime`
- `createdAt: DateTime`

A persistência deve criar uma subcoleção `users/{uid}/projects/{projectId}/tasks/{taskId}`. Metadados e tarefas podem ser atualizados independentemente.

## 5. Validações

### Projeto

- Nome obrigatório, de 3 a 80 caracteres.
- Descrição obrigatória, de 10 a 500 caracteres.
- Prazo obrigatório e posterior ao momento atual no cadastro.
- Imagens são opcionais.
- Quantidade máxima sugerida: cinco imagens por projeto.
- Coordenadas só são aceitas com latitude entre -90 e 90 e longitude entre -180 e 180.
- Ao editar, `updatedAt` deve ser atualizado.

### Tarefa

- Nome obrigatório, de 3 a 80 caracteres.
- Mini descrição obrigatória, de 5 a 240 caracteres.
- Responsável obrigatório, de 2 a 80 caracteres.
- Prazo obrigatório e igual ou anterior ao prazo do projeto.
- Tarefas concluídas não podem ter suas informações principais alteradas sem confirmação explícita.

## 6. Operações

### Projetos

- Criar, listar, visualizar, editar e excluir.
- A exclusão exige confirmação e remove também as tarefas e imagens do projeto.
- Atualizar imediatamente a hora da última atualização após qualquer alteração relevante.
- Ordenar por prazo ou última atualização no dashboard.

### Tarefas

- Criar, listar, visualizar, editar, concluir/reabrir e excluir.
- A conclusão deve refletir visualmente o estado e atualizar `updatedAt`.

## 7. Imagens e localização

- Seleção de imagens pelo `image_picker`.
- Compressão básica antes do upload.
- Upload para `projects/{uid}/{projectId}/images/{fileName}`.
- URLs persistidas no projeto.
- Permissão de localização solicitada apenas ao usuário tocar no botão GPS.
- Coordenadas obtidas pelo `geolocator` e exibidas em texto.
- Em caso de serviço ou permissão indisponível, mostrar mensagem acionável e permitir cancelamento.

## 8. Calendário

- Obrigatoriamente utilizar o pacote `table_calendar`.
- Exibir projetos e tarefas em marcadores das datas correspondentes.
- Ao selecionar uma data, listar os itens daquele dia.
- Ao tocar em um projeto ou tarefa, abrir a tela de detalhes correspondente.
- A legenda distingue visualmente projeto e tarefa.

## 9. Frase motivacional

- Buscar ZenQuotes API em `GET https://zenquotes.io/api/random`.
- Se houver falha, indisponibilidade ou resposta inválida, usar Advice Slip API em `GET https://api.adviceslip.com/advice`.
- Exibir uma única frase curta na pílula do dashboard.
- Cachear em memória pela sessão e buscar novamente ao abrir o dashboard em outro dia.
- Mostrar fallback local quando ambas as APIs falharem.
- Não bloquear o dashboard durante a requisição.

## 10. Estados e tratamento de erros

- Loading: indicadores de progresso sem apagar dados já carregados.
- Empty: mensagens e botão para criar o primeiro projeto ou tarefa.
- Offline: apresentar erro apropriado e não permitir afirmar que dados foram persistidos sem confirmação do Firebase.
- Validação: mensagens próximas aos campos e destaque visual nos campos inválidos.
- Exceções: converter erros técnicos em mensagens amigáveis.

## 11. Segurança

- Todas as consultas são restritas ao usuário autenticado.
- Regras do Firestore devem exigir `request.auth.uid == userId` no caminho do usuário.
- Regras do Storage devem exigir autenticação e propriedade da pasta.
- Nenhuma chave privada ou credencial deve ser adicionada ao código-fonte.

## 12. Critérios de conclusão

- Usuário consegue cadastrar, entrar, sair e recuperar senha.
- Usuário cria, edita, visualiza e exclui projetos.
- Usuário cria, edita, conclui e exclui tarefas.
- Projeto mostra imagens, coordenadas e hora da última atualização.
- Calendário contém marcadores reais de projetos e tarefas.
- Pílula do dashboard retorna frase da API ou fallback.
- Tema aprovado está aplicado em todas as páginas principais.
- Projeto compila no Android e possui testes básicos de validação e repositórios.
