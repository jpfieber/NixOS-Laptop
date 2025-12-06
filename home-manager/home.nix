{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    # Your user-specific packages would go here
    rnix
    rnix-lsp
  ];
  
  # Import app-specific configurations
  imports = [ 
    ./rclone
    ./git
    ./vscode
    ./alacritty
    ./powershell
    ./ghostty
    ./syncthing
  ];
  
  # Enable app modules
  apps.rclone.enable = true;
  apps.git.enable = true;
  apps.vscode.enable = true;
  apps.alacritty.enable = true;
  apps.powershell.enable = true;
  apps.ghostty.enable = true;
  apps.syncthing.enable = true;
  
  # Note: KDE Plasma appearance settings (theme, icons, wallpaper, etc.) 
  # are configured manually through System Settings.
  # This is the standard approach for NixOS + KDE users.
}
