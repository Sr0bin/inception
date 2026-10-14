# Developer documentation

## Set up from scratch

Prerequisites (inside the VM): Docker Engine, Docker Compose plugin
(`docker compose`), `make`, `openssl`.

1. Clone the repository.
2. Add the domain: `echo "127.0.0.1 rorollin.42.fr" | sudo tee -a /etc/hosts`
3. Configuration:
   - `srcs/.env`: non-secret variables (domain, database name, user names, emails).
   - `secrets/*.txt`: passwords. Created automatically with `openssl rand`
     by the Makefile if missing; you can also write them yourself:
     ```
     secrets/db_password.txt       one line: the password
     secrets/db_root_password.txt  one line: the password
     secrets/credentials.txt       WP_ADMIN_PASSWORD=...
                                   WP_USER_PASSWORD=...
     ```
   `secrets/` is in `.gitignore`.

## Build and launch

`make` runs, in order:
1. generation of missing secrets,
2. `mkdir -p /home/rorollin/data/{mariadb,wordpress}` (volume storage),
3. `docker compose -f srcs/docker-compose.yml -p inception up -d --build`.

Startup order: `mariadb` (healthcheck `mysqladmin ping`) → `wordpress`
(waits for mariadb to be healthy, installs WordPress with WP-CLI on first
run) → `nginx`.

## Managing containers and volumes

```sh
make ps / make logs                       # status / logs
docker exec -it wordpress bash            # shell in a container
docker exec wordpress wp user list --allow-root
docker exec -it mariadb sh -c 'mysql -uroot -p$(cat /run/secrets/db_root_password)'
docker volume ls                          # inception_mariadb, inception_wordpress
docker volume inspect inception_mariadb   # device: /home/rorollin/data/mariadb
docker network inspect inception_inception
make down        # remove containers + network
make fclean      # also remove images, volumes and /home/rorollin/data
make re          # full rebuild from zero
```

## Where data is stored and how it persists

| Volume                | Mounted at (container) | Stored on host                  |
|-----------------------|------------------------|---------------------------------|
| `inception_mariadb`   | `/var/lib/mysql`       | `/home/rorollin/data/mariadb`   |
| `inception_wordpress` | `/var/www/html` (wordpress + nginx) | `/home/rorollin/data/wordpress` |

They are named volumes (`local` driver with `driver_opts: type none, o bind`),
so the data survives `make down`, `make stop` and reboots. Only `make fclean`
deletes it. On first start Docker copies the
image's MariaDB system tables into the empty `mariadb` volume
(`mysql_install_db` only runs if they are missing), and the init SQL is
re-applied on every start without duplicating anything. The WordPress
entrypoint only runs the setup steps that are missing. Existing data is
therefore reused as-is on the next start.

## Layout

```
Makefile
secrets/                      git-ignored passwords
srcs/.env                     non-secret variables
srcs/docker-compose.yml
srcs/requirements/
├── mariadb/   Dockerfile, conf/50-server.cnf, tools/entrypoint.sh
├── nginx/     Dockerfile, conf/nginx.conf
└── wordpress/ Dockerfile, conf/www.conf, tools/entrypoint.sh
```
