# 🏗️ Diagrama de Arquitectura: customCSS en Chatwoot

## 1. Flujo General del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTE HTML                              │
│                                                                  │
│  <!DOCTYPE html>                                                 │
│  <script>                                                        │
│    window.chatwootSDK.run({                                     │
│      websiteToken: "abc123",                                    │
│      customCSS: "button { ... }"  ← NUEVO PARÁMETRO            │
│    })                                                            │
│  </script>                                                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│           SDK JAVASCRIPT (app/javascript/sdk.js)                │
│                                                                  │
│  1. Recibe customCSS del cliente                               │
│  2. Lo almacena en window.$chatwoot.customCSS ← MODIFICADO     │
│                                                                  │
│  window.$chatwoot = {                                           │
│    baseUrl,                                                     │
│    websiteToken,                                               │
│    customCSS: chatwootSettings.customCSS || '',  ← NUEVO      │
│    ...otros parámetros...                                      │
│  }                                                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              CREAR IFRAME (IFrameHelper)                        │
│                                                                  │
│  <iframe id="chatwoot_live_chat_widget"                        │
│          src="https://base-url/widget?token=...">             │
│  </iframe>                                                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
        ┌────────────────────────────────────────┐
        │      DENTRO DEL IFRAME (Widget)       │
        │                                        │
        │  App.vue y componentes Vue            │
        │                                        │
        │  1. Widget se carga                   │
        │  2. Envía evento 'loaded' al parent   │
        └────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│        IFrameHelper.events.loaded() - MODIFICADO               │
│                                                                  │
│  Recibe: evento 'loaded'                                       │
│                                                                  │
│  Envía:                                                         │
│  {                                                              │
│    event: 'config-set',                                        │
│    locale: ...,                                                │
│    customCSS: window.$chatwoot.customCSS  ← AGREGADO          │
│    ...otros config...                                          │
│  }                                                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼ postMessage
        ┌────────────────────────────────────────┐
        │      DENTRO DEL IFRAME (Widget)       │
        │                                        │
        │  App.vue.registerListeners()           │
        │                                        │
        │  Recibe mensaje 'config-set'          │
        │  Llama: injectCustomCSS() ← NUEVO     │
        └────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│        App.vue.injectCustomCSS() - NUEVO MÉTODO               │
│                                                                  │
│  1. Valida que customCSS no esté vacío                         │
│  2. Evita duplicados (busca id='cw-custom-widget-styles')     │
│  3. Crea elemento <style>                                      │
│  4. Asigna innerHTML con customCSS                            │
│  5. Adjunta a document.head                                    │
│                                                                  │
│  const style = document.createElement('style');               │
│  style.id = 'cw-custom-widget-styles';                        │
│  style.innerHTML = customCSS;                                 │
│  document.head.appendChild(style);                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ✅ CSS APLICADO AL WIDGET                    │
│                                                                  │
│  <style id="cw-custom-widget-styles">                          │
│    button[class*="inline-flex"] {                              │
│      background-color: #8caca1 !important;                     │
│      color: #ffffff !important;                                │
│      ...                                                        │
│    }                                                            │
│  </style>                                                       │
│                                                                  │
│  Resultado: Botón personalizado con nuevos estilos             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Cambios Específicos por Archivo

### Archivo: app/javascript/entrypoints/sdk.js
```
ANTES:
┌─────────────────────────────────┐
│ window.$chatwoot = {            │
│   baseUrl,                      │
│   websiteToken,                 │
│   locale,                       │
│   ...                           │
│   enableEndConversation: true,  │
│ }                               │
└─────────────────────────────────┘

DESPUÉS: ✨ LÍNEA 82
┌─────────────────────────────────┐
│ window.$chatwoot = {            │
│   baseUrl,                      │
│   websiteToken,                 │
│   locale,                       │
│   ...                           │
│   enableEndConversation: true,  │
│   customCSS: chatwootSettings   │
│     .customCSS || '',           │ ← NUEVO
│ }                               │
└─────────────────────────────────┘
```

---

### Archivo: app/javascript/sdk/IFrameHelper.js
```
ANTES:
┌─────────────────────────────────────┐
│ IFrameHelper.sendMessage(             │
│   'config-set', {                     │
│     locale: ...,                      │
│     darkMode: ...,                    │
│     enableEndConversation: true,      │
│   }                                   │
│ )                                     │
└─────────────────────────────────────┘

DESPUÉS: ✨ LÍNEA 176
┌─────────────────────────────────────┐
│ IFrameHelper.sendMessage(             │
│   'config-set', {                     │
│     locale: ...,                      │
│     darkMode: ...,                    │
│     enableEndConversation: true,      │
│     customCSS:                        │
│       window.$chatwoot.customCSS, │ ← NUEVO
│   }                                   │
│ )                                     │
└─────────────────────────────────────┘
```

---

### Archivo: app/javascript/widget/App.vue

#### Cambio 1: En registerListeners() ✨ LÍNEA 264
```
ANTES:
if (message.event === 'config-set') {
  this.setLocale(message.locale);
  this.setBubbleLabel();
  ...
  this.setCampaignReadData(message.campaignsSnoozedTill);
}

DESPUÉS:
if (message.event === 'config-set') {
  this.setLocale(message.locale);
  this.setBubbleLabel();
  ...
  this.setCampaignReadData(message.campaignsSnoozedTill);
  this.injectCustomCSS(message.customCSS);  ← NUEVO
}
```

#### Cambio 2: Nuevo método injectCustomCSS() ✨ LÍNEA 349-361
```
ANTES:
setCampaignReadData(snoozedTill) {
  if (snoozedTill) {
    this.campaignsSnoozedTill = Number(snoozedTill);
  }
}

DESPUÉS:
setCampaignReadData(snoozedTill) {
  if (snoozedTill) {
    this.campaignsSnoozedTill = Number(snoozedTill);
  }
},
injectCustomCSS(customCSS) {              ← NUEVO MÉTODO
  if (!customCSS) return;

  if (document.getElementById('cw-custom-widget-styles')) {
    return;  // Evitar duplicados
  }

  const style = document.createElement('style');
  style.id = 'cw-custom-widget-styles';
  style.innerHTML = customCSS;
  document.head.appendChild(style);
}
```

---

## 3. Flujo de Datos - Ejemplo Práctico

```
CLIENTE PASA:
───────────────
customCSS: `
  button[class*="inline-flex"] {
    background-color: #8caca1 !important;
    color: white !important;
  }
`

        ↓
        
SDK LO ALMACENA EN:
───────────────────
window.$chatwoot.customCSS = 
  "button[class*='inline-flex'] { ... }"

        ↓
        
IFRAMEHELPER LO ENVÍA VÍA POSTMESSAGE:
──────────────────────────────────────
{
  event: 'config-set',
  customCSS: "button[class*='inline-flex'] { ... }",
  ...otrosConfig...
}

        ↓
        
APP.VUE LO RECIBE Y PROCESA:
────────────────────────────
injectCustomCSS("button[class*='inline-flex'] { ... }")

        ↓
        
SE CREA EN EL IFRAME:
────────────────────
<style id="cw-custom-widget-styles">
  button[class*="inline-flex"] {
    background-color: #8caca1 !important;
    color: white !important;
  }
</style>

        ↓
        
✅ RESULTADO:
────────────
Botón renderizado con nuevos estilos
```

---

## 4. Estructura de Carpetas (Modificadas)

```
app/javascript/
├── entrypoints/
│   └── sdk.js ........................... ✨ MODIFICADO (Línea 82)
├── sdk/
│   ├── IFrameHelper.js ................ ✨ MODIFICADO (Línea 176)
│   └── DOMHelpers.js .................. (Sin cambios)
└── widget/
    ├── App.vue ....................... ✨ MODIFICADO (Línea 264, 349-361)
    ├── components/
    │   └── TeamAvailability.vue ....... (Sin cambios)
    └── store/
        └── ... ........................ (Sin cambios)
```

---

## 5. Seguridad - Flujo de Validación

```
ENTRADA DEL USUARIO:
customCSS: "input {color: red;}"

        ↓ VALIDACIÓN 1: No está vacío
        
if (!customCSS) return;  ✓ OK

        ↓ VALIDACIÓN 2: No existe duplicado
        
if (document.getElementById('cw-custom-widget-styles')) return;  ✓ OK

        ↓ VALIDACIÓN 3: Se inyecta como CSS puro
        
style.innerHTML = customCSS;  ✓ SEGURO
(CSS no puede ejecutar JavaScript)

        ↓ VALIDACIÓN 4: Se añade solo al HEAD del iframe
        
document.head.appendChild(style);  ✓ SEGURO
(Limitado al contexto del iframe)

        ↓
        
✅ CSS APLICADO CON SEGURIDAD
```

---

## 6. Matriz de Cambios

| Archivo | Línea | Tipo | Cambio |
|---------|-------|------|--------|
| sdk.js | 82 | ADD | `customCSS: chatwootSettings.customCSS \|\| ''` |
| IFrameHelper.js | 176 | ADD | `customCSS: window.$chatwoot.customCSS` |
| App.vue | 264 | ADD | `this.injectCustomCSS(message.customCSS)` |
| App.vue | 349-361 | ADD | Nuevo método `injectCustomCSS()` |

---

## 7. Precedencia de CSS

```
ESPECIFICIDAD DE SELECTORES:

1️⃣ MENOR PRIORIDAD: Estilos del widget (predeterminados)
   Ejemplo: .inline-flex { color: var(--color); }

2️⃣ MAYOR PRIORIDAD: Estilos personalizados (customCSS)
   Ejemplo: button { color: #8caca1 !important; }
   
3️⃣ MÁXIMA PRIORIDAD: Estilos inline con !important
   Ejemplo: <div style="color: red !important;">

RECOMENDACIÓN: Usar !important en customCSS
button[class*="inline-flex"] {
  color: white !important;  ← Asegura que se aplique
}
```

---

## 8. Timeline de Ejecución

```
0ms      ├─ Cliente carga HTML
         │
10ms     ├─ Script SDK comienza a cargar
         │
50ms     ├─ SDK.js se ejecuta
         │  └─ window.$chatwoot se inicializa
         │     └─ customCSS se almacena ✓
         │
100ms    ├─ IFrame se crea y comienza a cargar
         │
200ms    ├─ App.vue dentro del iframe se monta
         │  └─ registerListeners() se ejecuta
         │
250ms    ├─ Widget envía evento 'loaded'
         │
260ms    ├─ IFrameHelper.events.loaded() procesa
         │  └─ Envía 'config-set' CON customCSS ✓
         │
270ms    ├─ App.vue recibe 'config-set'
         │  └─ injectCustomCSS() se ejecuta ✓
         │     └─ <style> se crea y adjunta al HEAD ✓
         │
280ms    ├─ ESTILOS APLICADOS AL DOM
         │  └─ Botón muestra nuevo color ✓
         │
300ms    └─ Widget completamente personalizado ✓
```

---

## 9. Punto de Entrada (SDK)

```
┌──────────────────────────────────────────────────────┐
│  CÓDIGO DEL CLIENTE                                  │
│                                                      │
│  window.chatwootSDK.run({                           │
│    websiteToken: "abc123",     ← Requerido          │
│    baseUrl: "https://...",     ← Requerido          │
│    customCSS: "..."            ← NUEVO, Opcional    │
│  })                                                  │
│                                                      │
│  customCSS: Cualquier CSS válido (String)           │
│  Ejemplo: "button { color: blue; }"                 │
│  Tamaño: Sin límite teórico                         │
│  Validación: Se ejecuta en tiempo de ejecución      │
└──────────────────────────────────────────────────────┘
```

---

## 10. Comparativa: Antes vs Después

| Aspecto | ANTES | DESPUÉS |
|---------|-------|---------|
| Personalización | Limitada a widgetColor | Completa con customCSS |
| Botón "Start Conversation" | Color variable | Color, padding, border-radius, hover, animaciones |
| Selectores CSS | Solo color | Todos los selectores CSS |
| Seguridad | N/A | CSS puro, sin JavaScript |
| Facilidad de uso | Simple | Más potente, similar de fácil |
| Documentación | Básica | Completa |
| Ejemplos | Ninguno | 15+ ejemplos |

---

## 11. Casos de Uso

```
CASO 1: Cliente quiere botón verde
    ✓ Usa customCSS con background-color
    ✓ Resultado: Botón personalizado

CASO 2: Cliente quiere animación suave
    ✓ Usa @keyframes en customCSS
    ✓ Resultado: Botón con animación

CASO 3: Cliente quiere tema completo
    ✓ Usa customCSS con múltiples selectores
    ✓ Resultado: Widget completamente personalizado

CASO 4: Cliente quiere dark mode
    ✓ Usa .dark selector en customCSS
    ✓ Resultado: Estilos en modo oscuro
```

---

**Versión:** 1.0  
**Última actualización:** Noviembre 2024  
**Status:** ✅ Completado

