# syntax=docker/dockerfile:1

# ============================================================================
# Estagio 1 — build: compila o app Flutter para web
# ----------------------------------------------------------------------------
# Versao do SDK fixada de proposito:
#  - pubspec.lock exige Flutter >= 3.22 / Dart >= 3.4
#  - o web/index.html usa o loader antigo (_flutter.loader.loadEntrypoint),
#    removido em versoes mais novas do Flutter. 3.24.5 ainda o suporta.
# Ao subir a versao do Flutter no futuro, atualize tambem o web/index.html
# para o novo bootstrap, senao a pagina abre em branco.
# ============================================================================
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS build

WORKDIR /app

# 1) Resolve dependencias primeiro (camada cacheada enquanto o pubspec nao muda)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 2) Copia o restante do codigo e compila
COPY . .
RUN flutter build web --release

# ============================================================================
# Estagio 2 — runtime: serve os arquivos estaticos com nginx
# Imagem final minima: apenas nginx + o build (sem SDK, sem Dart, sem Flutter).
# ============================================================================
FROM nginx:1.27-alpine AS runtime

# Remove a config default e usa a nossa (SPA + gzip + mime de .wasm)
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/app.conf

# Copia apenas o resultado do build web
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

# Healthcheck simples: a pagina principal responde
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
