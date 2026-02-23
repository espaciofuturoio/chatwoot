# Actualizar Chatwoot desde upstream (v4.11.1 y futuras versiones)

Este documento registra **qué se hizo** en la actualización a v4.11.1 y **cómo repetir el proceso** para futuras versiones. Está pensado para que tanto humanos como IA (Cursor, Claude, etc.) puedan seguir los pasos.

> **Importante — Cómo corre Chatwoot en este servidor:**  
> **Siempre usamos Docker Compose**, no `make run` ni Ruby en el host. Archivo: `docker-compose.custom-css.yaml`. Imagen: `chatwoot/chatwoot:custom-css`. Cualquier paso de migraciones, reinicio o build debe hacerse con `docker compose -f docker-compose.custom-css.yaml ...`.

---

## Lo que hicimos (feb 2025 — actualización a v4.11.1)

- **Repo**: `/opt/chatwoot` (submódulo → `espaciofuturoio/chatwoot`). Remoto upstream: `https://github.com/chatwoot/chatwoot.git`.
- **Rama de trabajo**: `production` (fork); actualización en rama `update-to-4.11.1`.

### Pasos ejecutados

1. **Rama de respaldo**  
   Se creó `backup/production-pre-4.11.1` desde `production` (estado antes del merge). Así se puede volver atrás con `git checkout production && git reset --hard backup/production-pre-4.11.1` si hace falta.

2. **Rama de actualización**  
   Se creó `update-to-4.11.1` desde `production`.

3. **Merge de upstream**  
   `git fetch upstream --tags` y `git merge v4.11.1 -m "Merge upstream v4.11.1 into production"`. El merge se hizo sin conflictos (estrategia `ort`). Los commits propios del fork (rate limit, custom CSS widget, docker compose .env, etc.) se mantuvieron en la historia.

4. **Versión**  
   `config/app.yml` pasó a `version: '4.11.1'` (incluido en el merge de upstream).

5. **Push al fork**  
   Se subieron las ramas `backup/production-pre-4.11.1` y `update-to-4.11.1` a `origin` (espaciofuturoio/chatwoot).

### Estado después de la actualización

- `backup/production-pre-4.11.1`: respaldo del `production` anterior.
- `update-to-4.11.1`: contiene production + merge de v4.11.1; lista para pruebas y luego merge a `production`.
- `production`: sin cambiar todavía; se actualizará cuando se haga merge de `update-to-4.11.1` y se validen migraciones y pruebas.

### Completado después (misma sesión)

- Merge de `update-to-4.11.1` en `production` y push a `origin production`.
- Submódulo en `/opt` actualizado al commit de production (v4.11.1) y push a `main`.

### Despliegue en este servidor: Docker Compose (siempre)

En este servidor Chatwoot **solo** corre con **docker-compose.custom-css.yaml** (imagen `chatwoot/chatwoot:custom-css`). Para aplicar la actualización a v4.11.1:

1. **Reconstruir la imagen** (código ya está en `production`):
   ```bash
   cd /opt/chatwoot
   docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .
   ```
2. **Ejecutar migraciones** con la nueva imagen:
   ```bash
   docker compose -f docker-compose.custom-css.yaml run --rm rails bundle exec rails db:migrate
   ```
3. **Reiniciar servicios** para usar la nueva imagen:
   ```bash
   docker compose -f docker-compose.custom-css.yaml down
   docker compose -f docker-compose.custom-css.yaml up -d
   ```

### Referencia: si en otro entorno usaran Ruby en el host

- En este servidor **no** se usa; aquí todo es Docker Compose. Solo por referencia: el proyecto requiere Ruby 3.4.4; luego `bundle install`, `pnpm install`, `bundle exec rails db:migrate`.

---

## Cómo actualizar Chatwoot en el futuro (para IA y humanos)

Usar este flujo cada vez que se quiera traer una nueva versión upstream (p. ej. v4.12.0). Sustituir `VERSION` por el tag deseado (ej: `v4.12.0`).

### 1. Verificar remotos y traer tags

```bash
cd /opt/chatwoot
git fetch upstream --tags
git checkout production
```

Comprobar que el tag existe: `git tag -l 'v4.*'`.

### 2. Crear rama de respaldo y rama de actualización

```bash
git branch backup/production-pre-VERSION    # ej: backup/production-pre-4.12.0
git checkout -b update-to-VERSION           # ej: update-to-4.12.0
```

### 3. Merge del tag de upstream

```bash
git merge VERSION -m "Merge upstream VERSION into production"
```

Si hay conflictos: resolver (priorizar cambios propios: rate limit, custom CSS, docker compose), luego:

```bash
git add .
git commit -m "Resolve merge conflicts with VERSION"
```

### 4. Versión en configuración

Si el merge no actualizó `config/app.yml`, editar y poner `version: 'X.Y.Z'` según la versión. Hacer commit si hubo cambio.

### 5. Dependencias y migraciones (en el entorno de despliegue)

**En este servidor (Docker Compose):** reconstruir imagen, migrar y reiniciar:

```bash
cd /opt/chatwoot
docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .
docker compose -f docker-compose.custom-css.yaml run --rm rails bundle exec rails db:migrate
docker compose -f docker-compose.custom-css.yaml down && docker compose -f docker-compose.custom-css.yaml up -d
```

(Si en otro entorno usaran Ruby en el host: `bundle install`, `pnpm install`, `bundle exec rails db:migrate`.)

### 6. Pruebas

- Con Docker Compose: tras `up -d`, comprobar en el navegador login, inbox y widget (incl. custom CSS).

### 7. Subir ramas al fork

```bash
git push origin backup/production-pre-VERSION
git push origin update-to-VERSION
```

### 8. Integrar en production (cuando las pruebas estén bien)

```bash
git checkout production
git merge update-to-VERSION -m "Merge update-to-VERSION into production"
git push origin production
```

### 9. Actualizar submódulo en el repo padre

Desde `/opt`:

```bash
git add chatwoot
git commit -m "update chatwoot submodule to VERSION"
git push origin main
```

### Si algo sale mal

- Antes de commitear el merge: `git merge --abort`.
- Volver al estado anterior en `production`: `git checkout production && git reset --hard backup/production-pre-VERSION` (solo si no se ha hecho push de production después del backup).

---

## Referencias

- [Chatwoot releases](https://github.com/chatwoot/chatwoot/releases)
- [Changelog](https://www.chatwoot.com/changelog/)
- Repo upstream: `https://github.com/chatwoot/chatwoot.git` (remoto `upstream` en este repo).
