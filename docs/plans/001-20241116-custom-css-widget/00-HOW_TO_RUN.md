# 🚀 Cómo Ver los Cambios Reflejados

Esta guía te muestra exactamente cómo ejecutar Chatwoot localmente y ver la funcionalidad de `customCSS` funcionando.

---

## 📋 Requisitos Previos

Verifica que tengas instalado:
```bash
ruby --version          # Ruby 3.0+
node --version          # Node.js 16+
pnpm --version          # pnpm (gestor de paquetes)
```

---

## 🚀 Paso 1: Setup del Proyecto

### 1.1 Instalar dependencias

```bash
cd /opt/chatwoot

# Instalar gemas de Ruby
bundle install

# Instalar paquetes de Node.js
pnpm install
```

**Tiempo estimado:** 5-10 minutos  
**Salida esperada:** Sin errores

---

## 🔨 Paso 2: Compilar Assets

### 2.1 Compilar JavaScript/Vue

```bash
# Opción A: Modo desarrollo (rápido, con recarga en vivo)
pnpm dev

# Opción B: Build una sola vez
pnpm build
```

### 2.2 Compilar CSS y Assets

Si es necesario:
```bash
pnpm build:css
```

**Nota:** El comando `pnpm dev` hace todo automáticamente.

---

## ▶️ Paso 3: Ejecutar el Servidor

### 3.1 Iniciar Chatwoot con Overmind

```bash
# En una terminal nueva (desde /opt/chatwoot)
overmind start -f ./Procfile.dev
```

**Salida esperada:**
```
[Web] Listening on 0.0.0.0:3000
[Webpack] Compiled successfully
[Rails] Started server...
```

### 3.2 Alternativa: Sin Overmind

```bash
# Terminal 1: Rails server
rails s -b 0.0.0.0 -p 3000

# Terminal 2 (nueva): Webpack dev
pnpm dev
```

---

## 🌐 Paso 4: Acceder a la Aplicación

### 4.1 Abrir en Navegador

```
http://localhost:3000
```

### 4.2 Login (si es necesario)

- **Email:** admin@chatwoot.test
- **Password:** password

---

## 🧪 Paso 5: Ver los Cambios

### 5.1 Verificar que el SDK tiene `customCSS`

#### Opción A: En el Widget HTML

Crea un archivo `test-custom-css.html` con:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Test Custom CSS</title>
</head>
<body>
  <h1>Testing Custom CSS en Chatwoot</h1>
  
  <script>
    (function(d,t) {
      var BASE_URL = "http://localhost:3000";
      var g = d.createElement(t), s = d.getElementsByTagName(t)[0];
      g.src = BASE_URL + "/packs/js/sdk.js";
      g.async = true;
      s.parentNode.insertBefore(g,s);
      g.onload = function() {
        // ✨ AQUÍ VAS A VER EL CAMBIO
        window.chatwootSDK.run({
          websiteToken: "YOUR_TOKEN_HERE",
          baseUrl: BASE_URL,
          customCSS: `
            button[class*="inline-flex"] {
              background-color: #8caca1 !important;
              color: #ffffff !important;
              border-radius: 8px !important;
              padding: 10px 16px !important;
            }
            
            button[class*="inline-flex"]:hover {
              background-color: #7a9690 !important;
              box-shadow: 0 4px 12px rgba(140, 172, 161, 0.3) !important;
            }
          `
        })
      }
    })(document, "script");
  </script>
</body>
</html>
```

#### Opción B: En DevTools del Widget

1. Abre http://localhost:3000
2. Abre DevTools (F12)
3. Busca el iframe: `#chatwoot_live_chat_widget`
4. En Elements, busca: `<style id="cw-custom-widget-styles">`
5. ¡Deberías ver tu CSS inyectado ahí!

---

## 📊 Paso 6: Verificación Visual

### 6.1 Abrir página de testing

```bash
# Abre en tu navegador (desde archivos locales)
file:///opt/chatwoot/docs/plans/001-20241116-custom-css-widget/TEST_CUSTOM_CSS.html
```

### 6.2 Abrir ejemplos

```bash
# Abre en tu navegador
file:///opt/chatwoot/docs/plans/001-20241116-custom-css-widget/CUSTOM_CSS_EXAMPLE.html
```

---

## 🧹 Paso 7: Linting y Testing

### 7.1 Verificar que no hay errores de linting

```bash
# JavaScript/Vue
pnpm eslint

# Ruby
bundle exec rubocop -a
```

**Salida esperada:** 0 errores ✅

### 7.2 Ejecutar tests (opcional)

```bash
# Tests de JavaScript
pnpm test

# Tests de Ruby
bundle exec rspec spec/javascript/widget/App.spec.js
```

---

## 🔍 Paso 8: Inspeccionar el Código Modificado

### 8.1 Ver cambios en los archivos

```bash
# Ver cambios en sdk.js
git diff app/javascript/entrypoints/sdk.js

# Ver cambios en IFrameHelper.js
git diff app/javascript/sdk/IFrameHelper.js

# Ver cambios en App.vue
git diff app/javascript/widget/App.vue
```

### 8.2 Confirmar que los cambios están presentes

```bash
# Buscar customCSS
grep -n "customCSS" app/javascript/entrypoints/sdk.js
grep -n "customCSS" app/javascript/sdk/IFrameHelper.js
grep -n "customCSS" app/javascript/widget/App.vue
```

**Salida esperada:** 3 coincidencias (una por archivo)

---

## 📝 Paso 9: Documento de Verificación

Crea un checklist de lo que debes ver:

- [ ] `pnpm dev` compila sin errores
- [ ] `overmind start -f ./Procfile.dev` inicia correctamente
- [ ] http://localhost:3000 carga sin errores
- [ ] En DevTools, veo `<style id="cw-custom-widget-styles">`
- [ ] El CSS personalizado está dentro del style
- [ ] `pnpm eslint` retorna 0 errores
- [ ] Los 3 archivos tienen los cambios esperados

---

## 🐛 Troubleshooting

### "No veo el archivo `cw-custom-widget-styles` en DevTools"

**Solución:**
1. Abre DevTools (F12)
2. Ve a Elements (Elementos)
3. Busca el iframe: `#chatwoot_live_chat_widget`
4. Busca dentro del iframe el elemento `<style>`

### "Los cambios no se reflejan después de modificar código"

**Solución:**
```bash
# Si estás en development, los cambios deberían ser automáticos
# Si no, recarga la página: Ctrl+Shift+R (hard refresh)

# Si aún no aparecen, limpia caché:
rm -rf tmp/
pnpm dev
```

### "Error al compilar JavaScript"

**Solución:**
```bash
# Limpia la compilación anterior
rm -rf public/packs/*
pnpm dev
```

### "Puerto 3000 ya está en uso"

**Solución:**
```bash
# Usa otro puerto
rails s -b 0.0.0.0 -p 3001
```

---

## 🔄 Flujo Completo (Copy-Paste)

```bash
# 1. Ir al directorio
cd /opt/chatwoot

# 2. Instalar dependencias (si no están instaladas)
bundle install && pnpm install

# 3. Iniciar el servidor
overmind start -f ./Procfile.dev

# En otra terminal:

# 4. Abrir en navegador
open http://localhost:3000

# 5. Abrir DevTools (F12)
# 6. Buscar: <style id="cw-custom-widget-styles">
# 7. ¡Ver los cambios! ✅
```

---

## 📊 Estructura del Flujo

```
Tu Código HTML
    ↓
window.chatwootSDK.run({ customCSS: "..." })
    ↓
SDK (app/javascript/entrypoints/sdk.js) 
    ↓ Almacena en window.$chatwoot.customCSS
    ↓
Widget iframe se carga
    ↓
IFrameHelper (app/javascript/sdk/IFrameHelper.js)
    ↓ Envía customCSS en config-set
    ↓
App.vue (app/javascript/widget/App.vue)
    ↓ injectCustomCSS()
    ↓
<style id="cw-custom-widget-styles"> creado
    ↓
✅ CSS aplicado al widget
```

---

## 🎯 Verificación Final

### Checklist de Verificación

```bash
# 1. Verifica que los archivos están modificados
grep -c "customCSS" app/javascript/entrypoints/sdk.js
grep -c "customCSS" app/javascript/sdk/IFrameHelper.js
grep -c "customCSS" app/javascript/widget/App.vue

# Salida esperada: 1, 1, 2 (respectivamente)

# 2. Verifica linting
pnpm eslint

# Salida esperada: 0 errores

# 3. Verifica que el proyecto compila
pnpm build

# Salida esperada: Sin errores
```

---

## 📚 Próximos Pasos

1. **Desarrollo Local Completado** ✅
2. **Testing en Staging** - Implementa en staging
3. **Code Review** - Solicita revisión
4. **Deploy a Producción** - Sube a producción
5. **Comunicación a Clientes** - Anuncia la nueva funcionalidad

---

## 💡 Tips

- 💾 Guarda cambios frecuentemente
- 🔄 Hard refresh (Ctrl+Shift+R) si ves caché
- 📱 Testea en mobile también (F12 → Device Toggle)
- 🌙 Prueba en modo oscuro (Chrome DevTools)
- 🧹 Mantén el linting limpio durante desarrollo

---

## 📞 Ayuda Rápida

| Problema | Solución |
|----------|----------|
| Puerto ocupado | `lsof -i :3000` y mata el proceso |
| Caché viejo | Ctrl+Shift+R |
| Node modules rotos | `rm -rf node_modules && pnpm install` |
| Compilación lenta | Abre pnpm dev en terminal separada |

---

**Tiempo total estimado:** 15-30 minutos desde cero

**Última actualización:** 2024-11-16

¡Listo para ver los cambios en acción! 🚀

