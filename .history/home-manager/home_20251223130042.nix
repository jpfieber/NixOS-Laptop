{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; (
    [
      # Your user-specific packages would go here
    ]
    ++ (if pkgs.lib.hasAttr "rnix" pkgs then [ pkgs.rnix ] else [])
    ++ (if pkgs.lib.hasAttr "rnix-lsp" pkgs then [ pkgs.rnix-lsp ] else [])
  );

  # Import app-specific configurations
  imports = [
    ./rclone
    ./git
    ./vscode
    ./alacritty
    ./powershell
    ./ghostty
    ./syncthing
    # ./plasma  # Disabled - manage Plasma settings manually
  ];

  # Enable app modules
  apps.rclone.enable = true;
  apps.git.enable = true;
  apps.vscode.enable = true;
  apps.alacritty.enable = true;
  apps.powershell.enable = true;
  apps.ghostty.enable = true;
  apps.syncthing.enable = true;
  # Note: plasma configuration is imported directly, no enable option needed

  # Note: keybindings.json is managed locally to allow VS Code sync.
}
