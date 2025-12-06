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
    
    xdg.configFile."ghostty/config".text = ''
      # Font settings
      font-size = 12
      font-family = monospace
      
      # Theme - Breeze Dark to match KDE Konsole
      background = 232627
      foreground = fcfcfc
      
      # Transparency (0.0 = fully transparent, 1.0 = fully opaque)
      background-opacity = 0.95
      
      # Cursor
      cursor-color = fcfcfc
      cursor-style = block
      
      # Window padding
      window-padding-x = 10
      window-padding-y = 10
      
      # Copy on select
      copy-on-select = clipboard
      
      # Shell integration features
      shell-integration-features = cursor,sudo,no-title
      
      # Notifications
      app-notifications = no-clipboard-copy
      
      # Keybindings for copy/paste
      keybind = ctrl+c=copy_to_clipboard
      keybind = ctrl+v=paste_from_clipboard
      keybind = ctrl+shift+c=copy_to_clipboard
      keybind = ctrl+shift+v=paste_from_clipboard
    '';
  };
}
