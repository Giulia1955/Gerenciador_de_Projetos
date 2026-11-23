# NightOwlner

Aplicativo Flutter para organização de projetos acadêmicos, tarefas, prazos e localização.

## Recursos

- Firebase Authentication: cadastro, login, recuperação de senha e logout.
- Projetos e tarefas persistidos no Cloud Firestore por usuário.
- CRUD completo de projetos e tarefas.
- Calendário com `table_calendar` e marcadores reais.
- Upload de até cinco imagens por projeto no Firebase Storage.
- Localização atual com `geolocator`, somente após ação do usuário.
- Frase motivacional com ZenQuotes, fallback Advice Slip e frase local.
- Tema escuro Material 3.

## Firebase

O projeto já utiliza a configuração Android existente em:

- `lib/firebase_options.dart`
- `android/app/google-services.json`

Não são necessárias credenciais adicionais no código. Configure o Firebase Console com Authentication, Cloud Firestore e Firebase Storage. O arquivo `firebase.json` publica:

- `firestore.rules`
- `storage.rules`

As regras limitam leitura e escrita ao usuário proprietário dos dados em `users/{uid}` e `projects/{uid}/{projectId}/images`.

## Executar

```sh
flutter pub get
flutter run
```

## Validar

```sh
flutter test
flutter analyze
flutter build apk --debug
```

## Estrutura principal

- `lib/models`: entidades e serialização.
- `lib/repositories`: Firestore, Storage, localização e APIs externas.
- `lib/providers`: estado reativo com `ChangeNotifier`.
- `lib/view`: telas e formulários.
- `lib/components`: widgets reutilizáveis.
- `test`: testes de modelos, repositórios, providers e formulários.
