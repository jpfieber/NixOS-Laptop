{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    # Your user-specific packages would go here
  ];
  
  # Import rclone mounts configuration
  imports = [ ./rclone-mounts.nix ];
  
  # KDE screen lock timeout (in seconds)
  # Set to 0 to disable auto-lock, or change to desired seconds (e.g., 600 = 10 minutes)
  home.file.".config/kscreenlockerrc".text = ''
    [Daemon]
    Autolock=true
    LockOnResume=true
    Timeout=0
  '';
  
  # Set desktop background to black
  home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][1][Wallpaper][org.kde.image][General]
    Color=0,0,0
    FillMode=1
  '';
  
  # Enable Night Light with sunrise/sunset schedule
  home.file.".config/kwinrc".text = ''
    [NightColor]
    Active=true
    Mode=Times
    NightTemperature=4500
  '';
  
  # Set Breeze Dark theme and Oxygen icons
  home.file.".config/kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark
    
    [Icons]
    Theme=oxygen
    
    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
    widgetStyle=Breeze
  '';
}
