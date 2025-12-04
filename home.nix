{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    # Your user-specific packages would go here
  ];
  
  # Import rclone mounts and plasma-manager
  imports = [ 
    ./rclone-mounts.nix
    <plasma-manager/modules>
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
      timeout = 0;
    };
    
    # Power management
    powerdevil = {
      AC = {
        autoSuspend = {
          action = "nothing";
          idleTimeout = 0;
        };
        turnOffDisplay = {
          idleTimeout = 0;
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
