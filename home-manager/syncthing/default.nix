{ config, lib, pkgs, ... }:

let
  cfg = config.apps.syncthing;
in
{
  options.apps.syncthing = {
    enable = lib.mkEnableOption "Syncthing file synchronization";
  };

  config = lib.mkIf cfg.enable {
    # Enable syncthing service
    services.syncthing = {
      enable = true;
    };
    
    # Create desktop shortcut to open Syncthing web UI
    xdg.desktopEntries.syncthing = {
      name = "Syncthing";
      comment = "Open Syncthing Web UI";
      exec = "${pkgs.xdg-utils}/bin/xdg-open http://localhost:8384";
      icon = "syncthing";
      terminal = false;
      categories = [ "Network" "FileTransfer" ];
    };
  };
}
