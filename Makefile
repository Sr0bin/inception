NAME		= inception
COMPOSE		= docker compose -f srcs/docker-compose.yml -p $(NAME)
DATA_DIR	= /home/rorollin/data
SECRETS		= secrets/db_password.txt secrets/db_root_password.txt secrets/credentials.txt

all: up

up: $(SECRETS)
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

secrets/db_password.txt secrets/db_root_password.txt:
	mkdir -p secrets
	openssl rand -hex 16 > $@
	#echo "CHANGEME"

secrets/credentials.txt:
	mkdir -p secrets
	echo "WP_ADMIN_PASSWORD=$$(openssl rand -hex 16)" > $@
	echo "WP_USER_PASSWORD=$$(openssl rand -hex 16)" >> $@
	#echo "WP_ADMIN_PASSWORD=CHANGEME" > $@
	#echo "WP_USER_PASSWORD=CHANGEME" >> $@

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean: down

fclean:
	$(COMPOSE) down -v --rmi all
	docker run --rm -v $(DATA_DIR):/data debian:bookworm rm -rf /data/mariadb /data/wordpress
	rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all up down stop start ps logs clean fclean re
