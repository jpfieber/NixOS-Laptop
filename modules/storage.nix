{ config, pkgs, ... }:

{
  # NFS mounts for Synology NAS - using NFSv3 to avoid ACL issues
  fileSystems."/mnt/nas/home" = {
    device = "192.168.86.63:/volume1/homes/jpfieber";
    fsType = "nfs";
    options = [ 
      "nfsvers=3"
      "rw"
      "noatime"
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };
  
  fileSystems."/mnt/nas/media" = {
    device = "192.168.86.63:/volume1/Media";
    fsType = "nfs";
    options = [ 
      "nfsvers=3"
      "rw"
      "noatime"
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };
  
  fileSystems."/mnt/nas/obsidian" = {
    device = "192.168.86.63:/volume1/Obsidian";
    fsType = "nfs";
    options = [ 
      "nfsvers=3"
      "rw"
      "noatime"
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };

  fileSystems."/mnt/nas/shared" = {
    device = "192.168.86.63:/volume1/Shared";
    fsType = "nfs";
    options = [ 
      "nfsvers=3"
      "rw"
      "noatime"
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };

  # Ensure NFS client services are enabled
  services.rpcbind.enable = true;

  # Fix NFS mount point permissions - ensure mount points are accessible
  systemd.tmpfiles.rules = [
    "d /mnt/nas 0755 root root -"
    "d /mnt/nas/home 0755 root root -"
    "d /mnt/nas/media 0755 root root -"
    "d /mnt/nas/obsidian 0755 root root -"
    "d /mnt/nas/shared 0755 root root -"
  ];

  # Service to fix mount point permissions after automount
  systemd.services.fix-nfs-permissions = {
    description = "Fix NFS mount point permissions";
    after = [ "remote-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/chmod 755 /mnt/nas/home /mnt/nas/media /mnt/nas/obsidian /mnt/nas/shared";
    };
  };
}
