let
  beaststation-domina = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAION61ovdLLEFvBSEnM0KHflttJFbOe3KDAwIShZM7uTd domina@beaststation";
  laptop-quio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpYUYVbj55SB3zK+W+oUq2AdO3sS27ZeTtGVYpdq3Dd quio@laptop";
  pc-quio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt4xvNKr0MsKk7qY9RJux9KGfUk2lCsnAeUO4NtJP8n quio@gaming-pc";

  users = [
    beaststation-domina
    laptop-quio
    pc-quio
  ];

  beaststation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/s6lYNuiiu10xgH91eUfyHMBumXa3wby0dP+PaVsaF root@beaststation";

  systems = [beaststation];

  all = users ++ systems;
in {
  "beaststation_mail_password.age".publicKeys = all;
}
