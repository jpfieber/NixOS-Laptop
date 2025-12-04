{ config, pkgs, lib, ... }:

let
  plasma-manager = builtins.fetchTarball "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
in
{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    # Your user-specific packages would go here
  ];
  
  # Import rclone mounts and plasma-manager
  imports = [ 
    ./rclone-mounts.nix
    "${plasma-manager}/modules"
  ];
  
  # Declarative KDE Plasma configuration using plasma-manager
  programs.plasma = {
    enable = true;
    
    # Workspace settings
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "oxygen";
      colorScheme = "BreezeDark";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Kay/contents/images/1080x1920.png";
    };
    
    # Screen locker
    kscreenlocker = {
      autoLock = false;
      lockOnResume = false;
      timeout = null;
    };
    
    # Power management - set to null to disable
    powerdevil = {
      AC = {
        autoSuspend = {
          action = "nothing";
          idleTimeout = null;
        };
        turnOffDisplay = {
          idleTimeout = null;
        };
      };
    };
  };
  
  # Disable KWallet password prompt
  home.file.".config/kwalletrc" = {
    text = ''
      [Wallet]
      Enabled=true
      First Use=false
      Prompt on Open=false
      Close When Idle=false
      Idle Timeout=0
    '';
    force = true;
  };
}
