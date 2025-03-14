let
  users = [ ];

  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWkILtyyPWk4UYWJaZoI5UqGKo/qlaJG5h7zfS69+ie mail@dominik-schwaiger.ch";
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxfAbBPBerC/yizdTU3aWII4fsDWEwZBHmxMAhgNn7X quio@dominik-kaltbrunn-pc";
  vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAqegrqtU2ijddotv2Xz6OGGg0U9a/L5v3P+P5/lreU root@nixos";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/s6lYNuiiu10xgH91eUfyHMBumXa3wby0dP+PaVsaF root@beaststation";

  systems = [ laptop pc vm server ];

  all = users ++ systems;
in
{
  "beaststation_mail_password.age".publicKeys = all;
}
