{ config, lib, pkgs, ... }:

let
  cfg = config.apps.ghostty;
in
{
  options.apps.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ghostty ];
    
    xdg.configFile."ghostty/config".text = lib.generators.toKeyValue {} {
      # Font settings
      font-size = 12;
      
      # Theme - using Breeze to match KDE
      theme = "Breeze";
      
      # Copy on select
      copy-on-select = "clipboard";
      
      # Shell integration features
      shell-integration-features = "cursor,sudo,no-title";
      
      # Notifications
      app-notifications = "no-clipboard-copy";
      
      # Keybindings for copy/paste
      keybind = [
        "ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
      ];
    };
  };
}
