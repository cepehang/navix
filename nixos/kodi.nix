{ pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  users.users.kodi = {
    isNormalUser = true;
    description = "Kodi";
    hashedPassword = "";
  };

  security.pam.services.sddm.allowNullPassword = true;

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
      defaultSession = "kodi";
      autoLogin = {
        enable = true;
        user = "kodi";
      };
    };
    # set full volume instead of 0.064 (-24 dB)
    pipewire.wireplumber.extraConfig."60-default-sink-volume" = {
      "wireplumber.settings"."device.routes.default-sink-volume" = 1.0;
    };
  };
}
