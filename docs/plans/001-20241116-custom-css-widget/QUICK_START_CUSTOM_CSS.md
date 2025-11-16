# 🚀 Quick Start: Personalizar Widget de Chatwoot

## En 60 segundos

### 1️⃣ Encuentra tu código de instalación

Busca en tu sitio web el código similar a este:

```html
<script>
  (function(d,t) {
    var BASE_URL="https://tu-dominio.com";
    var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
    g.src=BASE_URL+"/packs/js/sdk.js";
    g.async = true;
    s.parentNode.insertBefore(g,s);
    g.onload=function(){
      window.chatwootSDK.run({
        websiteToken: 'tu-token-aqui',
        baseUrl: BASE_URL
      })
    }
  })(document,"script");
</script>
```

### 2️⃣ Agrega el parámetro `customCSS`

```html
<script>
  (function(d,t) {
    var BASE_URL="https://tu-dominio.com";
    var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
    g.src=BASE_URL+"/packs/js/sdk.js";
    g.async = true;
    s.parentNode.insertBefore(g,s);
    g.onload=function(){
      window.chatwootSDK.run({
        websiteToken: 'tu-token-aqui',
        baseUrl: BASE_URL,
        customCSS: `
          /* Personalización aquí */
        `
      })
    }
  })(document,"script");
</script>
```

### 3️⃣ Personaliza el botón

Aquí están los 3 estilos más comunes:

#### Opción A: Botón Verde (Recomendado)
```javascript
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
```

#### Opción B: Botón Azul
```javascript
customCSS: `
  button[class*="inline-flex"] {
    background-color: #1f93ff !important;
    color: #ffffff !important;
    border-radius: 8px !important;
    padding: 10px 16px !important;
  }

  button[class*="inline-flex"]:hover {
    background-color: #0d7dd4 !important;
  }
`
```

#### Opción C: Botón Rojo
```javascript
customCSS: `
  button[class*="inline-flex"] {
    background-color: #ff6b6b !important;
    color: #ffffff !important;
    border-radius: 8px !important;
    padding: 10px 16px !important;
  }

  button[class*="inline-flex"]:hover {
    background-color: #ff5252 !important;
  }
`
```

### 4️⃣ Guarda y Prueba

1. Guarda los cambios
2. Recarga la página
3. Abre DevTools (F12)
4. Busca el iframe y verifica el botón

✅ **¡Listo!**

---

## Ejemplos Avanzados

### Con Animación
```javascript
customCSS: `
  @keyframes slideUp {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }

  button[class*="inline-flex"] {
    background-color: #8caca1 !important;
    color: #ffffff !important;
    border-radius: 8px !important;
    padding: 10px 16px !important;
    animation: slideUp 0.4s ease-out !important;
  }

  button[class*="inline-flex"]:hover {
    transform: translateY(-2px) !important;
    box-shadow: 0 8px 16px rgba(140, 172, 161, 0.4) !important;
  }
`
```

### Gradiente
```javascript
customCSS: `
  button[class*="inline-flex"] {
    background: linear-gradient(135deg, #8caca1 0%, #7a9690 100%) !important;
    color: #ffffff !important;
    border-radius: 8px !important;
    padding: 10px 16px !important;
  }

  button[class*="inline-flex"]:hover {
    box-shadow: 0 8px 20px rgba(140, 172, 161, 0.4) !important;
  }
`
```

### Tema Completo
```javascript
customCSS: `
  /* Botón principal */
  button[class*="inline-flex"] {
    background-color: #8caca1 !important;
    color: #ffffff !important;
    border-radius: 8px !important;
    padding: 10px 16px !important;
  }

  button[class*="inline-flex"]:hover {
    background-color: #7a9690 !important;
  }

  /* Iconos */
  i {
    color: #ffffff !important;
  }

  /* Links */
  a {
    color: #8caca1 !important;
  }

  /* Inputs */
  input, textarea {
    border-color: #8caca1 !important;
  }

  input:focus, textarea:focus {
    box-shadow: 0 0 0 3px rgba(140, 172, 161, 0.1) !important;
  }
`
```

---

## 🎨 Tabla de Colores Recomendados

| Color | Hex | Uso |
|-------|-----|-----|
| Verde Natural | `#8caca1` | Principal |
| Verde Oscuro | `#7a9690` | Hover |
| Azul | `#1f93ff` | Alternativo |
| Rojo | `#ff6b6b` | Atención |
| Naranja | `#ff922b` | Urgencia |
| Morado | `#9775fa` | Premium |

---

## ❌ Errores Comunes

### ❌ No funciona: CSS sin `!important`
```javascript
// INCORRECTO
color: #ffffff;

// CORRECTO
color: #ffffff !important;
```

### ❌ No funciona: Selectores incorrectos
```javascript
// INCORRECTO
.button { ... }
#start-btn { ... }

// CORRECTO
button[class*="inline-flex"] { ... }
```

### ❌ No funciona: CSS inválido
```javascript
// INCORRECTO
botton { color: red; }  // typo en "button"

// CORRECTO
button { color: red; }
```

---

## 🔍 Verificación

### Confirmar que está funcionando

1. **Abre la página en navegador**
2. **Abre DevTools (F12)**
3. **Ve a Elements → encuentra el iframe**
4. **Busca: `<style id="cw-custom-widget-styles">`**
5. **Expande y verifica que tu CSS esté ahí**

Si ves el elemento con tu CSS → ✅ **Funciona**

Si NO lo ves → 
1. Revisa la consola de errores
2. Verifica que copiaste correctamente el `websiteToken`
3. Verifica que NO haya errores de sintaxis en CSS

---

## 💡 Tips Profesionales

### 1️⃣ Usa herramientas online para colores
- [Coolors.co](https://coolors.co) - Paletas de colores
- [ColorHexa.com](https://www.colorhexa.com) - Información de colores
- [WebAIM](https://webaim.org/resources/contrastchecker/) - Contraste

### 2️⃣ Copia estos selectores para cambiar más elementos

```css
/* Botón */
button[class*="inline-flex"]

/* Icono dentro del botón */
i.i-lucide-chevron-right

/* Texto del botón */
button span

/* Contenedor */
.flex.flex-col.justify-end

/* Sombra */
.shadow

/* Border radius */
.rounded-xl
```

### 3️⃣ Minifica tu CSS para producción
Usa herramientas online como:
- [CSSMinifier.com](https://cssminifier.com)
- [Compressor.io](https://compressor.io)

---

## 📚 Recursos Completos

Para más información:
- 📖 Ver `CUSTOM_CSS_IMPLEMENTATION.md` - Documentación técnica
- 🎨 Ver `CUSTOM_CSS_EXAMPLE.html` - 15+ ejemplos HTML
- 🧪 Ver `TEST_CUSTOM_CSS.html` - Testing page

---

## 🆘 Necesitas Ayuda?

### No aparece el botón
→ Verifica el `websiteToken`

### El botón tiene el color equivocado
→ Revisa que uses `!important`

### El CSS es muy largo
→ Minifica o divide en temas

### Conflictos con otros estilos
→ Aumenta especificidad usando `!important`

---

## ✨ Ejemplo Completo Listo para Copiar

```html
<!DOCTYPE html>
<html>
<head>
  <title>Mi Sitio</title>
  <script>
    (function(d,t) {
      var BASE_URL="https://tu-dominio.com";
      var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
      g.src=BASE_URL+"/packs/js/sdk.js";
      g.async = true;
      s.parentNode.insertBefore(g,s);
      g.onload=function(){
        window.chatwootSDK.run({
          websiteToken: 'REEMPLAZA_CON_TU_TOKEN',
          baseUrl: BASE_URL,
          customCSS: `
            button[class*="inline-flex"] {
              background-color: #8caca1 !important;
              color: #ffffff !important;
              border-radius: 8px !important;
              padding: 10px 16px !important;
              transition: all 0.3s ease !important;
            }

            button[class*="inline-flex"]:hover {
              background-color: #7a9690 !important;
              box-shadow: 0 4px 12px rgba(140, 172, 161, 0.3) !important;
              transform: translateY(-2px) !important;
            }

            button[class*="inline-flex"]:active {
              transform: scale(0.98) !important;
            }
          `
        })
      }
    })(document,"script");
  </script>
</head>
<body>
  <h1>Bienvenido a Mi Sitio</h1>
  <p>Presiona el botón de chat abajo a la derecha 👉</p>
</body>
</html>
```

**Reemplaza:**
- `https://tu-dominio.com` por tu dominio
- `REEMPLAZA_CON_TU_TOKEN` por tu websiteToken

**¡Listo!** 🎉

---

**Versión:** 1.0  
**Última actualización:** Noviembre 2024

