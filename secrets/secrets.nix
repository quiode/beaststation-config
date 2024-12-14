let
  users = [  ];

  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWkILtyyPWk4UYWJaZoI5UqGKo/qlaJG5h7zfS69+ie mail@dominik-schwaiger.ch";
  vm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAqegrqtU2ijddotv2Xz6OGGg0U9a/L5v3P+P5/lreU root@nixos";

  systems = [ laptop vm ];

  all = users ++ systems;
in
{
  "beaststation_mail_password.age".publicKeys = all;
}