{ pkgs, ... }:

{
  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs.firefox.enable = true;

  users.users."cepehang".packages = with pkgs; [
    kdePackages.kate
  ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];
}
