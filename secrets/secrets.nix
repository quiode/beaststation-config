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
  "telegram_watchtower_token.age".publicKeys = all;
  "db_pw.age".publicKeys = all;
  "nextcloud_admin_password.age".publicKeys = all;
  "nextcloud_smtp_password.age".publicKeys = all;
  "jwt_secret.age".publicKeys = all;
  "bw_installation_id.age".publicKeys = all;
  "bw_installation_key.age".publicKeys = all;
  "schwaiger_admin_password.age".publicKeys = all;
  "gitlab_smtp_password.age".publicKeys = all;
  "registry_http_secret.age".publicKeys = all;
}
