# ⚡ Cheat Sheet - customCSS (Docker Compose Only)

## 🚀 START HERE

### Workflow Completo

```bash
# 1. Edita archivos locales
vim app/javascript/widget/App.vue

# 2. Recompila imagen (~3-5 min)
docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .

# 3. Reinicia contenedores
docker compose -f docker-compose.custom-css.yaml restart rails

# 4. Navega: http://localhost:3000

# 5. Recarga: F5

# 6. Verifica en DevTools (F12)
```

---

## 🔄 Quick Commands

```bash
# Levantar por primera vez
docker compose -f docker-compose.custom-css.yaml up -d

# Ver logs
docker compose -f docker-compose.custom-css.yaml logs -f rails

# Estado
docker compose -f docker-compose.custom-css.yaml ps

# Parar
docker compose -f docker-compose.custom-css.yaml down

# Limpiar (pierde datos)
docker compose -f docker-compose.custom-css.yaml down -v

# Reiniciar solo Rails
docker compose -f docker-compose.custom-css.yaml restart rails
```

---

## 📝 Archivos a Editar

```
app/javascript/entrypoints/sdk.js          # Configuración
app/javascript/sdk/IFrameHelper.js         # Pasar parámetro
app/javascript/widget/App.vue              # Inyectar CSS
```

---

## 🔍 Verificar que Funciona

**DevTools (F12):**

1. Elements
2. Busca iframe: `#chatwoot_live_chat_widget`
3. Dentro → Busca: `<style id="cw-custom-widget-styles">`
4. ✅ ¡Verás tu CSS!

---

## 🆘 Problemas

| Problema | Solución |
|----------|----------|
| `Port 3000 in use` | `lsof -ti:3000 \| xargs kill -9` |
| Cambios no aparecen | Recompila imagen + Ctrl+Shift+R |
| Rails restarting | Ver logs: `docker compose logs rails` |
| Errores JS/Vue | Ver logs build + arreglar sintaxis |

---

## 📚 Con Makefile

```bash
make customcss-help             # Ver opciones
make docker-build-custom        # Compilar
make docker-up-custom           # Levantar
make docker-logs-custom         # Logs
make docker-down-custom         # Parar
```

---

**¡Listo! Edit → Build → Restart → Refresh 🎉**
