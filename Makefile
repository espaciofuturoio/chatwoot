# Chatwoot Makefile - Local Development & Production
# ==================================================

# Variables
APP_NAME := chatwoot
RAILS_ENV ?= development
COMPOSE := docker compose -f docker-compose.production.yaml
COMPOSE_EXEC := $(COMPOSE) exec -it rails

# Default target
.DEFAULT_GOAL := help

.PHONY: help setup burn db db_create db_migrate db_seed db_reset console server run force_run force_run_tunnel debug debug_worker docker \
        up down down-volumes restart logs logs-rails logs-redis logs-postgres db-prepare shell status ps test-connection \
        docker-build-custom docker-up-custom docker-down-custom docker-logs-custom dev-db-only customcss-help dev-setup test

# ============================================================================
# 🎯 GENERAL HELP
# ============================================================================

help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║        Chatwoot Development & Production Makefile             ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📚 DEVELOPMENT TARGETS:"
	@echo "  make setup              - Install dependencies (Ruby, Node)"
	@echo "  make burn               - Clean reinstall (bundle + pnpm)"
	@echo "  make server             - Start Rails server on 0.0.0.0:3000"
	@echo "  make run                - Start with Overmind (full dev stack)"
	@echo "  make force_run          - Force restart Overmind"
	@echo "  make force_run_tunnel   - Force restart with tunnel"
	@echo "  make console            - Open Rails console"
	@echo "  make debug              - Debug Rails process"
	@echo "  make debug_worker       - Debug worker process"
	@echo ""
	@echo "🗄️  DATABASE TARGETS:"
	@echo "  make db_create          - Create database"
	@echo "  make db_migrate         - Run migrations"
	@echo "  make db_seed            - Seed database"
	@echo "  make db_reset           - Reset database"
	@echo "  make db                 - Run chatwoot_prepare (full setup)"
	@echo ""
	@echo "🐳 PRODUCTION DOCKER TARGETS:"
	@echo "  make up                 - Start all services"
	@echo "  make down               - Stop all services"
	@echo "  make down-volumes       - Stop and remove volumes"
	@echo "  make restart            - Restart all services"
	@echo "  make logs               - View all logs"
	@echo "  make logs-rails         - View Rails logs"
	@echo "  make logs-redis         - View Redis logs"
	@echo "  make logs-postgres      - View PostgreSQL logs"
	@echo "  make db-prepare         - Prepare production database"
	@echo "  make shell              - Open production Rails console"
	@echo "  make status             - Show services status"
	@echo "  make ps                 - Show running containers"
	@echo "  make test-connection    - Test API connection"
	@echo ""
	@echo "🔨 BUILD TARGETS:"
	@echo "  make docker             - Build Docker image"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""

# ============================================================================
# 🚀 DEVELOPMENT TARGETS
# ============================================================================

setup:
	@echo "📦 Installing dependencies..."
	@command -v ruby >/dev/null 2>&1 || { echo "❌ Ruby not found. Install Ruby first."; exit 1; }
	@command -v pnpm >/dev/null 2>&1 || { echo "❌ pnpm not found. Install Node.js first."; exit 1; }
	gem install bundler
	bundle install
	pnpm install
	@echo "✅ Setup complete!"

burn:
	@echo "🔥 Cleaning and reinstalling dependencies..."
	bundle install
	pnpm install
	@echo "✅ Dependencies reinstalled!"

db_create:
	@echo "📝 Creating database..."
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:create
	@echo "✅ Database created!"

db_migrate:
	@echo "📝 Running migrations..."
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:migrate
	@echo "✅ Migrations complete!"

db_seed:
	@echo "🌱 Seeding database..."
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:seed
	@echo "✅ Database seeded!"

db_reset:
	@echo "🔄 Resetting database..."
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:reset
	@echo "✅ Database reset!"

db:
	@echo "🔧 Running chatwoot_prepare..."
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:chatwoot_prepare
	@echo "✅ Database prepared!"

console:
	@echo "💻 Opening Rails console..."
	RAILS_ENV=$(RAILS_ENV) bundle exec rails console

server:
	@echo "🚀 Starting Rails server..."
	RAILS_ENV=$(RAILS_ENV) bundle exec rails server -b 0.0.0.0 -p 3000

run:
	@if [ -f ./.overmind.sock ]; then \
		echo "⚠️  Overmind is already running. Use 'make force_run' to start a new instance."; \
	else \
		echo "🚀 Starting Overmind (full dev stack)..."; \
		overmind start -f Procfile.dev; \
	fi

force_run:
	@echo "🔄 Force restarting Overmind..."
	rm -f ./.overmind.sock
	rm -f tmp/pids/*.pid
	overmind start -f Procfile.dev

force_run_tunnel:
	@echo "🔄 Force restarting Overmind with tunnel..."
	lsof -ti:3000 | xargs kill -9 2>/dev/null || true
	rm -f ./.overmind.sock
	rm -f tmp/pids/*.pid
	overmind start -f Procfile.tunnel

debug:
	@echo "🐛 Connecting to Rails debugger..."
	overmind connect backend

debug_worker:
	@echo "🐛 Connecting to Worker debugger..."
	overmind connect worker

docker:
	@echo "🐳 Building Docker image..."
	docker build -t $(APP_NAME) -f ./docker/Dockerfile .
	@echo "✅ Docker image built!"

# ============================================================================
# 🐳 PRODUCTION DOCKER TARGETS
# ============================================================================

up:
	@echo "🚀 Starting Chatwoot services..."
	$(COMPOSE) up -d
	@echo "✅ Chatwoot services started"

down:
	@echo "🛑 Stopping Chatwoot services..."
	$(COMPOSE) down
	@echo "✅ Chatwoot services stopped"

down-volumes:
	@echo "🛑 Stopping services and removing volumes..."
	$(COMPOSE) down -v
	@echo "✅ Chatwoot services stopped and volumes removed"

restart: down up
	@echo "🔄 Chatwoot services restarted"

logs:
	@echo "📋 Showing all logs..."
	$(COMPOSE) logs -f

logs-rails:
	@echo "📋 Showing Rails logs..."
	$(COMPOSE) logs -f rails

logs-redis:
	@echo "📋 Showing Redis logs..."
	$(COMPOSE) logs -f redis

logs-postgres:
	@echo "📋 Showing PostgreSQL logs..."
	$(COMPOSE) logs -f postgres

db-prepare:
	@echo "🔧 Preparing production database..."
	$(COMPOSE) run --rm rails bundle exec rails db:chatwoot_prepare
	@echo "✅ Database prepared"

shell:
	@echo "💻 Opening production Rails console..."
	$(COMPOSE_EXEC) bash -c 'RAILS_ENV=production bundle exec rails c'

status:
	@echo "📊 Showing services status..."
	$(COMPOSE) ps

ps:
	@echo "📊 Showing Chatwoot containers..."
	docker ps | grep chatwoot

test-connection:
	@echo "🔗 Testing API connection..."
	curl -I http://localhost:3000/api
	@echo ""
	@echo "✅ Connection test complete"

# ============================================================================
# 🔧 UTILITY TARGETS
# ============================================================================

clean:
	@echo "🧹 Cleaning up..."
	rm -rf tmp/
	rm -rf log/
	rm -rf node_modules/
	rm -rf public/packs/
	@echo "✅ Cleanup complete!"

lint:
	@echo "🔍 Running linters..."
	pnpm eslint
	bundle exec rubocop -a
	@echo "✅ Linting complete!"

test:
	@echo "🧪 Running tests..."
	pnpm test
	bundle exec rspec
	@echo "✅ Tests complete!"

dev-setup: setup db db_seed
	@echo "✅ Development environment ready!"
	@echo ""
	@echo "Next steps:"
	@echo "  make run          - Start development server with Overmind"
	@echo "  make server       - Start just Rails server"
	@echo "  make console      - Open Rails console"
	@echo ""

# ============================================================================
# 🎨 CUSTOMCSS DEVELOPMENT
# ============================================================================

docker-build-custom:
	@echo "🐳 Building Docker image with customCSS..."
	docker build -f docker/Dockerfile -t chatwoot/chatwoot:custom-css .
	@echo "✅ Docker image built!"

docker-up-custom:
	@echo "🚀 Starting Docker with customCSS image..."
	docker compose -f docker-compose.custom-css.yaml up -d
	@echo "✅ Services started! Open: http://localhost:3000"
	@echo ""
	@echo "View logs:"
	@echo "  make docker-logs-custom"

docker-down-custom:
	@echo "🛑 Stopping Docker services..."
	docker compose -f docker-compose.custom-css.yaml down
	@echo "✅ Services stopped!"

docker-logs-custom:
	@echo "📋 Viewing customCSS Docker logs..."
	docker compose -f docker-compose.custom-css.yaml logs -f rails

dev-db-only:
	@echo "🚀 Starting only PostgreSQL and Redis (for local dev)..."
	docker compose -f docker-compose.production.yaml up -d postgres redis
	@echo "✅ Database services started!"
	@echo ""
	@echo "Next: make run"

customcss-help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║              🎨 customCSS Development Workflow                 ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📘 QUICK START (Local Development):"
	@echo "  1. make dev-db-only     - Start PostgreSQL + Redis"
	@echo "  2. make run             - Start Chatwoot (in another terminal)"
	@echo "  3. Open: http://localhost:3000"
	@echo "  4. Edit: app/javascript/widget/App.vue"
	@echo "  5. Press F5 in browser → See changes ⚡"
	@echo ""
	@echo "🐳 DOCKER PRODUCTION TEST:"
	@echo "  1. make docker-build-custom   - Build image (~3-5 min)"
	@echo "  2. make docker-up-custom      - Start containers"
	@echo "  3. Open: http://localhost:3000"
	@echo "  4. View logs: make docker-logs-custom"
	@echo "  5. Stop: make docker-down-custom"
	@echo ""
	@echo "📚 Documentation:"
	@echo "  QUICKSTART-CUSTOMCSS.md   - Detailed guide"
	@echo "  CHEATSHEET-CUSTOMCSS.md   - Quick reference"
	@echo ""
	@echo "Files to edit:"
	@echo "  app/javascript/entrypoints/sdk.js"
	@echo "  app/javascript/sdk/IFrameHelper.js"
	@echo "  app/javascript/widget/App.vue"
	@echo ""
