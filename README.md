# beaststation-docker-compose

Docker compose files for my server (Beaststation).

## Required Environment Variables

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

## Volumes

- `/mnt/raid5/openvpn`
- `/mnt/raid5/nextcloud/data`
- `/mnt/raid5/nextcloud/apps`
- `/mnt/raid5/nextcloud/config`
- `/mnt/raid5/nextcloud/themes`
- `/mnt/raid5/nextcloud/database`
- `/mnt/raid5/minecraft/server`
- `/mnt/raid5/portainer/data`
- `/mnt/raid5/bitwarden/data`
- `/mnt/raid5/bitwarden/database`
- `/mnt/raid5/bitwarden/logs`
- `/var/run/docker.sock`
- `/home/domina/beaststation-docker-compose/proxy/nginx_config`
- `/home/domina/beaststation-docker-compose`
- `/home/domina/.ssh`

## Ports

- 80
- 443
- 25565
- 1194
