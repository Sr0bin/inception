# User documentation

## Services provided

| Service     | What it does                                              |
|-------------|-----------------------------------------------------------|
| nginx       | Web server, the only entrypoint, HTTPS on port 443        |
| wordpress   | The WordPress website (PHP executed by php-fpm)           |
| mariadb     | Database storing posts, users and settings                |

## Start and stop

From the root of the repository:

```sh
make          # build (first time) and start everything
make stop     # stop the containers
make start    # start them again
make down     # remove the containers (website data is kept)
```

## Access the website

1. Make sure the domain points to your machine (once):
   `echo "127.0.0.1 rorollin.42.fr" | sudo tee -a /etc/hosts`
2. Website: <https://rorollin.42.fr>
3. Administration panel: <https://rorollin.42.fr/wp-admin>

The certificate is self-signed: the browser shows a warning, accept it.
Plain HTTP (port 80) is not served.

## Credentials

All passwords are in the `secrets/` folder at the root (never committed to git).
They are generated randomly by `make` on the first run:

| File                          | Content                                    |
|-------------------------------|--------------------------------------------|
| `secrets/credentials.txt`     | `WP_ADMIN_PASSWORD`, `WP_USER_PASSWORD`    |
| `secrets/db_password.txt`     | password of the WordPress database user    |
| `secrets/db_root_password.txt`| MariaDB root password                      |

User names are in `srcs/.env`: administrator `WP_ADMIN_USER` (rorollin),
author `WP_USER` (writer), database user `MYSQL_USER`.

To change a password, edit the file **before the first `make`**, or run
`make fclean && make` (this deletes the site data).

## Check that everything runs

```sh
make ps                                   # 3 containers "Up", mariadb "healthy"
make logs                                 # live logs of all services
curl -k https://rorollin.42.fr            # returns the WordPress HTML
```
