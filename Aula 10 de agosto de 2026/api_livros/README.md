# Catálogo de Livros

App Flutter de catálogo de livros, com foco em telas pequenas (mobile). Os
dados vêm da [Open Library API](https://openlibrary.org/dev/docs/api) (busca,
categorias e capas) e o acesso ao app é protegido por login com **Firebase
Authentication** (e-mail/senha).

## Como rodar depois de clonar

### 1. Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sem erros).
- Um dispositivo para rodar o app: emulador Android, celular Android com
  depuração USB ativada, ou o **Chrome** (o app também roda como web).

### 2. Instalar as dependências

Abra um terminal na pasta do projeto (`Aula 10 de agosto de 2026/api_livros`) e rode:

```bash
flutter pub get
```

### 3. Rodar o app

**Não é necessário configurar nada do Firebase manualmente** — os arquivos de
configuração (`lib/firebase_options.dart` e `android/app/google-services.json`)
já estão no repositório, prontos para uso.

```bash
flutter run
```

Se mais de um dispositivo estiver disponível, o Flutter vai perguntar qual
usar. Para forçar um específico:

```bash
flutter run -d chrome      # roda no navegador
flutter run -d <deviceId>  # roda num emulador/celular Android (veja "flutter devices")
```

> O Firebase só foi configurado para **Android** e **Web** (foco do projeto é
> mobile). Rodar com `-d windows`/`-d macos`/`-d linux` não funciona — o login
> quebra porque não há configuração do Firebase para essas plataformas.

Para gerar um instalável Android (útil se quiser testar num celular sem
configurar todo o ambiente Flutter):

```bash
flutter build apk --release
```

O `.apk` fica em `build/app/outputs/flutter-apk/app-release.apk` — é só
transferir para o celular e instalar.

### 4. Login

O app pede login antes de mostrar o catálogo. Duas opções:

- **Usar a conta de teste já criada:**
  - E-mail: `professor.teste@example.com`
  - Senha: `senha123`
- **Ou criar uma conta nova**, direto pela tela de login, no link
  "Não tem conta? Criar conta" (nome, e-mail e senha — não precisa de nenhum
  cadastro externo).

### 5. Rodar os testes (opcional)

```bash
flutter test
flutter analyze
```

## Estrutura do projeto

```
lib/
├── main.dart                    # inicializa o Firebase e monta o app
├── firebase_options.dart        # configuração do Firebase (gerada, não editar à mão)
├── models/book.dart             # modelo de dados do livro
├── services/
│   ├── auth_service.dart        # login/cadastro/logout (Firebase Auth)
│   └── book_service.dart        # busca de livros na Open Library API
├── screens/
│   ├── auth_gate.dart           # decide entre tela de login e catálogo
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── catalog_screen.dart      # busca + grid de livros
│   └── book_detail_screen.dart
├── widgets/book_card.dart
└── theme/app_theme.dart         # paleta e estilo "dark-gothic" do app
```
