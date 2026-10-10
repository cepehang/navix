let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINytlbyvu4iUlnl5URDJSmQ73x6EfhUdUK+xEpLFG/pT";
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5xtD8fkDK/wmLCAblN8mXG4biafDS67rYdjgtrcOL5";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICI0aRLnFWufMMJbuo4e2SpdbxgFeAZknfeywiHroNvQ root@nixos";
in
{
  "njalla-keys.age" = {
    publicKeys = [
      laptop
      pc
      server
    ];
    armor = true;
  };
  "wireguard.age" = {
    publicKeys = [
      laptop
      pc
      server
    ];
    armor = true;
  };
}
