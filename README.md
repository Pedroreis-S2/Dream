# dream

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Rodando com Docker

O app é compilado para **web** e servido por nginx dentro de um container.
Não é preciso ter Flutter nem Dart instalados na máquina — só Docker.

### Subir

```bash
docker compose up --build
```

Depois abra **http://localhost:8080**.

Para rodar em segundo plano: `docker compose up --build -d`.
Para parar: `docker compose down`.

### Desenvolvimento (Codespaces / dev container)

O serviço `dev` é um container interativo com o SDK do Flutter, mantido vivo
com `sleep infinity`, para abrir o terminal quantas vezes for preciso.

- **Codespaces / VS Code:** abrir o repositório já sobe o `dev` pela pasta
  `.devcontainer/` e roda `flutter pub get`.
- **Local:**

```bash
docker compose up -d dev        # sobe o container (fica vivo)
docker compose exec dev bash    # abre um terminal (repita quantas vezes quiser)
```

Dentro do container, para servir com hot reload:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
```

Acesse a porta **5000** (no Codespaces ela é encaminhada automaticamente).

### Como funciona

- **Build multi-stage** (`Dockerfile`):
  - Estágio 1: imagem `ghcr.io/cirruslabs/flutter:3.24.5` roda `flutter build web`.
  - Estágio 2: `nginx:1.27-alpine` serve apenas os arquivos estáticos do build.
- A imagem final tem o mínimo para rodar: nginx + o build web, sem SDK.
- `nginx.conf` trata o roteamento de SPA, gzip e o MIME de `.wasm`.

### Observações

- **Versão do Flutter fixada em 3.24.5** de propósito: o `web/index.html`
  deste projeto usa o loader antigo (`loadEntrypoint`). Ao atualizar o Flutter,
  atualize também o `index.html` para o novo bootstrap, ou a página abre em branco.
- **Firebase e internet:** enquanto o Firebase estiver no projeto, a
  inicialização no web carrega o SDK em tempo de execução e precisa de internet
  ao abrir. Depois que o Firebase for removido, o container roda 100% offline.
- Porta configurável em `docker-compose.yml` (`8080:80`).
