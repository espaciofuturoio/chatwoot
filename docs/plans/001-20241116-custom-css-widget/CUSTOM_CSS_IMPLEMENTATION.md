# 🎨 Implementación de customCSS en Widget de Chatwoot

## 📋 Resumen

Se ha implementado la funcionalidad `customCSS` que permite personalizar completamente el estilo del widget de Chatwoot, incluyendo el botón "Start Conversation", sin necesidad de tocar el código del widget.

## 🎯 Características

- ✅ Parámetro `customCSS` en el SDK
- ✅ Inyección de CSS en el iframe del widget
- ✅ Prevención de inyecciones duplicadas
- ✅ Soporte para variables CSS
- ✅ Compatible con modo oscuro
- ✅ Transiciones y animaciones suaves

## 🔧 Cambios Realizados

### 1. SDK (app/javascript/entrypoints/sdk.js)

**Cambio:** Se agregó el parámetro `customCSS` a `window.$chatwoot`

```javascript
window.$chatwoot = {
  // ... otros parámetros ...
  customCSS: chatwootSettings.customCSS || '',
}
```

**Ubicación:** Línea 82

---

### 2. IFrameHelper (app/javascript/sdk/IFrameHelper.js)

**Cambio:** Se pasa `customCSS` al iframe cuando se recibe el evento 'loaded'

```javascript
IFrameHelper.sendMessage('config-set', {
  // ... otros parámetros ...
  customCSS: window.$chatwoot.customCSS,
});
```

**Ubicación:** Línea 176

---

### 3. App.vue (app/javascript/widget/App.vue)

**Cambios:**

a) Se agregó la llamada al método `injectCustomCSS()` en el listener:

```javascript
if (message.event === 'config-set') {
  // ... otros métodos ...
  this.injectCustomCSS(message.customCSS);
}
```

**Ubicación:** Línea 264

b) Se implementó el método `injectCustomCSS()`:

```javascript
injectCustomCSS(customCSS) {
  if (!customCSS) return;

  // Check if custom style already exists
  if (document.getElementById('cw-custom-widget-styles')) {
    return;
  }

  const style = document.createElement('style');
  style.id = 'cw-custom-widget-styles';
  style.innerHTML = customCSS;
  document.head.appendChild(style);
}
```

**Ubicación:** Línea 349-361

---

## 📚 Uso

### Sintaxis Básica

```javascript
window.chatwootSDK.run({
  websiteToken: 'tu-token',
  baseUrl: 'https://tu-dominio.com',
  customCSS: `
    /* Tu CSS personalizado aquí */
    button {
      background-color: #8caca1 !important;
    }
  `
})
```

### Ejemplo: Personalizar el Botón "Start Conversation"

```html
<!DOCTYPE html>
<html>
<head>
  <script>
    (function(d, t) {
      var BASE_URL = "https://tu-dominio.com";
      var g = d.createElement(t), s = d.getElementsByTagName(t)[0];
      g.src = BASE_URL + "/packs/js/sdk.js";
      g.async = true;
      s.parentNode.insertBefore(g, s);
      g.onload = function() {
        window.chatwootSDK.run({
          websiteToken: "abc123",
          baseUrl: BASE_URL,
          customCSS: `
            /* Botón principal */
            button[class*="inline-flex"] {
              background-color: #8caca1 !important;
              color: #ffffff !important;
              border-radius: 8px !important;
              padding: 10px 16px !important;
            }

            /* Hover */
            button[class*="inline-flex"]:hover {
              background-color: #7a9690 !important;
              box-shadow: 0 4px 12px rgba(140, 172, 161, 0.3) !important;
            }
          `
        })
      }
    })(document, "script");
  </script>
</head>
<body>
  <h1>Mi Sitio Web</h1>
</body>
</html>
```

---

## 🎨 Selectores CSS Disponibles

| Elemento | Selector |
|----------|----------|
| Botón "Start Conversation" | `button[class*="inline-flex"]` |
| Contenedor principal | `.flex.flex-col.justify-end` |
| Icono Chevron | `i.i-lucide-chevron-right` |
| Contenedor de sombra | `.shadow` |
| Border radius | `.rounded-xl` |
| Padding | `.px-5.py-4` |

---

## 💡 Ejemplos Avanzados

### 1. Tema Completo Personalizado

```javascript
customCSS: `
  /* Variables CSS */
  :root {
    --brand-color: #8caca1;
    --brand-dark: #7a9690;
  }

  /* Botón */
  button[class*="inline-flex"] {
    background: linear-gradient(135deg, var(--brand-color), var(--brand-dark));
    color: white !important;
    border-radius: 8px !important;
    padding: 12px 20px !important;
    transition: all 0.3s ease !important;
  }

  button[class*="inline-flex"]:hover {
    transform: translateY(-2px) !important;
    box-shadow: 0 8px 20px rgba(140, 172, 161, 0.4) !important;
  }

  /* Dark mode */
  .dark button[class*="inline-flex"] {
    background: linear-gradient(135deg, #5a7a6f, #4a6a5f);
  }
`
```

### 2. Animaciones

```javascript
customCSS: `
  @keyframes slideUp {
    from {
      opacity: 0;
      transform: translateY(10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  button[class*="inline-flex"] {
    animation: slideUp 0.4s ease-out !important;
  }
`
```

### 3. Responsive Design

```javascript
customCSS: `
  button[class*="inline-flex"] {
    padding: 10px 16px !important;
  }

  @media (max-width: 640px) {
    button[class*="inline-flex"] {
      padding: 8px 12px !important;
      font-size: 14px !important;
    }
  }
`
```

---

## 🔍 Flujo de Inyección

```
┌─────────────────────────────────────────────────────┐
│ 1. Usuario llama window.chatwootSDK.run()           │
│    con customCSS                                     │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 2. SDK almacena en window.$chatwoot.customCSS       │
│    (app/javascript/entrypoints/sdk.js)              │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 3. Widget iframe se carga                           │
│    Envía evento 'loaded'                            │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 4. IFrameHelper recibe 'loaded'                     │
│    Envía 'config-set' con customCSS                 │
│    (app/javascript/sdk/IFrameHelper.js)             │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 5. App.vue recibe 'config-set'                      │
│    Llama injectCustomCSS()                          │
│    (app/javascript/widget/App.vue)                  │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 6. CSS inyectado en document.head                   │
│    del iframe con id 'cw-custom-widget-styles'      │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Testing

### Verificar que customCSS se inyecte correctamente

1. Abre DevTools (F12)
2. Busca el elemento `<style id="cw-custom-widget-styles">`
3. Verifica que el CSS esté presente y correcto

### Verificar que el CSS se aplique

1. Inspecciona el botón "Start Conversation"
2. En el panel Styles, busca las reglas de tu `customCSS`
3. Verifica que no sean sobrescritas por otros estilos

---

## 🐛 Troubleshooting

### Los estilos no se aplican

**Solución 1:** Usa `!important`
```css
color: #ffffff !important;  /* ✅ Correcto */
color: #ffffff;              /* ❌ Podría no funcionar */
```

**Solución 2:** Verifica el CSS
- Abre DevTools
- Ve a la pestaña Network
- Busca requests fallidos
- Revisa la consola de errores

### El CSS no aparece en el iframe

**Solución:** Verifica que `customCSS` se envíe correctamente
1. En DevTools, busca el mensaje 'config-set'
2. Expande el objeto y busca el campo `customCSS`
3. Verifica que contenga tu CSS

---

## 🔐 Consideraciones de Seguridad

⚠️ **Importante:** El parámetro `customCSS` acepta cualquier CSS. Evita:

1. **No inyectes código JavaScript**
   ```css
   /* ❌ Esto no funcionará en CSS puro */
   background: url('javascript:alert("hack")');
   ```

2. **No uses content que sea HTML**
   ```css
   /* ❌ Esto es HTML, no CSS */
   content: '<script>alert("hack")</script>';
   ```

3. **CSS es seguro:** Solo puede aplicar estilos, no ejecutar código

---

## 📊 Compatibilidad

| Navegador | Versión | Soporte |
|-----------|---------|---------|
| Chrome | 90+ | ✅ Full |
| Firefox | 88+ | ✅ Full |
| Safari | 14+ | ✅ Full |
| Edge | 90+ | ✅ Full |
| IE 11 | - | ❌ No soportado |

---

## 🚀 Próximas Mejoras Sugeridas

1. **customJS:** Agregar soporte para JavaScript personalizado
2. **Configuration UI:** Panel de administración para personalizar CSS
3. **CSS Templates:** Plantillas predefinidas de temas
4. **Preview:** Vista previa en vivo en el dashboard

---

## 📞 Soporte

Para reportar problemas o sugerir mejoras:
1. Revisa los ejemplos en `CUSTOM_CSS_EXAMPLE.html`
2. Verifica el flujo de inyección en DevTools
3. Consulta el troubleshooting anterior
4. Contacta al equipo de soporte

---

## 📄 Changelog

### v1.0 (Actual)
- ✅ Implementación inicial de `customCSS`
- ✅ Inyección segura en iframe
- ✅ Prevención de duplicados
- ✅ Documentación completa

---

**Última actualización:** Noviembre 2024
**Autor:** Equipo de Desarrollo
**Estado:** ✅ Producción

