#!/bin/bash

################################################################################
# Chatwoot Fork Synchronization Script
# 
# Sincroniza cambios del repositorio original de Chatwoot (upstream)
# a tu rama develop, y luego a production.
#
# Uso:
#   ./sync-upstream.sh              # Sync normal
#   ./sync-upstream.sh --restart    # Sync + reiniciar servicios
#   ./sync-upstream.sh --backup     # Sync + crear backup
#
# Autor: SDM Chatwoot
# Versión: 1.0
################################################################################

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
REPO_DIR="/opt/chatwoot"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/tmp/chatwoot-sync-${TIMESTAMP}.log"
RESTART=false
BACKUP=false

# Funciones
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "${BLUE}" | tee -a "$LOG_FILE"
    echo "════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
    echo "   Chatwoot Upstream Sync Script" | tee -a "$LOG_FILE"
    echo "════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

print_footer() {
    echo -e "${BLUE}" | tee -a "$LOG_FILE"
    echo "════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
    echo "   Sync Completed" | tee -a "$LOG_FILE"
    echo "════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
    echo -e "${NC}" | tee -a "$LOG_FILE"
}

# Verificar que estamos en el directorio correcto
check_directory() {
    if [ ! -d "$REPO_DIR/.git" ]; then
        log_error "No estamos en un repositorio git válido"
        log_error "Esperado: $REPO_DIR"
        exit 1
    fi
    log_success "Repositorio encontrado en: $REPO_DIR"
}

# Crear backup si se pide
create_backup() {
    log_info "Creando backup de production..."
    cd "$REPO_DIR"
    
    BACKUP_BRANCH="backup/production-${TIMESTAMP}"
    git branch "$BACKUP_BRANCH"
    log_success "Backup creado: $BACKUP_BRANCH"
}

# Traer cambios de upstream
fetch_upstream() {
    log_info "Trayendo cambios de upstream..."
    cd "$REPO_DIR"
    
    if ! git fetch upstream 2>&1 | tee -a "$LOG_FILE"; then
        log_error "Fallo al traer cambios de upstream"
        exit 1
    fi
    
    log_success "Cambios traídos del upstream"
}

# Ver cambios disponibles
show_changes() {
    log_info "Cambios disponibles en upstream/develop:"
    cd "$REPO_DIR"
    
    local changes_count=$(git log --oneline develop..upstream/develop 2>/dev/null | wc -l)
    
    if [ "$changes_count" -eq 0 ]; then
        log_warn "No hay cambios nuevos en upstream"
        return 0
    fi
    
    echo "" | tee -a "$LOG_FILE"
    echo "Commits nuevos:" | tee -a "$LOG_FILE"
    git log --oneline develop..upstream/develop 2>/dev/null | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    echo "Archivos modificados:" | tee -a "$LOG_FILE"
    git diff develop upstream/develop --stat 2>/dev/null | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Mergear a develop
merge_to_develop() {
    log_info "Mergeando cambios a develop..."
    cd "$REPO_DIR"
    
    git checkout develop 2>&1 | tee -a "$LOG_FILE"
    
    if ! git merge upstream/develop 2>&1 | tee -a "$LOG_FILE"; then
        log_error "Conflicto durante merge a develop"
        log_warn "Por favor, resuelve los conflictos manualmente:"
        log_warn "  git status"
        log_warn "  # Editar archivos con conflicto"
        log_warn "  git add ."
        log_warn "  git commit"
        exit 1
    fi
    
    log_success "Merge a develop completado"
}

# Pushear develop
push_develop() {
    log_info "Pusheando develop a origin..."
    cd "$REPO_DIR"
    
    if ! git push origin develop 2>&1 | tee -a "$LOG_FILE"; then
        log_error "Fallo al pushear develop"
        exit 1
    fi
    
    log_success "develop pusheado a origin"
}

# Mergear a production
merge_to_production() {
    log_info "Mergeando a production..."
    cd "$REPO_DIR"
    
    git checkout production 2>&1 | tee -a "$LOG_FILE"
    
    if ! git merge develop 2>&1 | tee -a "$LOG_FILE"; then
        log_error "Conflicto durante merge a production"
        log_warn "Por favor, resuelve los conflictos manualmente:"
        log_warn "  git status"
        log_warn "  # Editar archivos con conflicto"
        log_warn "  git add ."
        log_warn "  git commit"
        exit 1
    fi
    
    log_success "Merge a production completado"
}

# Pushear production
push_production() {
    log_info "Pusheando production a origin..."
    cd "$REPO_DIR"
    
    if ! git push origin production 2>&1 | tee -a "$LOG_FILE"; then
        log_error "Fallo al pushear production"
        exit 1
    fi
    
    log_success "production pusheado a origin"
}

# Pullear cambios locales
pull_production() {
    log_info "Trayendo cambios de production..."
    cd "$REPO_DIR"
    
    if ! git pull origin production 2>&1 | tee -a "$LOG_FILE"; then
        log_error "Fallo al traer cambios de production"
        exit 1
    fi
    
    log_success "Cambios de production traídos"
}

# Reiniciar servicios
restart_services() {
    log_info "Reiniciando servicios de Chatwoot..."
    cd "$REPO_DIR"
    
    if ! make restart 2>&1 | tee -a "$LOG_FILE"; then
        log_warn "Fallo al reiniciar servicios con make"
        log_info "Intentando con docker compose..."
        
        if ! docker compose -f docker-compose.production.yaml restart 2>&1 | tee -a "$LOG_FILE"; then
            log_error "Fallo al reiniciar servicios"
            exit 1
        fi
    fi
    
    log_success "Servicios reiniciados"
    
    # Esperar a que se estabilicen
    sleep 10
    
    log_info "Verificando estado de servicios..."
    docker compose -f docker-compose.production.yaml ps 2>&1 | tee -a "$LOG_FILE"
}

# Mostrar status final
show_status() {
    log_info "Status final:"
    cd "$REPO_DIR"
    
    echo "" | tee -a "$LOG_FILE"
    echo "Rama actual:" | tee -a "$LOG_FILE"
    git branch --show-current | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    echo "Últimos commits en production:" | tee -a "$LOG_FILE"
    git log --oneline -5 production | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    echo "Estado de git:" | tee -a "$LOG_FILE"
    git status | tee -a "$LOG_FILE"
}

# Main
main() {
    print_header
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --restart)
                RESTART=true
                shift
                ;;
            --backup)
                BACKUP=true
                shift
                ;;
            *)
                log_warn "Argumento desconocido: $1"
                shift
                ;;
        esac
    done
    
    log_info "Log guardado en: $LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    # Ejecutar pasos
    check_directory
    
    if [ "$BACKUP" = true ]; then
        create_backup
    fi
    
    fetch_upstream
    show_changes
    merge_to_develop
    push_develop
    merge_to_production
    push_production
    pull_production
    
    if [ "$RESTART" = true ]; then
        restart_services
    fi
    
    show_status
    print_footer
    
    log_success "Sincronización completada!"
    echo "" | tee -a "$LOG_FILE"
    
    if [ "$RESTART" = false ]; then
        log_info "Para reiniciar servicios, ejecuta: make restart"
    fi
}

# Ejecutar
main "$@"

