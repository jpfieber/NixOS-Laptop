#!/usr/bin/env bash
set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEVICE=""  # Will be set interactively
MOUNT_POINT="/mnt"
CONFIG_REPO="https://github.com/jpfieber/NixOS-Laptop.git"
# Ensure the config dir is accessible to the user later
CONFIG_DIR="${MOUNT_POINT}/home/jpfieber/nixos-config"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  NixOS Btrfs Installation Script${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Show all available disks
echo -e "${YELLOW}Available disks:${NC}"
lsblk -d -o NAME,SIZE,TYPE,TRAN | grep disk
echo ""
echo -e "${YELLOW}Full disk layout:${NC}"
lsblk
echo ""
read -p "Enter the device name to install to (e.g., sda, nvme0n1, mmcblk0): " device_input
DEVICE="/dev/${device_input}"

if [ ! -b "$DEVICE" ]; then
    echo -e "${RED}Error: $DEVICE is not a valid block device${NC}"
    exit 1
fi

echo -e "${YELLOW}Selected device: $DEVICE${NC}"

# Safety check - only run from live USB
# This section is generally fine, assuming you are in a standard NixOS Live environment

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

# Warning about data destruction
echo ""
echo -e "${RED}WARNING: This will DESTROY ALL DATA on ${DEVICE}${NC}"
echo -e "${RED}Make sure you have backed up everything!${NC}"
echo ""
echo -e "${YELLOW}Device details:${NC}"
lsblk ${DEVICE}
echo ""
fdisk -l ${DEVICE} | head -10
echo ""
read -p "Type 'I have backed up my data' to continue: " backup_confirm
if [ "$backup_confirm" != "I have backed up my data" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
read -p "Type the device name to confirm (e.g., sda, nvme0n1, mmcblk0): " device_confirm
if [ "/dev/$device_confirm" != "$DEVICE" ]; then
    echo -e "${RED}Device name doesn't match. Aborted.${NC}"
    exit 1
fi

# Determine partition naming scheme
if [[ "$DEVICE" == *"nvme"* ]] || [[ "$DEVICE" == *"mmcblk"* ]]; then
    PART_PREFIX="p"
else
    PART_PREFIX=""
fi

echo ""
echo -e "${GREEN}Starting installation...${NC}"
echo -e "${YELLOW}Will create partitions: ${DEVICE}${PART_PREFIX}1 and ${DEVICE}${PART_PREFIX}2${NC}"
echo ""

# Deactivate any LVM volumes and unmount partitions
echo -e "${YELLOW}Deactivating LVM and unmounting partitions on ${DEVICE}...${NC}"
# First unmount any mounted partitions on target device only
umount ${DEVICE}${PART_PREFIX}1 2>/dev/null || true
umount ${DEVICE}${PART_PREFIX}2 2>/dev/null || true
umount ${DEVICE}${PART_PREFIX}3 2>/dev/null || true
# Deactivate only LVM volumes that use partitions on this specific device
if command -v pvs &> /dev/null; then
    for vg in $(pvs --noheadings -o vg_name,pv_name 2>/dev/null | grep "${DEVICE}" | awk '{print $1}' | sort -u); do
        if [ -n "$vg" ]; then
            echo "Deactivating volume group: $vg"
            vgchange -an "$vg" 2>/dev/null || true
        fi
    done
fi
echo -e "${GREEN}✓ Deactivated and unmounted${NC}"
sleep 2

# Step 1: Partition the disk
echo -e "${YELLOW}[1/8] Partitioning ${DEVICE}...${NC}"
parted ${DEVICE} -- mklabel gpt
parted ${DEVICE} -- mkpart primary 1MiB 512MiB
parted ${DEVICE} -- set 1 boot on
parted ${DEVICE} -- mkpart primary 512MiB 100%
echo -e "${GREEN}✓ Partitioning complete${NC}"
sleep 2

# Step 2: Format partitions
echo -e "${YELLOW}[2/8] Formatting partitions...${NC}"
mkfs.fat -F 32 -n boot ${DEVICE}${PART_PREFIX}1
mkfs.btrfs -f -L nixos ${DEVICE}${PART_PREFIX}2
echo -e "${GREEN}✓ Formatting complete${NC}"
sleep 2

# Step 3: Create Btrfs subvolumes
echo -e "${YELLOW}[3/8] Creating Btrfs subvolumes...${NC}"
mount ${DEVICE}${PART_PREFIX}2 ${MOUNT_POINT}
btrfs subvolume create ${MOUNT_POINT}/root
btrfs subvolume create ${MOUNT_POINT}/home
btrfs subvolume create ${MOUNT_POINT}/nix
btrfs subvolume create ${MOUNT_POINT}/snapshots
umount ${MOUNT_POINT}
echo -e "${GREEN}✓ Subvolumes created${NC}"
sleep 2

# Step 4: Mount filesystems
echo -e "${YELLOW}[4/8] Mounting filesystems...${NC}"
mount -o subvol=root,compress=zstd,noatime ${DEVICE}${PART_PREFIX}2 ${MOUNT_POINT}
mkdir -p ${MOUNT_POINT}/{boot,home,nix,.snapshots}
mount ${DEVICE}${PART_PREFIX}1 ${MOUNT_POINT}/boot
mount -o subvol=home,compress=zstd,noatime ${DEVICE}${PART_PREFIX}2 ${MOUNT_POINT}/home
mount -o subvol=nix,compress=zstd,noatime ${DEVICE}${PART_PREFIX}2 ${MOUNT_POINT}/nix
mount -o subvol=snapshots,compress=zstd,noatime ${DEVICE}${PART_PREFIX}2 ${MOUNT_POINT}/.snapshots
echo -e "${GREEN}✓ Filesystems mounted${NC}"
sleep 2

# Step 5: Generate initial configuration (just for initial hardware-configuration.nix)
echo -e "${YELLOW}[5/8] Generating hardware configuration...${NC}"
nixos-generate-config --root ${MOUNT_POINT}
echo -e "${GREEN}✓ Hardware configuration generated${NC}"
sleep 2

# Step 6: Clone nixos-config
echo -e "${YELLOW}[6/8] Cloning NixOS configuration...${NC}"
mkdir -p ${CONFIG_DIR}
git clone ${CONFIG_REPO} ${CONFIG_DIR}
echo -e "${GREEN}✓ Configuration cloned${NC}"
sleep 2

# Step 7: Copy hardware-configuration.nix to repo and fix ownership
echo -e "${YELLOW}[7/8] Updating hardware configuration in repo and setting permissions...${NC}"
cp ${MOUNT_POINT}/etc/nixos/hardware-configuration.nix ${CONFIG_DIR}/hardware-configuration.nix

# Assuming UID 1000 is the first user (jpfieber) defined in your Nix config
chown -R 1000:100 ${CONFIG_DIR}
echo -e "${GREEN}✓ Hardware configuration updated and permissions set${NC}"
sleep 2

# Step 8: Install NixOS
echo -e "${YELLOW}[8/8] Installing NixOS from flake (this will take a while)...${NC}"
echo ""
cd ${CONFIG_DIR}
nixos-install --flake .#nixos

# REMOVED STEP 9: The install command handles the bootloader configuration correctly.

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Remove the USB drive"
echo "2. Reboot and enter BIOS if needed to select 'NIXOS' boot entry"
echo "3. After first boot, log in as jpfieber"
echo "4. Restore age key:"
echo "   sudo mkdir -p /var/lib/sops-nix"
echo "   sudo cp /path/to/age-key-backup.txt /var/lib/sops-nix/key.txt"
echo "   sudo chmod 600 /var/lib/sops-nix/key.txt"
echo "4. Rebuild to decrypt secrets:"
echo "   cd ~/nixos-config && nrs"
echo "5. Your Plasma settings (taskbar, widgets, shortcuts) are managed by plasma-manager"
echo "6. Verify all services work"
echo ""
read -p "Press Enter to reboot or Ctrl+C to stay in live environment..."
reboot
