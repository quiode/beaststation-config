#!/usr/bin/env bash
# Executes compose down for all
for dir in */; do [ -f "$dir/docker-compose.yml" ] && (cd "$dir" && sudo docker compose down); done
