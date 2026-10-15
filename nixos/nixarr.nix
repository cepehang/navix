{ config, ... }:

{
  age.secrets = {
    njalla-keys.file = ../secrets/njalla-keys.age;
    wireguard.file = ../secrets/wireguard.age;
    rutracker-username = {
      file = ../secrets/rutracker-username.age;
      owner = "prowlarr";
    };
    rutracker-password = {
      file = ../secrets/rutracker-password.age;
      owner = "prowlarr";
    };
    nzbgeek-api-key = {
      file = ../secrets/nzbgeek-api-key.age;
      owner = "prowlarr";
    };
    eweka-username = {
      file = ../secrets/eweka-username.age;
      owner = "sabnzbd";
    };
    eweka-password = {
      file = ../secrets/eweka-password.age;
      owner = "sabnzbd";
    };
    sabnzbd-api-key = {
      file = ../secrets/sabnzbd-api-key.age;
      owner = "sabnzbd";
      group = "media";
      mode = "0440";
    };
  };

  systemd.tmpfiles.rules = [ "z /data 0755 root root -" ];

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

      # extraConfig = {
      #   BitTorrent = {
      #     "Session\\MaxActiveDownloads" = 3;
      #     "Session\\MaxActiveTorrents" = 5;
      #   };
      # };
    };

    # Usenet over TLS to the provider, so no VPN
    sabnzbd.enable = true;

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
          {
            name = "SABnzbd";
            implementation = "Sabnzbd";
            fields = {
              host = "127.0.0.1";
              port = config.nixarr.sabnzbd.guiPort;
              apiKey.secret = config.age.secrets.sabnzbd-api-key.path;
              movieCategory = "radarr";
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
          {
            name = "SABnzbd";
            implementation = "Sabnzbd";
            fields = {
              host = "127.0.0.1";
              port = config.nixarr.sabnzbd.guiPort;
              apiKey.secret = config.age.secrets.sabnzbd-api-key.path;
              tvCategory = "sonarr";
            };
          }
        ];
      };
    };

    seerr = {
      enable = true;
      expose.https = {
        enable = true;
        domainName = "seerr.cepehang.com";
        acmeMail = "ndml97@gmail.com";
      };
    };

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
            priority = 10;
            fields = {
              baseUrl = "https://nyaa.si/";
            };
          }
          {
            sort_name = "nzbgeek";
            fields.apiKey.secret = config.age.secrets.nzbgeek-api-key.path;
          }
          {
            sort_name = "animetosho usenet";
            fields.baseUrl = "https://feed.animetosho.xyz";
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
                trash_id = "9d142234e45d6143785ac55f5a9e8dc9"; # WEB-1080p (Alternative)
                name = "[Défaut] Série VOSTFR";
                reset_unmatched_scores.enabled = true;
              }
              {
                trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
                name = "Animé";
                reset_unmatched_scores.enabled = true;
              }
              {
                trash_id = "4c48f506c1116a3a57ae33f12346bd15"; # [French MULTi.VO] HD Bluray + WEB (1080p)
                name = "Série VOSTFR (+ VF)";
                reset_unmatched_scores.enabled = true;
              }
            ];
            media_naming = {
              series = "jellyfin-tvdb";
              season = "default";
              episodes = {
                rename = true;
                standard = "default";
                daily = "default";
                anime = "default";
              };
            };
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
            quality_profiles = [
              {
                trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Bluray + WEB
                name = "[Défaut] VOSTFR";
                reset_unmatched_scores.enabled = true;
              }
              {
                trash_id = "2572ce3ea4eef1c19d59e0e20ed1cea7"; # [French MULTi.VO] HD Bluray + WEB
                name = "VOSTFR (+ VF)";
                reset_unmatched_scores.enabled = true;
              }
            ];
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

  # Upstream settings Nixarr does not expose
  services = {
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

    sabnzbd = {
      settings = {
        misc = {
          api_key = "@sabnzbd_api_key@";
          cache_limit = "512M";
          # fix config drift to prevent SABnzbd writing to its read-only config
          config_conversion_version = 5;
          fixed_ports = true;
        };
        servers.eweka = {
          name = "eweka";
          displayname = "Eweka";
          host = "news.eweka.nl";
          port = 563;
          connections = 50;
          expire_date = "";
          username = "@eweka_username@";
          password = "@eweka_password@";
        };
        categories = {
          # fix config drift to prevent SABnzbd writing to its read-only config
          "*" = {
            name = "*";
            pp = 3;
            script = "None";
          };
          # Match the tvCategory/movieCategory used by the sonarr/radarr download clients
          sonarr = {
            name = "sonarr";
            dir = "${config.nixarr.mediaDir}/usenet/sonarr";
          };
          radarr = {
            name = "radarr";
            dir = "${config.nixarr.mediaDir}/usenet/radarr";
          };
        };
      };
      secretValues = {
        "@sabnzbd_api_key@" = config.age.secrets.sabnzbd-api-key.path;
        "@eweka_username@" = config.age.secrets.eweka-username.path;
        "@eweka_password@" = config.age.secrets.eweka-password.path;
      };
    };
  };
}
