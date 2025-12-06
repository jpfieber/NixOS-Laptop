{ config, lib, pkgs, ... }:

let
  cfg = config.apps.rclone;
in
{
  options.apps.rclone = {
    enable = lib.mkEnableOption "rclone cloud storage mounts";
    
    gdrive.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Google Drive mount";
    };
    
    onedrive.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable OneDrive mount";
    };
  };

  config = lib.mkIf cfg.enable {
    # Google Drive mount
    systemd.user.services.rclone-gdrive = lib.mkIf cfg.gdrive.enable {
      Unit = {
        Description = "RClone mount for Google Drive";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "notify";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/gdrive";
        ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: %h/gdrive --vfs-cache-mode writes --config %h/.config/rclone/rclone.conf";
        ExecStop = "/run/current-system/sw/bin/fusermount -u %h/gdrive";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    
    # OneDrive mount
    systemd.user.services.rclone-onedrive = lib.mkIf cfg.onedrive.enable {
      Unit = {
        Description = "RClone mount for OneDrive";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "notify";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/onedrive";
        ExecStart = "${pkgs.rclone}/bin/rclone mount onedrive: %h/onedrive --vfs-cache-mode writes --config %h/.config/rclone/rclone.conf";
        ExecStop = "/run/current-system/sw/bin/fusermount -u %h/onedrive";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
