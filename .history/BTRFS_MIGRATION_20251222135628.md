# Btrfs Migration Plan for NixOS Laptop

## Current System State
- Filesystem: ext4
- Boot device: `/dev/sda`
- Boot loader: GRUB
- RAM: 6GB
- Desktop: KDE Plasma 6
- NixOS Version: 25.11

## Pre-Migration Checklist

### 1. Backup Everything
- [ ] All home directory files (`/home/jpfieber`)
- [ ] NixOS configuration (`~/nixos-config` - already in Git)
- [ ] Encrypted secrets (`secrets/secrets.yaml` and age key)
- [ ] Browser profiles, bookmarks
- [ ] Any data on NAS is already backed up
- [ ] SSH keys if not using age-based ones
- [ ] Git credentials (will need to re-authenticate)

**Backup locations:**
- Cloud: Already have OneDrive and Google Drive via rclone
- NAS: Already have shares at 10.0.20.63
- External: Consider USB drive for offline backup

### 2. Document Current Setup
- [ ] Current disk layout: `sudo lsblk -f > disk-layout.txt`
- [ ] Current partitions: `sudo fdisk -l > partitions.txt`
- [ ] Installed packages: Already in configuration
- [ ] Running services: Already in configuration

### 3. Prepare Installation Media
- [ ] Download NixOS 25.11 ISO (or latest stable)
- [ ] Create bootable USB: `dd if=nixos.iso of=/dev/sdX bs=4M status=progress`
- [ ] Test boot from USB before wiping

## Migration Steps

### Phase 1: Backup (On Current System)

```bash
# Sync home directory to NAS
rsync -av --progress /home/jpfieber/ /mnt/nas/home/backup-$(date +%Y%m%d)/

# Backup nixos-config to NAS (redundant with Git, but safe)
rsync -av --progress ~/nixos-config/ /mnt/nas/home/nixos-config-backup/

# Backup age key
sudo cp /var/lib/sops-nix/key.txt ~/age-key-backup.txt
sudo chown jpfieber:users ~/age-key-backup.txt
cp ~/age-key-backup.txt /mnt/nas/home/

# List all systemd user services (to remember what's running)
systemctl --user list-units --type=service > ~/user-services.txt
```

### Phase 2: Installation (Boot from USB)

1. **Boot from NixOS installation USB**

2. **Set up WiFi (if needed)**
```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YourSSID"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit
```

3. **Partition the disk with Btrfs**
```bash
# WARNING: This wipes /dev/sda - make sure backups are complete!

# Create partitions
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart primary 1MiB 512MiB  # Boot partition
sudo parted /dev/sda -- set 1 boot on
sudo parted /dev/sda -- mkpart primary 512MiB 100%  # Root partition

# Format boot partition
sudo mkfs.fat -F 32 -n boot /dev/sda1

# Format root with Btrfs
sudo mkfs.btrfs -L nixos /dev/sda2

# Mount root and create subvolumes
sudo mount /dev/sda2 /mnt
sudo btrfs subvolume create /mnt/root
sudo btrfs subvolume create /mnt/home
sudo btrfs subvolume create /mnt/nix
sudo btrfs subvolume create /mnt/snapshots
sudo umount /mnt

# Mount with proper subvolumes and options
sudo mount -o subvol=root,compress=zstd,noatime /dev/sda2 /mnt
sudo mkdir -p /mnt/{boot,home,nix,.snapshots}
sudo mount /dev/sda1 /mnt/boot
sudo mount -o subvol=home,compress=zstd,noatime /dev/sda2 /mnt/home
sudo mount -o subvol=nix,compress=zstd,noatime /dev/sda2 /mnt/nix
sudo mount -o subvol=snapshots,compress=zstd,noatime /dev/sda2 /mnt/.snapshots
```

4. **Generate hardware configuration**
```bash
sudo nixos-generate-config --root /mnt
```

5. **Copy your nixos-config**
```bash
# If you have USB with config:
sudo mkdir -p /mnt/home/jpfieber/nixos-config
sudo cp -r /path/to/backup/nixos-config/* /mnt/home/jpfieber/nixos-config/

# Or clone from GitHub:
git clone https://github.com/jpfieber/NixOS-Laptop.git /mnt/home/jpfieber/nixos-config
```

6. **Update hardware-configuration.nix for Btrfs**
The generated file will have Btrfs settings, but verify it looks like:
```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/XXXXXXXX";
  fsType = "btrfs";
  options = [ "subvol=root" "compress=zstd" "noatime" ];
};

fileSystems."/home" = {
  device = "/dev/disk/by-uuid/XXXXXXXX";
  fsType = "btrfs";
  options = [ "subvol=home" "compress=zstd" "noatime" ];
};

fileSystems."/nix" = {
  device = "/dev/disk/by-uuid/XXXXXXXX";
  fsType = "btrfs";
  options = [ "subvol=nix" "compress=zstd" "noatime" ];
};

fileSystems."/.snapshots" = {
  device = "/dev/disk/by-uuid/XXXXXXXX";
  fsType = "btrfs";
  options = [ "subvol=snapshots" "compress=zstd" "noatime" ];
};

fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/XXXX-XXXX";
  fsType = "vfat";
};
```

7. **Install NixOS**
```bash
cd /mnt/home/jpfieber/nixos-config
sudo nixos-install --flake .#nixos
```

8. **Set root password when prompted**

9. **Reboot**
```bash
sudo reboot
```

### Phase 3: Post-Installation Setup

1. **First boot - log in as jpfieber**

2. **Set user password if needed**
```bash
passwd
```

3. **Restore age key for sops**
```bash
sudo mkdir -p /var/lib/sops-nix
sudo cp /mnt/nas/home/age-key-backup.txt /var/lib/sops-nix/key.txt
sudo chown root:root /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
```

4. **Rebuild to decrypt secrets**
```bash
cd ~/nixos-config
nrs  # or: sudo nixos-rebuild switch --flake .#nixos
```

5. **Verify rclone mounts work**
```bash
ls ~/gdrive
ls ~/onedrive
```

6. **Verify NFS mounts work**
```bash
ls /mnt/nas/home
ls /mnt/nas/media
ls /mnt/nas/obsidian
```

7. **Configure KDE manually** (as before)
- Breeze Dark theme
- Oxygen icons
- Black wallpaper
- Disable screen lock
- KWallet with empty password

8. **Test printer**
```bash
lpstat -p -d
```

### Phase 4: Set Up Snapper for Automatic Snapshots

Create a new module: `modules/snapshots.nix`

```nix
{ config, pkgs, ... }:

{
  # Enable Snapper
  services.snapper = {
    configs = {
      root = {
        SUBVOLUME = "/";
        ALLOW_USERS = [ "jpfieber" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 6;
      };
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "jpfieber" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 24;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 6;
      };
    };
  };

  # Automatically take snapshot before nixos-rebuild
  system.activationScripts.snapper = ''
    if [ -x ${pkgs.snapper}/bin/snapper ]; then
      ${pkgs.snapper}/bin/snapper -c root create -d "Before nixos-rebuild" || true
    fi
  '';
}
```

Add to `configuration.nix`:
```nix
imports = [
  # ... existing imports
  ./modules/snapshots.nix
];
```

### Phase 5: Verification

- [ ] All applications launch
- [ ] Cloud storage mounts (gdrive, onedrive)
- [ ] NAS mounts accessible
- [ ] Printer works
- [ ] RDP works (test from Windows)
- [ ] VSCode with extensions
- [ ] Alacritty/Ghostty work
- [ ] Git authentication works
- [ ] Syncthing running and syncing
- [ ] Snapshots being created: `sudo snapper -c root list`

## Btrfs Useful Commands

```bash
# List subvolumes
sudo btrfs subvolume list /

# Show disk usage
sudo btrfs filesystem usage /

# Show space used by snapshots
sudo btrfs filesystem du -s /.snapshots/*

# Manual snapshot
sudo snapper -c root create -d "Manual backup"

# List snapshots
sudo snapper -c root list

# Rollback to snapshot (emergency)
# Boot from USB, mount root, delete current root subvolume, 
# snapshot the desired snapshot to become new root

# Check filesystem
sudo btrfs check /dev/sda2

# Balance (optimize space usage)
sudo btrfs balance start -dusage=50 /
```

## Rollback Strategy

If something goes wrong after migration:

1. **Boot from USB**
2. **Mount your Btrfs filesystem**
3. **Access backups from NAS**
4. **Can restore ext4 from backup or continue with Btrfs fix**

## Estimated Timeline

- Backup: 1-2 hours (depending on data size)
- Installation: 30 minutes
- System rebuild: 20-30 minutes
- Post-config: 30 minutes
- Testing: 30 minutes

**Total: ~3-4 hours**

## Benefits After Migration

✓ Instant snapshots before system updates
✓ Quick rollback if updates break something
✓ Automatic timeline snapshots (hourly, daily, weekly)
✓ Better compression = more free space
✓ Copy-on-write = data integrity
✓ Faster file operations with noatime
✓ Subvolumes for better organization

## Notes

- Keep installation USB and backups safe until confirmed stable
- First week, verify snapshots are being created
- Monitor disk space - snapshots accumulate
- Snapper auto-cleanup keeps it manageable
- Can browse snapshots in `/.snapshots/*/snapshot/`
