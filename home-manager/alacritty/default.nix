{ config, lib, pkgs, ... }:

let
  cfg = config.apps.alacritty;
in
{
  options.apps.alacritty = {
    enable = lib.mkEnableOption "Alacritty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      
      settings = {
        # Window settings
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          decorations = "full";
          opacity = 1.0;
        };
        
        # Scrolling
        scrolling = {
          history = 10000;
          multiplier = 3;
        };
        
        # Font configuration
        font = {
          normal = {
            family = "monospace";
            style = "Regular";
          };
          bold = {
            family = "monospace";
            style = "Bold";
          };
          italic = {
            family = "monospace";
            style = "Italic";
          };
          size = 12.0;
        };
        
        # Colors (Breeze - matches KDE Konsole)
        colors = {
          primary = {
            background = "#232627";
            foreground = "#fcfcfc";
          };
          normal = {
            black = "#232627";
            red = "#ed1515";
            green = "#11d116";
            yellow = "#f67400";
            blue = "#1d99f3";
            magenta = "#9b59b6";
            cyan = "#1abc9c";
            white = "#fcfcfc";
          };
          bright = {
            black = "#7f8c8d";
            red = "#c0392b";
            green = "#1cdc9a";
            yellow = "#fdbc4b";
            blue = "#3daee9";
            magenta = "#8e44ad";
            cyan = "#16a085";
            white = "#ffffff";
          };
        };
        
        # Cursor
        cursor = {
          style = {
            shape = "Block";
            blinking = "Off";
          };
        };
        
        # Shell - uses system default (bash)
        # Uncomment to use PowerShell instead:
        # terminal.shell = {
        #   program = "${pkgs.powershell}/bin/pwsh";
        # };
        
        # Key bindings - Ctrl+C/V for copy/paste
        keyboard.bindings = [
          { key = "C"; mods = "Control"; action = "Copy"; }
          { key = "V"; mods = "Control"; action = "Paste"; }
          { key = "C"; mods = "Control|Shift"; action = "Copy"; }
          { key = "V"; mods = "Control|Shift"; action = "Paste"; }
          { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
          { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
          { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
        ];
      };
    };
  };
}
