# 🚀 START HERE - Ubuntu 24.04 LTS

Tu máquina: **Ubuntu 24.04.3 LTS**

---

## ⚡ 4 Pasos para Comenzar

### Paso 1: Ejecuta el setup automático

```bash
cd /opt/chatwoot
./setup-ubuntu.sh
```

**Qué hace:**
- Instala Ruby
- Instala Node.js + pnpm
- Instala PostgreSQL y Redis
- Instala Overmind
- Configura todo automáticamente

**Tiempo:** 15-30 minutos

### Paso 2: Inicia Chatwoot

```bash
make run
```

Verás:
```
[Web] Listening on 0.0.0.0:3000
[Webpack] Compiled successfully
```

### Paso 3: Abre en navegador

```
http://localhost:3000
```

### Paso 4: Verifica customCSS

1. Abre DevTools: **F12**
2. Ve a **Elements**
3. Busca el iframe: `#chatwoot_live_chat_widget`
4. Dentro busca: `<style id="cw-custom-widget-styles">`
5. ¡Listo! ✨

---

## 📖 Documentación

| Necesito | Archivo |
|----------|---------|
| Guía automática para Ubuntu | `SETUP-UBUNTU.md` |
| Guía manual paso a paso | `SETUP.md` |
| Todos los comandos | `make help` |
| Documentación de customCSS | `/docs/plans/001-20241116-custom-css-widget/00-START-HERE.md` |

---

## 🎯 Si algo falla

### Error: "You don't have write permissions"

Ver: `QUICK-FIX.md` - Ya está arreglado, solo continúa con:
```bash
./setup-ubuntu.sh
```

### Setup se detiene

```bash
# Intenta de nuevo (es seguro ejecutarlo múltiples veces)
./setup-ubuntu.sh

# O instala manualmente
sudo apt-get update && sudo apt-get install -y ruby-full build-essential git nodejs
npm install -g pnpm
sudo gem install bundler
bundle install
pnpm install
make db
```

### El servidor no inicia

```bash
# Reinicia Overmind
make force_run

# O inicia solo Rails
make server
```

### Redis/PostgreSQL no funciona

```bash
# Inicia los servicios
sudo systemctl start postgresql
sudo systemctl start redis-server

# Verifica
sudo systemctl status postgresql
sudo systemctl status redis-server
```

---

## ✅ Verificación Rápida

Verifica que todo está instalado:

```bash
ruby -v              # Ruby 3.0+
node -v              # Node 18+
pnpm -v              # pnpm
psql -V              # PostgreSQL
redis-cli ping       # Redis (debe responder PONG)
overmind --version   # Overmind
```

Si todos responden ✓, ejecuta:

```bash
make run
```

---

## 🚀 Comando Rápido (Todo en Uno)

```bash
cd /opt/chatwoot && ./setup-ubuntu.sh && make run
```

---

## 💡 Tips

1. **Contraseña:** El script pedirá tu contraseña de Ubuntu (sudo)
2. **Tiempo:** Primera vez toma 20-30 minutos
3. **Internet:** Necesita conexión activa
4. **Disco:** Requiere ~2-3 GB de espacio

---

## 📚 Próxima Lectura

Después de que `make run` funcione:

1. Lee `/docs/plans/001-20241116-custom-css-widget/00-START-HERE.md`
2. Explora ejemplos de customCSS
3. ¡Comienza a desarrollar!

---

**¡Buena suerte! 🎉**

Ejecuta: `./setup-ubuntu.sh`

