# Substituição do Firebase Storage por imagens Blob no Firestore

## Objetivo

Remover a dependência de `firebase_storage` desta aplicação e armazenar imagens pequenas diretamente no documento do projeto no Cloud Firestore, usando dados Blob.

## Decisões validadas

- Imagens existentes no Firebase Storage não serão migradas.
- Projetos existentes perderão a apresentação das URLs antigas após a atualização.
- Cada imagem será limitada a aproximadamente 100 KB.
- As imagens serão comprimidas e convertidas para JPEG.
- Cada projeto continuará limitado a cinco imagens.
- Não será mantido suporte permanente ao campo `imageUrls`.

## Modelo de dados

Cada projeto será armazenado em:

`users/{uid}/projects/{projectId}`

O campo `imageUrls` será substituído por:

```text
images: List<Blob>
```

O campo será serializado pelo modelo `Project` como uma lista de blobs suportada pelo `cloud_firestore`.

O `Blob` será usado como valor binário, não como Base64.

## Arquitetura

### Componentes

- `Project`: armazenará `List<Blob>` em vez de `List<String>`.
- `MediaProvider`: receberá o arquivo selecionado, validará, processará e devolverá um `Blob` ou erro.
- `ProjectFormPage`: manterá os Blobs no estado do formulário e exibirá previews com `Image.memory`.
- `ProjectDetailPage`: exibirá previews dos Blobs com `Image.memory`.
- `ProjectRepository`: continuará salvando o projeto, incluindo o campo `images`, pelo Firestore.
- `ProjectProvider`: deixará de depender de `StorageRepository` para criar ou excluir projetos.
- `main.dart`: deixará de inicializar `FirebaseStorage` e `StorageRepository`.

### Processamento da imagem

Ao selecionar uma imagem:

1. Ler os bytes originais do arquivo.
2. Decodificar e redimensionar a imagem para no máximo 600 × 600 pixels.
3. Comprimir o resultado em JPEG.
4. Diminuir a qualidade até o arquivo ter no máximo 100 KB.
5. Rejeitar a operação se o tamanho continuar acima do limite após a compressão.
6. Criar um `Blob` a partir dos bytes finais.

A biblioteca usada para redimensionar e comprimir será definida no plano de implementação. A implementação não pode depender do Firebase Storage.

### Documento

A aplicação deve calcular e validar o tamanho agregado das imagens antes de salvar o projeto. O limite máximo recomendado é manter uma margem segura do limite de 1 MiB do Firestore.

Se o documento ultrapassar o limite seguro ou o resultado da gravação indicar tamanho excessivo, o salvamento será rejeitado com mensagem clara ao usuário.

## Remoções

Serão removidos:

- Importações de `firebase_storage`.
- Inicialização de `FirebaseStorage.instance`.
- `StorageRepository`.
- Dependência `firebase_storage` no `pubspec.yaml`.
- Dependência de `StorageRepository` em `ProjectProvider` e `MediaProvider`.
- Regras `storage.rules`, quando não forem mais usadas por nenhum componente do projeto.

O arquivo `storage.rules` não será usado enquanto não houver Storage no projeto.

## Compatibilidade

Não haverá leitura de URLs antigas no campo `imageUrls`. Dados antigos de projetos podem permanecer no Firestore temporariamente, mas serão ignorados pelo novo modelo.

Ao editar um projeto antigo, a lista `images` ficará vazia e o usuário poderá adicionar imagens novas.

## Interface e experiência

- O botão continuará permitindo no máximo cinco imagens.
- O preview deve usar a representação em memória dos bytes.
- Ao remover uma imagem do formulário, ela será removida da lista enviada ao Firestore.
- Erros de validação ou compressão serão exibidos por `SnackBar` ou pela interface já usada pelo projeto.

## Testes

Os testes devem cobrir:

- Conversão de bytes JPEG em `Blob`.
- Leitura de `List<Blob>` pelo `Project.fromMap`.
- Serialização de `Project` em `images`.
- Ausência de `imageUrls` no mapa salvo.
- Redimensionamento e limite máximo de 100 KB.
- Limite de cinco imagens.
- Remoção de uma imagem da lista.
- Criação e atualização de projeto com Blobs.
- Mensagem apropriada quando uma imagem não puder ser comprimida.
- Ausência de referências a Firebase Storage nos arquivos principais da aplicação.

## Critérios de conclusão

- Nenhuma tela ou provedor usa Firebase Storage.
- Nenhuma operação recebe ou produz URLs de Storage.
- Imagens novas são salvas como Blob no documento do projeto.
- Previews são exibidos a partir de bytes.
- O projeto continua dentro do limite de cinco imagens e 100 KB por imagem.
- A análise e os testes do projeto passam.
