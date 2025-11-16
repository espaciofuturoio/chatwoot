.PHONY: help up down logs restart db-prepare shell status ps

COMPOSE := docker compose -f docker-compose.production.yaml
COMPOSE_EXEC := $(COMPOSE) exec -it rails

help:
	@echo "Chatwoot Production Docker Commands"
	@echo ""
	@echo "Usage: make [command]"
	@echo ""
	@echo "Commands:"
	@echo "  make up                - Start all services"
	@echo "  make down              - Stop all services"
	@echo "  make down-volumes      - Stop services and remove volumes"
	@echo "  make restart           - Restart all services"
	@echo "  make logs              - View logs from all services"
	@echo "  make logs-rails        - View Rails logs"
	@echo "  make logs-redis        - View Redis logs"
	@echo "  make logs-postgres     - View PostgreSQL logs"
	@echo "  make db-prepare        - Prepare database (initial setup/migrations)"
	@echo "  make shell             - Open Rails console"
	@echo "  make status            - Show services status"
	@echo "  make ps                - Show running containers"
	@echo ""

up:
	$(COMPOSE) up -d
	@echo "✅ Chatwoot services started"

down:
	$(COMPOSE) down
	@echo "✅ Chatwoot services stopped"

down-volumes:
	$(COMPOSE) down -v
	@echo "✅ Chatwoot services stopped and volumes removed"

restart: down up
	@echo "✅ Chatwoot services restarted"

logs:
	$(COMPOSE) logs -f

logs-rails:
	$(COMPOSE) logs -f rails

logs-redis:
	$(COMPOSE) logs -f redis

logs-postgres:
	$(COMPOSE) logs -f postgres

db-prepare:
	$(COMPOSE) run --rm rails bundle exec rails db:chatwoot_prepare
	@echo "✅ Database prepared"

shell:
	$(COMPOSE_EXEC) bash -c 'RAILS_ENV=production bundle exec rails c'

status:
	$(COMPOSE) ps

ps:
	docker ps | grep chatwoot

test-connection:
	curl -I http://localhost:3000/api
	@echo ""
	@echo "✅ Connection test complete"

