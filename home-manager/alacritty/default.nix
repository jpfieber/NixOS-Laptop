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
        
        # Colors (One Dark theme)
        colors = {
          primary = {
            background = "#282c34";
            foreground = "#abb2bf";
          };
          normal = {
            black = "#282c34";
            red = "#e06c75";
            green = "#98c379";
            yellow = "#d19a66";
            blue = "#61afef";
            magenta = "#c678dd";
            cyan = "#56b6c2";
            white = "#abb2bf";
          };
          bright = {
            black = "#5c6370";
            red = "#e06c75";
            green = "#98c379";
            yellow = "#d19a66";
            blue = "#61afef";
            magenta = "#c678dd";
            cyan = "#56b6c2";
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
        
        # Shell
        terminal.shell = {
          program = "${pkgs.powershell}/bin/pwsh";
        };
        
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
