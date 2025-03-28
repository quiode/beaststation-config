# docker compose configuration

Docker compose files for my server (Beaststation).

## Location

These should be saved to `/ssd/critical/service/secrets.env` for each service and mounted as env files.

## Secrets

- **Watchtower**
  - `REPO_PASSWORD`
    - password for docker repo
  - `WATCHTOWER_NOTIFICATION_URL`
    - telegram url (token) for watchtower bot
- **Common Database Secret**
  - `DB_PW`
    - password for databases
  ```bash
  MYSQL_PASSWORD="${DB_PW}"
  MARIADB_ROOT_PASSWORD="${DB_PW}"
  MARIADB_PASSWORD="${DB_PW}"
  POSTGRES_PASSWORD="${DB_PW}"
  ```
- **Nextcloud**
  - `NEXTCLOUD_ADMIN_PASSWORD`
    - admin password for nextcloud

  - `SMTP_PASSWORD`
    - password for <mail@nextcloud.dominik-schwaiger.ch>
      `NEXTCLOUD_SMTP_PASSWORD="${SMTP_PASSWORD}"`
      `globalSettings__mail__smtp__password="${SMTP_PASSWORD}"`
- **Only Office**
  - `JWT_SECRET`
    - secret for jwt's (onlyoffice)
- **Bitwarden**
  - `BW_INSTALLATION_ID`
    - get from <https://bitwarden.com/host/>
  - `BW_INSTALLATION_KEY`
    - get from <https://bitwarden.com/host/>
- **Personal Website**
  - `SCHWAIGER_ADMIN_PASSWORD`
    - password to enter admin panel of <https://dominik-schwaiger.ch>
- **Gitlab**
  - `GITLAB_SMTP_PASSWORD`
    - email password for gitlab
  - `OIDC_CLIENT_SECRET`
    - authentik
  - `OIDC_CLIENT_SECRET`
    - authentik
- **Immich**
  - `DB_PASSWORD`
    - password for immich db
      `POSTGRES_PASSWORD="${DB_PASSWORD}"`
- **Authentik**
  - `AUTHENTIK_EMAIL__PASSWORD`
  - `POSTGRES_PASSWORD`
  - `AUTHENTIK_POSTGRESQL__PASSWORD`
- **Open WebUI**
  - `OAUTH_CLIENT_ID`
  - `OAUTH_CLIENT_SECRET`

## Bind Volumes

Critical data (which should be snapshotted more often and also should be backed up) is always saved under `pool/critical` while non-critical stuff is saved under `pool/non-critical`. There are two pools, `hdd` and `ssd`. Their names should make it clear which one is where. Big data or data which doesn't have to be accessed for a long time should be on the hdd while small data or data that has to be accessed often should be saved on the ssd.

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
- `/ssd/critical/bitwarden/data`
- `/ssd/critical/bitwarden/database`
- `/hdd/non-critical/bitwarden/logs`
- `/hdd/non-critical/dominik-schwaiger.ch/images`
- `/ssd/critical/gitlab/runner/config`
- `/hdd/non-critical/gitlab/logs`
- `/ssd/critical/gitlab/config`
- `/hdd/critical/gitlab/data`
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
- `/ssd/critical/authentik/database`
- `/ssd/critical/authentik/media`
- `/ssd/critical/authentik/certs`
- `/ssd/critical/authentik/custom-templates`

### Other

- `/var/run/docker.sock`

## Ports

- 80 (proxy)
- 443 (proxy)
- 25565 (Minecraft)
- 1194 (OpenVPN)
- 22 (Gitlab) (host ssh port has to be changed -> currently set to 2222)
- 389 (LDAP Authentik)
- 636 (LDAP Authentik)
