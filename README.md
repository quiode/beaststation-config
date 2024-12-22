# Beaststation Configuration

This repository contains all configuration files (and thus all specification) for my server (*beaststation*).

The server itself runs on NixOS which is configured inside `nix`. The `README.md` there should explain everything. Secrets (passwords and such) are stored inside `secrets`. The `README.md` there also should explain most.

The actual services are all run inside docker containers. Their setup is specified with the docker compose files inside `compose` (see again the `README.md`).

All data is stored on raid devices and the most critical data is also being backuped on an external server.
