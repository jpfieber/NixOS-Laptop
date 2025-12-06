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
  ];
  
  # Enable app modules
  apps.rclone.enable = true;
  apps.git.enable = true;
  apps.vscode.enable = true;
  apps.alacritty.enable = true;
  apps.powershell.enable = true;
  apps.ghostty.enable = true;
  apps.syncthing.enable = true;

  # Custom VS Code keybindings (terminal copy/paste behavior)
  xdg.configFile."Code/User/keybindings.json".text = ''
    [
      {
        "key": "ctrl+c",
        "command": "workbench.action.terminal.copySelection",
        "when": "terminalFocus && terminalTextSelected"
      },
      {
        "key": "ctrl+c",
        "command": "workbench.action.terminal.sendSequence",
        "args": { "text": "\u0003" },
        "when": "terminalFocus && !terminalTextSelected"
      },
      {
        "key": "ctrl+v",
        "command": "workbench.action.terminal.paste",
        "when": "terminalFocus"
      }
    ]
  '';
  
  # Note: KDE Plasma appearance settings (theme, icons, wallpaper, etc.) 
  # are configured manually through System Settings.
  # This is the standard approach for NixOS + KDE users.
}
