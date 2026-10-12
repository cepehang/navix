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

  networking = {
    hostName = "navix";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    networkmanager = {
      enable = true;
    };
  };

  security.rtkit.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  time.timeZone = "Europe/Paris";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  console.keyMap = "fr";
  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "fr";
        variant = "";
      };
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    lidarr = {
      settings.auth.required = "DisabledForLocalAddresses";
    };
    sonarr = {
      settings.auth.required = "DisabledForLocalAddresses";
    };
    radarr = {
      settings.auth.required = "DisabledForLocalAddresses";
    };
    prowlarr = {
      settings.auth.required = "DisabledForLocalAddresses";
    };
    flaresolverr.enable = true;
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "true";
        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
    };
  };

  age.secrets = {
    njalla-keys.file = ../secrets/njalla-keys.age;
    rutracker-username.file = ../secrets/rutracker-username.age;
    rutracker-password.file = ../secrets/rutracker-password.age;
    wireguard.file = ../secrets/wireguard.age;
  };

  nixarr = {
    enable = true;
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.age.secrets.wireguard.path;
    };

    ddns.njalla = {
      enable = true;
      keysFile = config.age.secrets.njalla-keys.path;
    };

    jellyfin = {
      enable = true;
      expose.https = {
        enable = true;
        domainName = "jellyfin.cepehang.com";
        acmeMail = "ndml97@gmail.com";
      };
      openFirewall = true;
    };

    qbittorrent = {
      enable = true;
      vpn.enable = true;
      peerPort = 8034;
      webuiPort = 5252;

      # See: https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent
      # extraConfig = {
      #   BitTorrent = {
      #     "Session\\MaxActiveDownloads" = 3;
      #     "Session\\MaxActiveTorrents" = 5;
      #   };
      # };
    };

    bazarr = {
      enable = true;
      settings-sync = {
        sonarr.enable = true;
        sonarr.config = {
          sync_only_monitored_series = true;
          sync_only_monitored_episodes = true;
        };

        radarr.enable = true;
        radarr.config = {
          sync_only_monitored_movies = true;
        };
      };
    };

    lidarr.enable = true;

    radarr = {
      enable = true;
      settings-sync = {
        downloadClients = [
          {
            name = "qBittorrent (VPN)";
            implementation = "QBittorrent";
            fields = {
              host = config.vpnNamespaces.wg.namespaceAddress; # 192.168.15.1
              port = config.nixarr.qbittorrent.qui.internalPort; # 8085
            };
          }
        ];
      };
    };

    sonarr = {
      enable = true;
      settings-sync = {
        downloadClients = [
          {
            name = "qBittorrent (VPN)";
            implementation = "QBittorrent";
            fields = {
              host = config.vpnNamespaces.wg.namespaceAddress; # 192.168.15.1
              port = config.nixarr.qbittorrent.qui.internalPort; # 8085
            };
          }
        ];
      };
    };
    seerr.enable = true;

    prowlarr = {
      enable = true;
      settings-sync = {
        enable-nixarr-apps = true;
        tags = [ "flaresolverr" ];
        indexers = [
          {
            sort_name = "1337x";
            tags = [ "flaresolverr" ];
            fields = {
              baseUrl = "https://1337x.to/";
            };
          }
          {
            sort_name = "eztv";
            tags = [ "flaresolverr" ];
            fields = {
              baseUrl = "https://eztvx.to/";
            };
          }
          {
            sort_name = "rutracker org";
            tags = [ "flaresolverr" ];
            fields = {
              baseUrl = "https://rutracker.org/";
              username.secret = config.age.secrets.rutracker-username.path;
              password.secret = config.age.secrets.rutracker-password.path;
            };
          }
          {
            sort_name = "nyaa si";
            fields = {
              baseUrl = "https://nyaa.si/";
            };
          }
        ];
      };
    };

    recyclarr = {
      enable = true;
      configuration = {
        sonarr = {
          series = {
            base_url = "http://localhost:8989";
            api_key = "!env_var SONARR_API_KEY";
            delete_old_custom_formats = true;
            quality_definition = {
              type = "series";
            };
            quality_profiles = [
              {

                trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
                reset_unmatched_scores.enabled = true;
              }
              {

                trash_id = "4c48f506c1116a3a57ae33f12346bd15"; # [French MULTi.VO] HD Bluray + WEB (1080p)
                reset_unmatched_scores.enabled = true;
              }
            ];
            media_naming.series = "jellyfin-tvdb";
            episodes.rename = true;
          };
        };
        radarr = {
          movies = {
            base_url = "http://localhost:7878";
            api_key = "!env_var RADARR_API_KEY";
            quality_definition = {
              type = "movie";
            };
            delete_old_custom_formats = true;
            media_naming = {
              folder = "jellyfin-tmdb";
              movie = {
                rename = true;
                standard = "jellyfin-tmdb";
              };
            };
          };
        };
      };
    };

    # exporters.enable = true;
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
      packages = with pkgs; [
        kdePackages.kate
      ];
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.cepehang = import ../home-manager/home.nix;
  };

  programs = {
    firefox.enable = true;
    nh = {
      enable = true;
      flake = "/home/cepehang/Projects/navix/";
    };
    ssh.startAgent = true;
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nerd-fonts.fira-code
    wl-clipboard
  ];

  system.stateVersion = "26.05";
}
