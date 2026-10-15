let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINytlbyvu4iUlnl5URDJSmQ73x6EfhUdUK+xEpLFG/pT";
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5xtD8fkDK/wmLCAblN8mXG4biafDS67rYdjgtrcOL5";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICI0aRLnFWufMMJbuo4e2SpdbxgFeAZknfeywiHroNvQ root@nixos";

  cepehangKeys = [
    laptop
    pc
    server
  ];
in
{

  "rutracker-username.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
  "rutracker-password.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
  "njalla-keys.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
  "wireguard.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
  "eweka-username.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
  "eweka-password.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
  "sabnzbd-api-key.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
  "nzbgeek-api-key.age" = {
    publicKeys = cepehangKeys;
    armor = true;
  };
}
