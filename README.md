# beaststation-docker-compose

Docker compose files for my server (Beaststation).

Assumption: User is named `domina` and this repository is cloned directly inside the home directory.

## Required Environment Variables

These should be written inside `/etc/environment`.

- `DOCKER_PW`
  - password for docker repo
- `TELEGRAM_WATCHTOWER_TOKEN`
  - telegram token for watchtower bot
- `DB_PW`
  - password for databases
- `NEXTCLOUD_ADMIN_PASSWORD`
  - admin password for nextcloud
- `NEXTCLOUD_SMTP_PASSWORD`
  - password for <mail@nextcloud.dominik-schwaiger.ch>
- `JWT_SECRET`
  - secret for jwt's (onlyoffice)
- `WEBHOOK_SECRET`
  - github webhook secreto for compose-watcher
- `WATCHER_TELEGRAM_TOKEN`
  - telegram token for compose-watcher telegram bot
- `WATCHER_CHAT_ID`
  - chat id for compose watcher
- `BW_INSTALLATION_ID`
  - get from <https://bitwarden.com/host/>
- `BW_INSTALLATION_KEY`
  - get from <https://bitwarden.com/host/>
- `SCHWAIGER_ADMIN_PASSWORD`
  - password to enter admin panel of <https://dominik-schwaiger.ch>
- `GITLAB_SMTP_PASSWORD`
  - email password for gitlab

## Bind Volumes

- `/mnt/raid5/openvpn`
- `/mnt/raid5/nextcloud/data`
- `/mnt/raid5/nextcloud/apps`
- `/mnt/raid5/nextcloud/config`
- `/mnt/raid5/nextcloud/themes`
- `/mnt/raid5/nextcloud/database`
- `/mnt/raid5/minecraft/server`
- `/mnt/raid5/minecraft/backups`
- `/mnt/raid5/portainer/data`
- `/mnt/raid5/bitwarden/data`
- `/mnt/raid5/bitwarden/database`
- `/mnt/raid5/bitwarden/logs`
- `/mnt/raid5/dominik-schwaiger.ch/images`
- `/mnt/raid5/gitlab/runner/config`
- `/mnt/raid5/gitlab/logs`
- `/mnt/raid5/gitlab/config`
- `/mnt/raid5/gitlab/data`
- `/mnt/raid5/registry/data`
- `/mnt/raid5/registry/auth`
- `/var/run/docker.sock`
- `/home/domina/beaststation-docker-compose/proxy/nginx_config`
- `/home/domina/beaststation-docker-compose`
- `/home/domina/.ssh`

## Ports

- 80 (nginx)
- 443 (nginx)
- 25565 (Minecraft)
- 1194 (OpenVPN)
- 22 (Gitlab)

## Hosts (`/etc/hosts`)

Create an entry for `registry.dominik-schwaiger` mapping to `localhost` (probably *127.0.0.1*), sucht that the self hosted docker registry works fine with docker inside the server.
