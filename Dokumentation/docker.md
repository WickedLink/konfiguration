# Docker Nextcloud
Ordner anlegen
```
mkdir -p /opt/containers/nextcloud/{database,app,daten}`
```
docker-compose.yml anlegen
```
cd /opt/containers/nextcloud/
vim docker-compose.yml
```
Inhalt der docker-compose.yml
```
version: '3.3'

services:
  nextcloud-db:
    image: mariadb
    container_name: nextcloud-db
    command: – transaction-isolation=READ-COMMITTED – log-bin=ROW
    command: – innodb_read_only_compressed=OFF
    restart: unless-stopped
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /opt/containers/nextcloud/database:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=test #SQL root Passwort eingeben
      - MYSQL_PASSWORD=test #SQL Benutzer Passwort eingeben
      - MYSQL_DATABASE=nextcloud #Datenbank Name
      - MYSQL_USER=nextcloud #SQL Nutzername
      - MYSQL_INITDB_SKIP_TZINFO=1 
    networks:
      - default

  nextcloud-redis:
    image: redis:alpine
    container_name: nextcloud-redis
    hostname: nextcloud-redis
    networks:
        - default
    restart: unless-stopped
    command: redis-server – requirepass test # Redis Passwort eingeben

  nextcloud-app:
    image: nextcloud
    container_name: nextcloud-app
    restart: unless-stopped
    depends_on:
      - nextcloud-db
      - nextcloud-redis
    environment:
        REDIS_HOST: nextcloud-redis
        REDIS_HOST_PASSWORD: test # Redis Passwort von oben wieder eingeben
    volumes:
      - /opt/containers/nextcloud/app:/var/www/html
      - /opt/containers/nextcloud/daten:/var/www/html/data

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nextcloud-app.entrypoints=http"
      - "traefik.http.routers.nextcloud-app.rule=Host(`nextcloud.euredomain.de`)"
      - "traefik.http.middlewares.nextcloud-app-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.nextcloud-app.middlewares=nextcloud-app-https-redirect"
      - "traefik.http.routers.nextcloud-app-secure.entrypoints=https"
      - "traefik.http.routers.nextcloud-app-secure.rule=Host(`nextcloud.euredomain.de`)"
      - "traefik.http.routers.nextcloud-app-secure.tls=true"
      - "traefik.http.routers.nextcloud-app-secure.tls.certresolver=http"
      - "traefik.http.routers.nextcloud-app-secure.service=nextcloud-app"
      - "traefik.http.services.nextcloud-app.loadbalancer.server.port=80"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.nextcloud-app-secure.middlewares=nextcloud-dav,secHeaders@file"
      - "traefik.http.middlewares.nextcloud-dav.replacepathregex.regex=^/.well-known/ca(l|rd)dav"
      - "traefik.http.middlewares.nextcloud-dav.replacepathregex.replacement=/remote.php/dav/"
    networks:
      - proxy
      - default

networks:
  proxy:
    external: true
```
Nextcloud Server starten
```
docker-compose -f /opt/containers/nextcloud/docker-compose.yml up -d
```
Standard Telefon Region einstellen
```
vim /opt/containers/nextcloud/app/config/config.php
```
folgende Zeile hinzufuegen
```
 'default_phone_region' => 'DE',
```
IP des Reverse-Proxy herausfinden
```
docker inspect traefik
```
Die Werte `„IPAddress“:` und `„IPPrefixLen“:` sind entscheidend

diese Werte in die Nextcloud config.php einfuegen
```
vim /opt/containers/nextcloud/app/config/config.php
```
diese Zeile einfuegen
```
'trusted_proxies' => '172.18.1.3/16',
```
wobei hier 172.18.1.3 `„IPAddress“:` ist

und 16 `„IPPrefixLen“:`

Nextcloud auf HTTPS umstellen
```
vim /opt/containers/nextcloud/app/config/config.php
```
Zeile aendern
von
```
 'overwrite.cli.url' => 'http://nextcloud.euredomain.de',
```
in
```
 'overwrite.cli.url' => 'https://nextcloud.euredomain.de',
```
diese Zeilen hinzufuegen
```
  'overwriteprotocol' => 'https',
  'overwritehost' => 'nextcloud.euredomain.de',
```
anschliessend den Container neu starten
