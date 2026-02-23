# Actualizar Chatwoot a v4.11.1

## Verificación (feb 2025)

- **Repo**: `/opt/chatwoot` (submódulo → `espaciofuturoio/chatwoot`).
- **Upstream**: `https://github.com/chatwoot/chatwoot.git` (remoto `upstream`).
- **Rama actual**: `production`.
- **Versión en código**: `config/app.yml` → `4.7.0`.
- **Última versión upstream**: **v4.11.1** (tag ya traído con `git fetch upstream --tags`).

### Estado respecto a v4.11.1

| Concepto | Valor |
|--------|--------|
| Commits en **v4.11.1** que no tienes | **273** (traerías todas las mejoras/parches hasta 4.11.1) |
| Commits **solo en production** (fork) | **5** (hay que conservarlos) |

Commits propios a conservar:

- `chore: increase rate limit`
- `chore: use custom style` (custom CSS widget)
- `chore: sync upstream`
- `Merge branch 'develop' into production`
- `chore: improve docker compose - load password from .env`

**Conclusión**: Sí se puede actualizar. La forma más segura es hacer **merge** de `v4.11.1` en `production` (no rebase), para no reescribir historia y mantener tus 5 commits.

---

## Pasos recomendados para actualizar

Hacerlo en máquina de desarrollo/staging primero; luego repetir en producción cuando esté estable.

1. **Entrar al submódulo y asegurar remotos**
   ```bash
   cd /opt/chatwoot
   git fetch upstream --tags
   git checkout production
   ```

2. **Crear rama de actualización (opcional pero recomendado)**
   ```bash
   git checkout -b update-to-4.11.1
   ```

3. **Merge de v4.11.1**
   ```bash
   git merge v4.11.1 -m "Merge upstream v4.11.1 into production"
   ```

4. **Resolver conflictos**  
   Si hay conflictos, resolver (priorizar conservar vuestros cambios de rate limit, custom style y docker compose). Luego:
   ```bash
   git add .
   git commit -m "Resolve merge conflicts with v4.11.1"
   ```

5. **Actualizar versión en configuración**
   - Editar `config/app.yml`: cambiar `version: '4.7.0'` a `version: '4.11.1'`.
   - Commit: `chore: set version to 4.11.1`.

6. **Instalar dependencias y migraciones**
   ```bash
   bundle install
   pnpm install
   bundle exec rails db:migrate
   ```

7. **Pruebas básicas**
   - `pnpm dev` o `make run` y comprobar login, inbox, widget (incluido custom CSS).
   - Si usáis Docker: reconstruir imagen y probar con `docker-compose`.

8. **Subir a vuestro fork**
   ```bash
   git push origin update-to-4.11.1   # o production si hiciste merge directo en production
   ```

9. **Actualizar submódulo en el repo padre**
   Desde `/opt`:
   ```bash
   git add chatwoot
   git commit -m "update chatwoot submodule to v4.11.1"
   git push origin main   # o la rama que uses
   ```

---

## Si algo sale mal

- Para abortar el merge antes de commitear: `git merge --abort`.
- La rama `production` no se habrá movido hasta que hagas `git checkout production && git merge update-to-4.11.1` (o hagas el merge directamente en `production` y push).

---

## Referencias

- [Chatwoot releases](https://github.com/chatwoot/chatwoot/releases)
- Changelog: https://www.chatwoot.com/changelog/
