#!/bin/bash

# ============================================================================
# Chatwoot Development Environment Setup - Ubuntu 24.04 LTS
# ============================================================================
# Este script configura automáticamente el ambiente completo de desarrollo
# para Chatwoot en Ubuntu 24.04.3 LTS
# ============================================================================

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Chatwoot Setup - Ubuntu 24.04 LTS                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
print_header() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# ============================================================================
# Step 1: Verify Ubuntu
# ============================================================================

print_header "Verificando sistema..."

if ! grep -qi "ubuntu" /etc/os-release; then
    print_error "Este script es para Ubuntu. Tu sistema no parece ser Ubuntu."
    exit 1
fi

UBUNTU_VERSION=$(grep 'PRETTY_NAME' /etc/os-release | cut -d'"' -f2)
print_success "Sistema detectado: $UBUNTU_VERSION"

# ============================================================================
# Step 2: Update System
# ============================================================================

print_header "Actualizando sistema..."
sudo apt-get update
print_success "Sistema actualizado"

# ============================================================================
# Step 3: Install Ruby
# ============================================================================

print_header "Instalando Ruby..."

if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby -v)
    print_success "Ruby ya está instalado: $RUBY_VERSION"
else
    print_warning "Instalando Ruby..."
    sudo apt-get install -y ruby-full build-essential libssl-dev libreadline-dev zlib1g-dev git curl wget
    print_success "Ruby instalado"
fi

# Verificar Bundler
if ! command -v bundle &> /dev/null; then
    print_warning "Instalando Bundler..."
    sudo gem install bundler
    print_success "Bundler instalado"
else
    print_success "Bundler ya está instalado"
fi

# ============================================================================
# Step 4: Install Node.js with NVM (Recommended)
# ============================================================================

print_header "Instalando Node.js con NVM..."

# Check if NVM is installed
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    print_success "NVM ya está instalado"
else
    print_warning "Instalando NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    print_success "NVM instalado"
fi

# Load NVM in this shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 25 (Latest)
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    print_success "Node.js ya está instalado: $NODE_VERSION"
else
    print_warning "Instalando Node.js 25..."
    nvm install 25
    nvm use 25
    print_success "Node.js 25 instalado"
fi

# ============================================================================
# Step 5: Install pnpm with Corepack
# ============================================================================

print_header "Instalando pnpm..."

if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm -v)
    print_success "pnpm ya está instalado: $PNPM_VERSION"
else
    print_warning "Instalando pnpm con corepack..."
    npm install -g corepack
    corepack enable pnpm
    print_success "pnpm instalado"
fi

# ============================================================================
# Step 6: Install PostgreSQL
# ============================================================================

print_header "Configurando PostgreSQL..."

if command -v psql &> /dev/null; then
    PG_VERSION=$(psql -V)
    print_success "PostgreSQL ya está instalado: $PG_VERSION"
else
    print_warning "Instalando PostgreSQL..."
    sudo apt-get install -y postgresql postgresql-contrib libpq-dev
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    print_success "PostgreSQL instalado e iniciado"
fi

# ============================================================================
# Step 7: Install Redis
# ============================================================================

print_header "Configurando Redis..."

if command -v redis-cli &> /dev/null; then
    REDIS_VERSION=$(redis-cli --version)
    print_success "Redis ya está instalado: $REDIS_VERSION"
else
    print_warning "Instalando Redis..."
    sudo apt-get install -y redis-server
    sudo systemctl start redis-server
    sudo systemctl enable redis-server
    print_success "Redis instalado e iniciado"
fi

# Verificar que Redis está corriendo
if ! redis-cli ping &> /dev/null; then
    print_warning "Iniciando Redis..."
    sudo systemctl restart redis-server
fi

# ============================================================================
# Step 8: Install Overmind
# ============================================================================

print_header "Configurando Overmind..."

if command -v overmind &> /dev/null; then
    OVERMIND_VERSION=$(overmind --version)
    print_success "Overmind ya está instalado: $OVERMIND_VERSION"
else
    print_warning "Descargando e instalando Overmind..."
    
    VERSION=$(curl -s https://api.github.com/repos/DarthSim/overmind/releases/latest | grep 'tag_name' | cut -d'"' -f4)
    
    curl -L -o /tmp/overmind.gz https://github.com/DarthSim/overmind/releases/download/$VERSION/overmind-$VERSION-linux_amd64.gz
    
    gunzip /tmp/overmind.gz
    sudo mv /tmp/overmind /usr/local/bin/overmind
    sudo chmod +x /usr/local/bin/overmind
    
    print_success "Overmind instalado"
fi

# ============================================================================
# Step 9: Install Project Dependencies
# ============================================================================

print_header "Instalando dependencias del proyecto..."

cd "$(dirname "$0")"

print_header "Instalando gemas Ruby..."
bundle install
print_success "Gemas Ruby instaladas"

print_header "Instalando paquetes Node.js..."
pnpm install
print_success "Paquetes Node.js instalados"

# ============================================================================
# Step 10: Database Setup
# ============================================================================

print_header "Configurando base de datos..."

# Crear usuario PostgreSQL si no existe
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='chatwoot'" | grep -q 1; then
    print_warning "Creando usuario PostgreSQL 'chatwoot'..."
    sudo -u postgres createuser chatwoot -d
    print_success "Usuario PostgreSQL creado"
else
    print_success "Usuario PostgreSQL 'chatwoot' ya existe"
fi

# Setup base de datos
make db
print_success "Base de datos configurada"

# ============================================================================
# Completion
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║            ✅ Setup Completado!                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "✓ Ruby instalado"
echo "✓ Node.js + pnpm instalados"
echo "✓ PostgreSQL instalado y configurado"
echo "✓ Redis instalado y configurado"
echo "✓ Overmind instalado"
echo "✓ Dependencias del proyecto instaladas"
echo "✓ Base de datos configurada"
echo ""
echo "🚀 Próximos pasos:"
echo ""
echo "  1. Iniciar servidor:"
echo "     ${GREEN}make run${NC}"
echo ""
echo "  2. Abrir en navegador:"
echo "     ${BLUE}http://localhost:3000${NC}"
echo ""
echo "  3. Comandos útiles:"
echo "     ${GREEN}make help${NC}       - Ver todos los comandos"
echo "     ${GREEN}make console${NC}    - Abrir Rails console"
echo "     ${GREEN}make logs${NC}       - Ver logs"
echo ""
echo "📚 Documentación:"
echo "   /opt/chatwoot/SETUP-UBUNTU.md"
echo "   /opt/chatwoot/docs/plans/001-20241116-custom-css-widget/"
echo ""
echo "Happy coding! 🚀"
echo ""

