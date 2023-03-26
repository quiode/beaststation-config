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
  - password for mail@nextcloud.dominik-schwaiger.ch

## Volumes

- `/mnt/raid5/openvpn`
- `/mnt/raid5/nextcloud/data`
- `/mnt/raid5/nextcloud/apps`
- `/mnt/raid5/nextcloud/config`
- `/mnt/raid5/nextcloud/themes`
- `/mnt/raid5/nextcloud/database`
- `/mnt/raid5/minecraft/server`
- `/mnt/raid5/focalboard`
- `/mnt/raid5/website_chris/database`
- `/mnt/raid5/website_chris/data`

## Ports

- 80
- 443
- 25565
- 1194
