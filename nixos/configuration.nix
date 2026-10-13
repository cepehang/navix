{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./desktop.nix
    ./kodi.nix
    ./locale.nix
    ./networking.nix
    ./nixarr.nix
    ./nvidia.nix
  ];

  nixpkgs = {
    overlays = [
      # neovim-nightly-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      flake-registry = "";
    };
    channel.enable = false;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users."cepehang" = {
      isNormalUser = true;
      description = "CepeHang";
      extraGroups = [
        "media"
        "networkmanager"
        "wheel"
      ];
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.cepehang = import ../home-manager/home.nix;
  };

  programs = {
    nh = {
      enable = true;
      flake = "/home/cepehang/Projects/navix/";
    };
    ssh.startAgent = true;
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nerd-fonts.fira-code
  ];

  system.stateVersion = "26.05";
}
