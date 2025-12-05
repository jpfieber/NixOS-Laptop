{ config, pkgs, ... }:

{
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
}
