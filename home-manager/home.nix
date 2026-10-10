{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.lazyvim.homeManagerModules.default
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [
      # neovim-nightly-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    stateVersion = "26.05";
    username = "cepehang";
    homeDirectory = "/home/cepehang";
    packages = with pkgs; [
      claude-code
      dig
      gparted
    ];
  };

  programs = {
    fzf.enable = true;
    jq.enable = true;
    git = {
      enable = true;
      signing = {
        format = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRwlMedSAzIJB6X0EiqOUrNaMH5ONoD7lFYbLoBuFI5 Navix Signing Key ndml97@gmail.com";
        signByDefault = true;
      };
      settings = {
        gpg = {
          format = "ssh";
        };
        user = {
          name = "CepeHang";
          email = "ndml97@gmail.com";
        };
      };
    };
    lazygit.enable = true;
    lazyvim.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    ripgrep.enable = true;
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".AddKeysToAgent = "yes";
    };
    starship.enable = true;
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "fzf"
          "zoxide"
        ];
      };
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
    zoxide.enable = true;
  };
}
