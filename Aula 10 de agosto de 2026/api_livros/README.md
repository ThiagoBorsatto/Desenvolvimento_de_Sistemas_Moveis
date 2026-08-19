# Catálogo de Livros

App Flutter de catálogo de livros, com foco em telas pequenas (mobile). Os
dados vêm da [Gutendex API](https://gutendex.com) (catálogo do Project
Gutenberg: busca, assuntos e capas) e o acesso ao app é protegido por login com
**Firebase Authentication** (e-mail/senha).

## Funcionalidades

- **Acervo completo na abertura.** A tela inicial mostra os livros todos
  juntos, ordenados por popularidade, sem nenhum filtro aplicado. As categorias
  só entram em cena quando o usuário toca em um chip.
- **Filtro por categoria.** Chips horizontais (Ficção, Fantasia, Romance,
  História, Mistério, Infantil, Poesia, Aventura) com um chip "Todos" para
  voltar ao acervo inteiro.
- **Busca na barra superior.** O ícone de lupa transforma a barra em campo de
  busca. Procura por título, nome do autor e também por assuntos/estantes do
  livro; combina com a categoria selecionada, se houver.
- **Tema claro e escuro.** Botão de alternância à direita da barra superior
  (e no canto da tela de login). A escolha é salva no dispositivo e vale para
  as próximas aberturas; sem escolha, o app segue o tema do sistema.

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

### 3. Configurar o Firebase

As chaves do Firebase **não ficam no repositório** (foram removidas por
segurança). Antes de rodar, crie os dois arquivos de configuração locais:

**a) O arquivo `.env`** — copie o modelo e preencha com as chaves do projeto:

```bash
cp .env.example .env    # no Windows/PowerShell: Copy-Item .env.example .env
```

Os valores estao no [Console do Firebase](https://console.firebase.google.com/)
em **Configurações do projeto > Seus apps**, ou peça o `.env` pronto para o
dono do repositório. O arquivo fica assim:

```
FIREBASE_WEB_API_KEY=AIza...
FIREBASE_WEB_APP_ID=1:000000000000:web:...
FIREBASE_MESSAGING_SENDER_ID=000000000000
FIREBASE_PROJECT_ID=seu-projeto
FIREBASE_AUTH_DOMAIN=seu-projeto.firebaseapp.com
FIREBASE_STORAGE_BUCKET=seu-projeto.firebasestorage.app
FIREBASE_MEASUREMENT_ID=G-...
FIREBASE_ANDROID_API_KEY=AIza...
FIREBASE_ANDROID_APP_ID=1:000000000000:android:...
```

**b) O arquivo `android/app/google-services.json`** (só precisa se for rodar no
Android) — copie o modelo e substitua os `YOUR_...` pelos valores reais, ou
baixe o arquivo direto do Console do Firebase:

```bash
cp android/app/google-services.json.example android/app/google-services.json
```

Os dois arquivos estão no `.gitignore` — nunca commite nenhum deles.

> **Sobre as chaves do Firebase:** elas são restritas por origem no Google
> Cloud Console. A chave **web** só funciona a partir de `localhost`,
> `127.0.0.1` e dos domínios do Firebase Hosting do projeto. A chave
> **Android** só funciona para o pacote `com.example.api_livros` assinado com
> o SHA-1 cadastrado.
>
> Isso significa que **buildar o app Android em outra máquina exige cadastrar
> o SHA-1 do keystore de debug dela**. Para descobrir o seu:
>
> ```bash
> keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
> ```
>
> E adicione em **Google Cloud Console > APIs e Serviços > Credenciais >
> Android key > Restrições de aplicativo**. Sem isso o login falha com HTTP 403.
>
> As chaves são públicas por natureza (vão no bundle do app); a restrição é
> o que impede que sejam usadas fora dele.

### 4. Rodar o app

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

### 5. Login

O app pede login antes de mostrar o catálogo. Duas opções:

- **Usar a conta de teste já criada:**
  - E-mail: `professor.teste@example.com`
  - Senha: `senha123`
- **Ou criar uma conta nova**, direto pela tela de login, no link
  "Não tem conta? Criar conta" (nome, e-mail e senha — não precisa de nenhum
  cadastro externo).

### 6. Rodar os testes (opcional)

```bash
flutter test
flutter analyze
```

## Arquitetura

O projeto segue **MVVM**, a arquitetura recomendada pela documentação oficial
do Flutter ([Guide to app architecture](https://docs.flutter.dev/app-architecture)),
organizada por funcionalidade (*feature-first*).

São três camadas, e a dependência só aponta para baixo — a UI conhece o
repositório, o repositório conhece o service, e nunca o contrário:

| Camada | Papel | Não pode |
| --- | --- | --- |
| **UI** (`ui/`) | *View* desenha; *ViewModel* guarda o estado da tela e as regras de interação. | Falar HTTP, conhecer `FirebaseAuthException`. |
| **Data** (`data/`) | *Repository* decide o que buscar, faz cache e traduz erros em mensagens. *Service* fala com uma fonte externa. | Conhecer widgets. |
| **Domain** (`domain/`) | Modelos puros compartilhados pelas outras camadas. | Depender de qualquer outra camada. |

Decisões que valem destacar:

- **Repositórios são interfaces.** `BookRepository`, `AuthRepository` e
  `ThemeRepository` são abstratos; as implementações concretas
  (`BookRepositoryRemote`, `AuthRepositoryFirebase`, `ThemeRepositoryLocal`)
  são escolhidas uma única vez, no `main.dart`. É o que permite testar as
  telas e as ViewModels com dublês, sem rede e sem Firebase.
- **Injeção manual por construtor.** Não há container de DI nem `provider`: as
  dependências são criadas no `main.dart` (*composition root*) e descem pela
  árvore de widgets. Menos mágica, e o caminho fica explícito.
- **`Result<T>` na fronteira.** Repositórios devolvem `Ok` ou `Failure` em vez
  de lançar exceção. O `switch` sobre a *sealed class* obriga a tratar os dois
  casos, e a mensagem de erro já chega pronta em português — a tela não precisa
  adivinhar o que deu errado.
- **Estado com `ChangeNotifier` + `ListenableBuilder`,** ambos do próprio
  Flutter, sem pacote de gerência de estado.

```
lib/
├── main.dart                       # composition root: cria e injeta as dependências
├── firebase_options.dart           # configuração do Firebase (gerada, não editar à mão)
├── domain/models/
│   ├── book.dart                   # modelo de livro
│   └── book_category.dart          # categorias oferecidas como filtro
├── data/
│   ├── services/
│   │   ├── book_api_service.dart   # cliente HTTP da Gutendex
│   │   ├── auth_service.dart       # camada fina sobre o Firebase Auth
│   │   └── theme_preference_service.dart
│   └── repositories/
│       ├── book_repository.dart    # busca + filtro + cache em memória
│       ├── auth_repository.dart    # login/cadastro/logout, erros traduzidos
│       └── theme_repository.dart
├── ui/
│   ├── core/
│   │   ├── themes/app_theme.dart   # paletas clara e escura
│   │   ├── view_model/theme_view_model.dart
│   │   └── widgets/                # book_card.dart, theme_toggle_button.dart
│   ├── auth/{view,view_model}/     # auth_gate, login, cadastro
│   ├── catalog/{view,view_model}/  # barra de busca, filtros e grid
│   └── book_detail/view/
└── utils/result.dart               # Ok / Failure
```

Os testes espelham essa estrutura em `test/ui/...`.
