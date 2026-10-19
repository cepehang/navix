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

  # Let Kodi power off/reboot even when other sessions (e.g. SSH) are open;
  # otherwise polkit asks for admin auth, which Kodi can't provide, and it hangs.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "kodi" &&
          (action.id.indexOf("org.freedesktop.login1.power-off") == 0 ||
           action.id.indexOf("org.freedesktop.login1.reboot") == 0)) {
        return polkit.Result.YES;
      }
    });
  '';

  services = {
    xserver = {
      enable = true;
      # Never blank/DPMS-off the display: turning it off drops the HDMI link,
      # the NVIDIA HDMI sink disappears and Kodi comes back without sound.
      serverFlagsSection = ''
        Option "BlankTime" "0"
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
      '';
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
