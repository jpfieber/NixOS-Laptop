# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./storage.nix
    ];

  # Enable flakes and increase download buffer
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    download-buffer-size = 134217728;  # 128MB
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Swap configuration - helps prevent OOM kills during builds
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4096; # 4GB swap file
    }
  ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.jpfieber = {
    isNormalUser = true;
    description = "Joseph Fieber";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    };
  };

  # This block enables and configures Home Manager for the specified user
  home-manager.users.jpfieber = import ./home.nix;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Allow insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"      # contains binary blobs that can't be audited for security
    "ventoy-qt5-1.1.07"  # Qt5 version of ventoy with same security concerns
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    audacity
    puddletag           # alternative to MP3Tag
    #notepadqq           # alternative to NotePad++ (errors on install)
    kdePackages.okular  # alternative to SumatraPDF
    vscode
    obsidian
    picard
    cuetools            # CLI only
    vlc
    google-chrome
    chromium            # Better Plasma integration than google-chrome
    microsoft-edge
    p7zip               # CLI only
    peazip              # GUI for 7-zip
    handbrake
    imagemagick
    mp3gain
    strawberry          # potential musicbee alternative
    weasis              # Alternative to MicroDICOM
    mediainfo
    mediainfo-gui
    ffmpeg_7
    exiftool
    libhdhomerun          # Not working
    hdhomerun-config-gui  # Not working
    rclone              # alternative to Google Drive & OneDrive
    rclone-browser      # alternative to Google Drive & OneDrive
    pavucontrol         # Graphical Audio Mixer for Topping DX3 Pro+ control
    kdePackages.plasma-browser-integration  # Native host for Plasma Integration browser extension
    whipper             # Accurate CD ripper (alternative to EAC)
    ventoy-full         # multi-iso bootloader
    ventoy-full-qt      # Gui for ventoy
    age                 # Encryption tool for sops
    sops                # Secret management tool
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable xrdp for RDP access
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
    openFirewall = true;
  };
  
  # Sops secrets configuration - automatically deploys encrypted rclone.conf
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets.rclone-conf = {
      path = "/home/jpfieber/.config/rclone/rclone.conf";
      owner = "jpfieber";
      group = "users";
      mode = "0600";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
