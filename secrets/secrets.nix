let
  beaststation-domina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAION61ovdLLEFvBSEnM0KHflttJFbOe3KDAwIShZM7uTd domina@beaststation";
  laptop-quio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWkILtyyPWk4UYWJaZoI5UqGKo/qlaJG5h7zfS69+ie mail@dominik-schwaiger.ch";
  pc-quio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxfAbBPBerC/yizdTU3aWII4fsDWEwZBHmxMAhgNn7X quio@dominik-kaltbrunn-pc";

  users = [ beaststation-domina laptop-quio pc-quio ];

  beaststation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/s6lYNuiiu10xgH91eUfyHMBumXa3wby0dP+PaVsaF root@beaststation";

  systems = [ beaststation ];

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
  "immich_db_pw.age".publicKeys = all;
}
