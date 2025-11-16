# 🚀 Quick Start - Desarrollo con customCSS (Docker Compose)

Este guide te muestra cómo hacer cambios al widget customCSS y verlos reflejados usando **docker compose**.

---

## 📋 Tabla de Contenidos

1. [Setup Inicial](#setup-inicial)
2. [Flujo de Trabajo](#flujo-de-trabajo)
3. [Comandos Útiles](#comandos-útiles)
4. [Troubleshooting](#troubleshooting)

---

## 🔧 Setup Inicial

### Requisitos

- Docker y Docker Compose instalados
- Chatwoot compilado: `docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .`

### Primera Vez

```bash
# Usar el docker-compose.custom-css.yaml
docker compose -f docker-compose.custom-css.yaml up -d

# Espera ~30 segundos a que levante
# Abre: http://localhost:3000
```

✅ **¡Listo!** Chatwoot está corriendo con customCSS.

---

## 🎯 Flujo de Trabajo

### 1️⃣ Edita los Cambios

Los archivos a editar están en tu máquina local:

```
app/javascript/entrypoints/sdk.js          # Configuración inicial
app/javascript/sdk/IFrameHelper.js         # Pasar customCSS al iframe
app/javascript/widget/App.vue              # Inyectar CSS dinámicamente
```

### 2️⃣ Recompila la Imagen

```bash
docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .
```

Espera a que termine (~3-5 minutos). ☕

### 3️⃣ Reinicia los Contenedores

```bash
docker compose -f docker-compose.custom-css.yaml down
docker compose -f docker-compose.custom-css.yaml up -d
```

### 4️⃣ Verifica en el Navegador

```
http://localhost:3000
```

Recarga la página (F5) para ver los cambios.

### 5️⃣ Verifica que el CSS Está Inyectado

Abre DevTools (F12):

1. Elements → Busca el iframe: `#chatwoot_live_chat_widget`
2. Dentro del iframe → Busca: `<style id="cw-custom-widget-styles">`
3. ✅ Verás tu CSS inyectado

---

## ⚡ Comandos Útiles

### Ver Estado de los Contenedores

```bash
docker compose -f docker-compose.custom-css.yaml ps
```

Deberías ver:
- ✅ `rails-1` (Up)
- ✅ `sidekiq-1` (Up)
- ✅ `postgres-1` (Up)
- ✅ `redis-1` (Up)

### Ver Logs

```bash
# Todos los logs
docker compose -f docker-compose.custom-css.yaml logs -f

# Solo Rails
docker compose -f docker-compose.custom-css.yaml logs -f rails

# Solo PostgreSQL
docker compose -f docker-compose.custom-css.yaml logs -f postgres
```

### Detener Todo

```bash
docker compose -f docker-compose.custom-css.yaml down
```

### Detener y Limpiar Volúmenes (⚠️ Pierde datos)

```bash
docker compose -f docker-compose.custom-css.yaml down -v
```

### Reiniciar un Contenedor Específico

```bash
docker compose -f docker-compose.custom-css.yaml restart rails
```

---

## 🎨 Cambios Comunes

### Agregar Nuevo Parámetro customCSS

**Paso 1: `app/javascript/entrypoints/sdk.js`**

```javascript
window.$chatwoot = {
  // ... otros parámetros ...
  customCSS: chatwootSettings.customCSS || '',  // ← Agregar aquí
};
```

**Paso 2: `app/javascript/sdk/IFrameHelper.js`**

```javascript
IFrameHelper.sendMessage('config-set', {
  // ... otros parámetros ...
  customCSS: window.$chatwoot.customCSS,  // ← Agregar aquí
});
```

**Paso 3: `app/javascript/widget/App.vue`**

```vue
// En registerListeners()
if (message.event === 'config-set') {
  // ... otros handlers ...
  this.injectCustomCSS(message.customCSS);  // ← Agregar aquí
}

// Implementar método
injectCustomCSS(customCSS) {
  if (!customCSS) return;
  
  if (document.getElementById('cw-custom-widget-styles')) {
    return;
  }
  
  const style = document.createElement('style');
  style.id = 'cw-custom-widget-styles';
  style.innerHTML = customCSS;
  document.head.appendChild(style);
}
```

---

## 📊 Workflow Resumido

```bash
# 1. Edita archivos en tu máquina local
vim app/javascript/widget/App.vue

# 2. Recompila imagen
docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .

# 3. Reinicia contenedores
docker compose -f docker-compose.custom-css.yaml restart rails

# 4. Recarga navegador
# http://localhost:3000 → F5

# 5. Verifica en DevTools (F12)
```

---

## 🆘 Troubleshooting

### Error: `Port 3000 already in use`

**Causa:** Otro contenedor usa el puerto 3000.

**Solución:**

```bash
# Mata el proceso
lsof -ti:3000 | xargs kill -9

# O para Chatwoot específicamente
docker compose -f docker-compose.custom-css.yaml down
```

---

### Cambios no aparecen

**Causa:** La imagen no fue recompilada.

**Solución:**

```bash
# Recompila la imagen
docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .

# Reinicia
docker compose -f docker-compose.custom-css.yaml down
docker compose -f docker-compose.custom-css.yaml up -d

# Limpia cache navegador: Ctrl+Shift+R
```

---

### Rails no inicia (Restarting)

**Causa:** Error en la base de datos o configuración.

**Solución:**

```bash
# Ver logs de error
docker compose -f docker-compose.custom-css.yaml logs rails

# Reinicia todo
docker compose -f docker-compose.custom-css.yaml down -v
docker compose -f docker-compose.custom-css.yaml up -d
```

---

### Errores de compilación JavaScript

**Causa:** Error de sintaxis en Vue o JavaScript.

**Solución:**

```bash
# Ver logs del build
docker compose -f docker-compose.custom-css.yaml logs rails

# Buscar línea de error y arreglar el archivo

# Recompilar
docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .
```

---

## 🚀 Con Makefile (Más Fácil)

Si prefieres usar comandos cortos:

```bash
# Ver todas las opciones de customCSS
make customcss-help

# Usar los comandos
make docker-build-custom     # Recompila imagen
make docker-up-custom        # Levanta contenedores
make docker-logs-custom      # Ver logs
make docker-down-custom      # Para contenedores
```

---

## 📚 Documentación Relacionada

```
CHEATSHEET-CUSTOMCSS.md             # Referencia rápida
/docs/plans/.../00-START-HERE.md    # Ejemplos de CSS
/docs/plans/.../00-HOW_TO_RUN.md    # Guía detallada
```

---

## ✅ Resumen Rápido

| Tarea | Comando |
|-------|---------|
| **Compilar imagen** | `docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .` |
| **Levantar** | `docker compose -f docker-compose.custom-css.yaml up -d` |
| **Parar** | `docker compose -f docker-compose.custom-css.yaml down` |
| **Logs** | `docker compose -f docker-compose.custom-css.yaml logs -f rails` |
| **Reiniciar Rails** | `docker compose -f docker-compose.custom-css.yaml restart rails` |
| **Estado** | `docker compose -f docker-compose.custom-css.yaml ps` |

---

**¡Happy coding! 🎉**
