{
  networking = {
    hostName = "navix";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    tempAddresses = "disabled";
    networkmanager = {
      enable = true;
      ensureProfiles.profiles.wired = {
        connection = {
          id = "Fixed IPv6 address wired connection";
          type = "ethernet";
          interface-name = "enp3s0";
          autoconnect-priority = 11;
        };
        ipv4.method = "auto";
        ipv6 = {
          method = "auto";
          addr-gen-mode = "eui64";
          token = "::10";
          ip6-privacy = 0;
        };
      };
    };
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
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
}
