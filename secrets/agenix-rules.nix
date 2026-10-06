let
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINytlbyvu4iUlnl5URDJSmQ73x6EfhUdUK+xEpLFG/pT";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5xtD8fkDK/wmLCAblN8mXG4biafDS67rYdjgtrcOL5";
in
{
  "armored-secret.age" = {
    publicKeys = [ laptop server ];
    armor = true;
  };
}
