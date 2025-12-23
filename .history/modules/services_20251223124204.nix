{ config, pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];  # Brother laser printer driver
  };

  # Pre-configure Brother printer
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_HL-L2340D";
        location = "Network";
        deviceUri = "ipp://192.168.86.19/ipp/print";
        model = "drv:///brlaser.drv/brl2340d.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_HL-L2340D";
  };

  # Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable OpenSSH server (needed for sops-nix to use host keys)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;  # More secure - use keys only
      PermitRootLogin = "no";
    };
  };

  # Sops secrets configuration - automatically deploys encrypted rclone.conf
  # Only enable if the age key file exists
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    validateSopsFiles = false;  # Don't fail if secrets can't be decrypted during install
    secrets.rclone-conf = {
      path = "/home/jpfieber/.config/rclone/rclone.conf";
      owner = "jpfieber";
      group = "users";
      mode = "0600";
    };
  };
}
