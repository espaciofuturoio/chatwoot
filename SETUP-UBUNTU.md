# 🚀 Chatwoot Setup Guide - Ubuntu 24.04 LTS

Guía específica para configurar Chatwoot en Ubuntu 24.04.3 LTS.

---

## ✅ Tu Sistema Operativo

```
Distributor: Ubuntu
Release: 24.04.3 LTS
Codename: noble
```

---

## ⚡ Setup Rápido (3 pasos)

```bash
# 1. Instala Ruby y dependencias
sudo apt-get update
sudo apt-get install -y ruby-full build-essential git curl wget

# 2. Instala Node.js + pnpm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g pnpm

# 3. Ejecuta setup de Chatwoot
cd /opt/chatwoot
bundle install
pnpm install
make db
make run
```

**Tiempo total:** 20-30 minutos

---

## 📋 Paso a Paso Detallado

### Paso 1: Actualizar Sistema

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

---

### Paso 2: Instalar Ruby

#### Opción A: Ruby del sistema (Rápido)

```bash
sudo apt-get install -y ruby-full build-essential git

# Verificar
ruby -v
gem --version
```

**Ventaja:** Rápido, fácil
**Desventaja:** Puede ser una versión vieja

#### Opción B: Ruby con rbenv (Recomendado)

```bash
# Instalar dependencias
sudo apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev

# Clonar rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

# Agregar a PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc

# Instalar ruby-build
mkdir -p ~/.rbenv/plugins
cd ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git

# Instalar Ruby
rbenv install 3.2.0
rbenv global 3.2.0

# Verificar
ruby -v  # Ruby 3.2.0
```

---

### Paso 3: Instalar Node.js y pnpm

#### Opción A: Node.js del repositorio de NodeSource

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar pnpm
npm install -g pnpm

# Verificar
node -v        # v20.x.x
pnpm -v        # 8.x.x+
```

#### Opción B: NVM (Node Version Manager)

```bash
# Instalar NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Recargar shell
source ~/.zshrc

# Instalar Node
nvm install 20
nvm use 20

# Instalar pnpm
npm install -g pnpm

# Verificar
node -v
pnpm -v
```

---

### Paso 4: Instalar PostgreSQL (Recomendado)

```bash
sudo apt-get install -y postgresql postgresql-contrib libpq-dev

# Iniciar servicio
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verificar
psql --version
```

---

### Paso 5: Instalar Redis (Recomendado)

```bash
sudo apt-get install -y redis-server

# Iniciar servicio
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verificar
redis-cli --version
redis-cli ping  # Debería responder: PONG
```

---

### Paso 6: Instalar Overmind

```bash
# Descargar última versión
VERSION=$(curl -s https://api.github.com/repos/DarthSim/overmind/releases/latest | grep 'tag_name' | cut -d'"' -f4)

# Para Ubuntu 24.04 LTS (amd64)
curl -L -o /tmp/overmind.gz https://github.com/DarthSim/overmind/releases/download/$VERSION/overmind-$VERSION-linux_amd64.gz

# Descomprimir e instalar
gunzip /tmp/overmind.gz
sudo mv /tmp/overmind /usr/local/bin/overmind
sudo chmod +x /usr/local/bin/overmind

# Verificar
overmind --version
```

---

### Paso 7: Configurar Chatwoot

```bash
cd /opt/chatwoot

# Instalar Bundler
gem install bundler

# Instalar dependencias Ruby
bundle install

# Instalar dependencias Node.js
pnpm install

# Configurar base de datos
make db
```

---

## 🚀 Ejecutar Chatwoot

### Opción A: Con Overmind (Recomendado)

```bash
make run
```

Esto inicia todo automáticamente:
- Rails server (3000)
- Webpack dev server
- Sidekiq worker
- Etc.

### Opción B: Solo Rails

```bash
make server
```

---

## 🌐 Acceder

```
http://localhost:3000
```

Login (si está seeded):
- Email: admin@chatwoot.test
- Password: password

---

## 🔧 Comandos Útiles

```bash
# Ver todos los comandos
make help

# Desarrollo
make run              # Iniciar con Overmind
make server           # Solo Rails
make console          # Rails console
make debug            # Debug

# Base de datos
make db               # Setup completo
make db_migrate       # Migrations
make db_seed          # Seed

# Linting
make lint             # ESLint + Rubocop
pnpm eslint          # Solo JavaScript

# Testing
make test             # Todos los tests
pnpm test            # Tests JavaScript
```

---

## ✅ Verificar Instalación

```bash
ruby -v          # Ruby 3.0+
node -v          # Node 18+
pnpm -v          # pnpm 8+
psql -V          # PostgreSQL
redis-cli -v     # Redis
overmind --version
```

---

## 🐛 Troubleshooting Ubuntu

### Error: "sudo: bundler: command not found"

```bash
gem install bundler
bundle install
```

### Error: "PostgreSQL connection refused"

```bash
# Verificar si PostgreSQL está corriendo
sudo systemctl status postgresql

# Iniciar si no está
sudo systemctl start postgresql

# Crear usuario/DB
sudo -u postgres createuser chatwoot -d
```

### Error: "Redis connection refused"

```bash
# Verificar si Redis está corriendo
sudo systemctl status redis-server

# Iniciar si no está
sudo systemctl start redis-server
```

### Error: "Port 3000 already in use"

```bash
# Encontrar proceso
lsof -i :3000

# Matar proceso
kill -9 <PID>
```

### Error: "Node modules incompatibles"

```bash
# Limpiar e reinstalar
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

---

## 📊 Servicios Necesarios

### Verificar Estado

```bash
# PostgreSQL
sudo systemctl status postgresql

# Redis
sudo systemctl status redis-server

# Overmind
ps aux | grep overmind
```

### Habilitar al Iniciar

```bash
sudo systemctl enable postgresql
sudo systemctl enable redis-server
```

---

## 🔒 Configuración Adicional (Opcional)

### Crear Usuario PostgreSQL Específico

```bash
sudo -u postgres createuser chatwoot -d
sudo -u postgres createdb chatwoot_development -O chatwoot
```

### Configurar PostgreSQL sin Contraseña (Desarrollo)

```bash
# Editar /etc/postgresql/16/main/pg_hba.conf
sudo nano /etc/postgresql/16/main/pg_hba.conf

# Cambiar:
# local   all             all                                     peer
# A:
local   all             all                                     trust

# Reiniciar
sudo systemctl restart postgresql
```

---

## 📁 Estructura del Proyecto

```
/opt/chatwoot/
├── app/
│   ├── javascript/     # Frontend (Vue 3)
│   ├── models/         # Modelos Rails
│   └── controllers/    # Controladores
├── config/             # Configuración
├── db/                 # Migrations
├── Gemfile             # Dependencias Ruby
├── package.json        # Dependencias Node
├── Makefile            # Comandos útiles
├── Procfile.dev        # Procesos para dev
├── SETUP.md            # Guía general
└── docs/               # Documentación
```

---

## 🎯 Primeros Pasos

### 1. Instalar Dependencias

```bash
# Actualizar sistema
sudo apt-get update && sudo apt-get upgrade -y

# Ruby
sudo apt-get install -y ruby-full build-essential git

# Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# pnpm
npm install -g pnpm

# PostgreSQL (opcional)
sudo apt-get install -y postgresql postgresql-contrib libpq-dev

# Redis (opcional)
sudo apt-get install -y redis-server

# Overmind
curl -L https://github.com/DarthSim/overmind/releases/download/v2.4.0/overmind-v2.4.0-linux_amd64.gz | gunzip | sudo tee /usr/local/bin/overmind > /dev/null
sudo chmod +x /usr/local/bin/overmind
```

### 2. Setup Chatwoot

```bash
cd /opt/chatwoot
gem install bundler
bundle install
pnpm install
make db
```

### 3. Iniciar Servidor

```bash
make run
```

### 4. Abrir en Navegador

```
http://localhost:3000
```

---

## 💡 Tips para Ubuntu

1. **Usar `sudo systemctl` para servicios**
   ```bash
   sudo systemctl start/stop/restart postgresql
   sudo systemctl status postgresql
   ```

2. **Permisos de archivo**
   ```bash
   # Si hay problemas de permisos
   sudo chown -R $USER:$USER /opt/chatwoot
   ```

3. **Limpiar espacios
   ```bash
   sudo apt-get autoremove
   sudo apt-get clean
   ```

4. **Actualizar todo**
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   gem update --system
   pnpm update -g
   ```

---

## 📚 Documentación

Guía general: `/opt/chatwoot/SETUP.md`
Makefile: `/opt/chatwoot/Makefile`
Custom CSS Docs: `/opt/chatwoot/docs/plans/001-20241116-custom-css-widget/`

---

## 🎉 ¡Listo!

Ejecuta:
```bash
make run
```

¡Happy coding! 🚀

