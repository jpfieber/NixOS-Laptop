{ config, pkgs, ... }:

{
  # Enable flakes and increase download buffer
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 134217728;  # 128MB
  };

  # Bootloader - UEFI with systemd-boot (more reliable for rebuilds)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  
  # Clean up old GRUB installation on next boot
  boot.loader.grub.enable = false;
  
  # One-time systemd service to clean GRUB remnants and ensure systemd-boot is properly installed
  systemd.services.cleanup-grub = {
    description = "Clean up GRUB remnants and install systemd-boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ -d /boot/EFI/NIXOS ] || [ -d /boot/grub ]; then
        echo "Cleaning up old GRUB files..."
        rm -rf /boot/EFI/NIXOS /boot/grub
        echo "Installing systemd-boot..."
        ${pkgs.systemd}/bin/bootctl install --path=/boot
        echo "GRUB cleanup complete. Disabling this service..."
        systemctl disable cleanup-grub.service
      fi
    '';
  };

  # Swap configuration - helps prevent OOM kills during builds
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4096; # 4GB swap file
    }
  ];

  # Networking
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Localization
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Shell aliases for all users
  environment.shellAliases = {
    nrs = "cd /etc/nixos && git pull && sudo nixos-rebuild switch --flake .#nixos";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
