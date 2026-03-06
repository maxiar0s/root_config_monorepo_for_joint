# Docker Compose (Dev)

Este flujo es solo para desarrollo local y no afecta el despliegue de QA/PROD en GCP.

## Requisitos

- Docker Desktop
- Docker Compose v2 (`docker compose`)

## Levantar servicios

1. Copia variables de entorno para dev:

   ```bash
   cp .env.dev.example .env.dev
   ```

   En PowerShell:

   ```powershell
   Copy-Item .env.dev.example .env.dev
   ```

2. Construye y levanta frontend + backend + mysql:

   ```bash
   docker compose --env-file .env.dev -f docker-compose.dev.yml up -d --build
   ```

3. Ver logs:

   ```bash
   docker compose -f docker-compose.dev.yml logs -f
   ```

## URLs locales

- Frontend: http://localhost:4200
- Backend: http://localhost:3000
- API (prefijo): http://localhost:3000/api
- MySQL local: localhost:3308

## Levantar

```bash
docker compose --env-file .env.dev -f docker-compose.dev.yml up -d --build
```

## Logs

```bash
docker compose -f docker-compose.dev.yml logs -f
```

## Bajar

```bash
docker compose -f docker-compose.dev.yml down
```

## Apagar servicios

```bash
docker compose -f docker-compose.dev.yml down
```

## Apagar y borrar volúmenes (borra datos de DB)

```bash
docker compose -f docker-compose.dev.yml down -v
```
