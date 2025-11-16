# 🔧 Quick Fix - Error de Permisos en Bundler

## 🚨 El Problema

```
ERROR: While executing gem ... (Gem::FilePermissionError)
You don't have write permissions for the /var/lib/gems/3.2.0 directory.
```

## ✅ La Solución

El script ya fue actualizado para usar `sudo gem install bundler`.

**Simplemente continúa ejecutando:**

```bash
./setup-ubuntu.sh
```

El script manejará automáticamente los permisos.

---

## 🔄 Si Ya Empezaste

Si el script se detuvo, simplemente ejecuta de nuevo:

```bash
cd /opt/chatwoot
./setup-ubuntu.sh
```

Es seguro ejecutarlo múltiples veces.

---

## 💡 ¿Por qué pasó?

Ruby instalado del sistema Ubuntu (`ruby-full`) requiere `sudo` para instalar gemas globalmente.

**Solución definitiva (opcional para el futuro):**

Si quieres evitar `sudo` en el futuro, usa rbenv:

```bash
# Desinstalar Ruby del sistema
sudo apt-get remove ruby-full

# Instalar rbenv (ver SETUP-UBUNTU.md Opción B)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
~/.rbenv/bin/rbenv install 3.2.0
```

---

## ✅ Continúa

Ejecuta:

```bash
./setup-ubuntu.sh
```

¡El script ya está arreglado! 🎉

