# 🎯 NVM Solution - Permisos en Node.js

## 🚨 El Problema

```
npm error code EACCES
npm error path /usr/lib/node_modules/pnpm
npm error Error: EACCES: permission denied
```

Node.js instalado del sistema requiere `sudo` para instalar paquetes globales.

## ✅ La Solución: NVM

Se actualizó `setup-ubuntu.sh` para usar **NVM (Node Version Manager)**, que:

- ✓ Instala Node.js en tu carpeta personal (`~/.nvm`)
- ✓ No necesita `sudo`
- ✓ Evita todos los problemas de permisos
- ✓ Permite múltiples versiones de Node.js
- ✓ Es la forma recomendada

## 🚀 Qué Hará el Script Ahora

```bash
# 1. Descargar e instalar NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 2. Activar NVM
source ~/.nvm/nvm.sh

# 3. Instalar Node.js 25 (Latest)
nvm install 25
nvm use 25

# 4. Instalar Corepack
npm install -g corepack

# 5. Instalar pnpm
corepack enable pnpm
```

## 📝 Cambios Realizados

**Archivo:** `setup-ubuntu.sh`

Actualizado para:
- Detectar si NVM ya está instalado
- Instalarlo si no existe
- Usar NVM para instalar Node.js 25 (latest)
- Usar Corepack para instalar pnpm (sin permisos de sudo)

## 🎉 Para Continuar

Simplemente ejecuta:

```bash
./setup-ubuntu.sh
```

El script continuará y completará la instalación sin problemas de permisos.

---

## 💡 Ventajas de NVM

| Aspecto | Sin NVM | Con NVM |
|--------|---------|---------|
| Instalación global | Sistema (/usr/lib) | Usuario (~/.nvm) |
| Permisos | Requiere sudo | Sin sudo |
| Múltiples versiones | ❌ No | ✅ Sí |
| Mantenimiento | Global | Aislado |
| Switching | Complejo | `nvm use X.Y` |

---

**Estado:** ✅ Listo para continuar

Ejecuta: `./setup-ubuntu.sh`

