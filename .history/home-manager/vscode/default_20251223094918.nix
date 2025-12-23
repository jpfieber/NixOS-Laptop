{ config, lib, pkgs, ... }:

let
  cfg = config.apps.vscode;
in
{
  options.apps.vscode = {
    enable = lib.mkEnableOption "VSCode configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;

      profiles.default = {
        # NOTE: userSettings intentionally removed so VS Code can manage
        # its own settings.json via Settings Sync / in-editor edits.
        # Extensions are also not managed here to allow Settings Sync.
      };
    };
  };
}
