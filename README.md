# beaststation-docker-compose

Docker compose files for my server (Beaststation).

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
- `BW_INSTALLATION_ID`
  - get from <https://bitwarden.com/host/>
- `BW_INSTALLATION_KEY`
  - get from <https://bitwarden.com/host/>
- `SCHWAIGER_ADMIN_PASSWORD`
  - password to enter admin panel of <https://dominik-schwaiger.ch>
- `GITLAB_SMTP_PASSWORD`
  - email password for gitlab
- `REGISTRY_HTTP_SECRET`
  - http secret for docker registry

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
- `/mnt/raid5/traefik/auth`
- `/mnt/raid5/traefik/acme`
- `/mnt/raid5/jellyfin/config`
- `/mnt/raid5/jellyfin/cache`
- `/mnt/raid5/jellyfin/media`
- `/etc/environment/`
- `/var/run/docker.sock`

## Symlinks

Files and folder that have/should be linked from the persistent storage.

- `/etc/environment`
- `/home/$USER/.ssh`

## Ports

- 80 (proxy)
- 443 (proxy)
- 25565 (Minecraft)
- 1194 (OpenVPN)
- 22 (Gitlab) (host ssh port has to be changed -> currently set to 2222)

## Hosts (`/etc/hosts`)

Create an entry for `registry.dominik-schwaiger` mapping to `localhost` (probably *127.0.0.1*), sucht that the self hosted docker registry works fine with docker inside the server.
