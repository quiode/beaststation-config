# docker compose configuration

Docker compose files for my server (Beaststation).

## Required Secrets

These should mounted to `/run/agenix`.
They should each define a set of environment variables and then are mounted as environment files.

### Format

- `secret_name` in `/run/agenix/secret_name`

  - `ENV` environemnt variable defined in the secret
    - description

  `other env vars that depend on above env vars`

### Secrets

- `docker_pw`
  - `REPO_PASSWORD`
    - password for docker repo
- `telegram_watchtower_token`
  - `WATCHTOWER_NOTIFICATION_URL`
    - telegram url (token) for watchtower bot
- `db_pw`

  - `DB_PW`
    - password for databases

  ```bash
  MYSQL_PASSWORD="${DB_PW}"
  MARIADB_ROOT_PASSWORD="${DB_PW}"
  MARIADB_PASSWORD="${DB_PW}"
  POSTGRES_PASSWORD="${DB_PW}"
  ```

- `nextcloud_admin_password`
  - `NEXTCLOUD_ADMIN_PASSWORD`
    - admin password for nextcloud
- `nextcloud_smtp_password`

  - `NEXTCLOUD_SMTP_PASSWORD`
    - password for <mail@nextcloud.dominik-schwaiger.ch>

  `globalSettings__mail__smtp__password="${SMTP_PASSWORD}"`

- `jwt_secret`
  - `JWT_SECRET`
    - secret for jwt's (onlyoffice)
- `bw_installation_id`
  - `BW_INSTALLATION_ID`
    - get from <https://bitwarden.com/host/>
- `bw_installation_key`
  - `BW_INSTALLATION_KEY`
    - get from <https://bitwarden.com/host/>
- `schwaiger_admin_password`
  - `SCHWAIGER_ADMIN_PASSWORD`
    - password to enter admin panel of <https://dominik-schwaiger.ch>
- `gitlab_smtp_password`
  - `GITLAB_SMTP_PASSWORD`
    - email password for gitlab
- `registry_http_secret`
  - `REGISTRY_HTTP_SECRET`
    - http secret for docker registry
- `immich_db_pw`

  - `DB_PASSWORD`
    - password for immich db

  `POSTGRES_PASSWORD="${DB_PASSWORD}"`

## Bind Volumes

Critical data (which should be snapshotted more often and also should be backuped) is always saved under `pool/critical` while non-critical stuff is saved under `pool/non-critical`. There are two pools, `hdd` and `ssd`. Their names should make it clear which one is where. Big data or data which doesn't have to be accessed for a long time should be on the hdd while small data or data that has to be accessed often should be saved on the ssd.

### Data

- `/ssd/critical/openvpn`
- `/ssd/critical/nextcloud/html`
- `/hdd/critical/nextcloud/data`
- `/ssd/critical/nextcloud/apps`
- `/ssd/critical/nextcloud/config`
- `/ssd/critical/nextcloud/themes`
- `/ssd/critical/nextcloud/database`
- `/ssd/critical/minecraft/server`
- `/hdd/non-critical/minecraft/backups`
- `/ssd/critical/portainer/data`
- `/ssd/critical/bitwarden/data`
- `/ssd/critical/bitwarden/database`
- `/hdd/non-critical/bitwarden/logs`
- `/hdd/non-critical/dominik-schwaiger.ch/images`
- `/ssd/critical/gitlab/runner/config`
- `/hdd/non-critical/gitlab/logs`
- `/ssd/critical/gitlab/config`
- `/hdd/critical/gitlab/data`
- `/hdd/non-critical/registry/data`
- `/ssd/critical/registry/auth`
- `/ssd/critical/traefik/auth`
- `/ssd/non-critical/traefik/acme.json`
- `/ssd/critical/jellyfin/config`
- `/hdd/non-critical/jellyfin/media`
- `/ssd/critical/qbittorrent/appdata`
- `/hdd/non-critical/qbittorrent/downloads`
- `/ssd/critical/immich/database`
- `/hdd/non-critical/immich/data`
- `/hdd/critical/immich/data/library`
- `/hdd/critical/immich/data/upload`
- `/hdd/critical/immich/data/profile`
- `/hdd/non-critical/ollama`
- `/hdd/critical/open-webui`
- `/ssd/non-critical/open-webui/cache`
- `/ssd/critical/mailserver/mail-data`
- `/ssd/critical/mailserver/config`
- `/ssd/critical/home-assistant/config`
- `/hdd/critical/home-assistant/backups`
- `/ssd/critical/home-assistant/esphome`
- `/hdd/critical/matrix/data/media`
- `/ssd/critical/matrix/data`
- `/ssd/critical/matrix/db`

### Other

- `/run/agenix/`
- `/var/run/docker.sock`

## Ports

- 80 (proxy)
- 443 (proxy)
- 25565 (Minecraft)
- 1194 (OpenVPN)
- 22 (Gitlab) (host ssh port has to be changed -> currently set to 2222)
