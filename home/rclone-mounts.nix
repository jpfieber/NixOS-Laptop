{ config, pkgs, ... }:

{
  # Rclone systemd mounts for Google Drive and OneDrive
  systemd.user.services.rclone-gdrive = {
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
  
  systemd.user.services.rclone-onedrive = {
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
}
