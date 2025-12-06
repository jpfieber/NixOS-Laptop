{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    # Your user-specific packages would go here
  ];
  
  # Import app-specific configurations
  imports = [ 
    ./apps/rclone
    ./apps/git
  ];
  
  # Enable app modules
  apps.rclone.enable = true;
  apps.git.enable = true;
  
  # Note: KDE Plasma appearance settings (theme, icons, wallpaper, etc.) 
  # are configured manually through System Settings.
  # This is the standard approach for NixOS + KDE users.
}
