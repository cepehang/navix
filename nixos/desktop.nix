{ pkgs, ... }:

{
  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services = {
    xserver.desktopManager.xfce.enable = true;
    # XFCE pulls in gnome-keyring's SSH agent; keep programs.ssh.startAgent instead
    gnome.gcr-ssh-agent.enable = false;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    xclip
  ];
}
