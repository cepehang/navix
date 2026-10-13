{ pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  users.users.kodi = {
    isNormalUser = true;
    description = "Kodi";
  };

  services = {
    xserver = {
      enable = true;
      desktopManager.kodi = {
        enable = true;
        # Force VDPAU instead of VAAPI which does not work with the
        # proprietary nvidia driver
        package = pkgs.symlinkJoin {
          name = "kodi-glx";
          paths = [ (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [ jellyfin ])) ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/kodi --add-flags "--gl-interface=glx"
          '';
        };
      };
    };
    displayManager = {
      # SDDM autologin uses the default session, so Kodi has to be the default.
      # Pick "Plasma (Wayland)" from the session menu when logging in as cepehang.
      defaultSession = "kodi";
      autoLogin = {
        enable = true;
        user = "kodi";
      };
    };
    # WirePlumber starts unsaved outputs at 0.064 (-24 dB). The kodi user never
    # touches the system volume, so start them at full and let Kodi control it.
    pipewire.wireplumber.extraConfig."60-default-sink-volume" = {
      "wireplumber.settings"."device.routes.default-sink-volume" = 1.0;
    };
  };
}
