let
  users = [ ];

  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWkILtyyPWk4UYWJaZoI5UqGKo/qlaJG5h7zfS69+ie mail@dominik-schwaiger.ch";
  vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAqegrqtU2ijddotv2Xz6OGGg0U9a/L5v3P+P5/lreU root@nixos";

  systems = [ laptop vm ];

  all = users ++ systems;
in
{
  "beaststation_mail_password.age".publicKeys = all;
  "docker_pw.age".publicKeys = all;
  "telegram_watchtower_token".publicKeys = all;
  "db_pw".publicKeys = all;
  "nextcloud_admin_password".publicKeys = all;
  "nextcloud_smtp_password".publicKeys = all;
  "jwt_secret".publicKeys = all;
  "webhook_secret".publicKeys = all;
  "bw_installation_id".publicKeys = all;
  "bw_installation_key".publicKeys = all;
  "schwaiger_admin_password".publicKeys = all;
  "gitlab_smtp_password".publicKeys = all;
  "registry_http_secret".publicKeys = all;
}
