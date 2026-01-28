#!/usr/bin/env bash
set -e
set -u
set -o pipefail

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

# IMPORTANT: Detect script location BEFORE we do anything else
# Save it because once we mount things, paths may become inaccessible
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAVED_SCRIPT_DIR="$SCRIPT_DIR"

# Ensure the config dir is accessible to the user later
CONFIG_DIR="${MOUNT_POINT}/etc/nixos/NixOS-Laptop"

echo -e "${BLUE}Script directory: ${SAVED_SCRIPT_DIR}${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  NixOS Installation Script${NC}"
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
echo -e "${YELLOW}Will create partitions: ${DEVICE}${PART_PREFIX}1, ${DEVICE}${PART_PREFIX}2, and ${DEVICE}${PART_PREFIX}3${NC}"
echo ""

# Deactivate any LVM volumes and unmount partitions
echo -e "${YELLOW}Deactivating LVM and unmounting partitions on ${DEVICE}...${NC}"
# First unmount any mounted partitions on target device only
umount ${DEVICE}${PART_PREFIX}1 2>/dev/null || true
umount ${DEVICE}${PART_PREFIX}2 2>/dev/null || true
umount ${DEVICE}${PART_PREFIX}3 2>/dev/null || true
swapoff ${DEVICE}${PART_PREFIX}3 2>/dev/null || true
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
echo -e "${YELLOW}[1/7] Partitioning ${DEVICE}...${NC}"
parted ${DEVICE} -- mklabel gpt
parted ${DEVICE} -- mkpart ESP fat32 1MiB 512MiB
parted ${DEVICE} -- set 1 esp on
parted ${DEVICE} -- mkpart primary 512MiB -8GiB
parted ${DEVICE} -- mkpart primary linux-swap -8GiB 100%
echo -e "${GREEN}✓ Partitioning complete${NC}"
sleep 2

# Step 2: Format partitions
echo -e "${YELLOW}[2/7] Formatting partitions...${NC}"
wipefs -a ${DEVICE}${PART_PREFIX}1 2>/dev/null || true
wipefs -a ${DEVICE}${PART_PREFIX}2 2>/dev/null || true
wipefs -a ${DEVICE}${PART_PREFIX}3 2>/dev/null || true
mkfs.fat -F 32 -n BOOT ${DEVICE}${PART_PREFIX}1
mkfs.ext4 -F -L nixos ${DEVICE}${PART_PREFIX}2
mkswap -L swap ${DEVICE}${PART_PREFIX}3
echo -e "${GREEN}✓ Formatting complete${NC}"
sleep 2

# Step 3: Mount filesystems
echo -e "${YELLOW}[3/7] Mounting filesystems...${NC}"
mount ${DEVICE}${PART_PREFIX}2 ${MOUNT_POINT}
mkdir -p ${MOUNT_POINT}/boot
mount ${DEVICE}${PART_PREFIX}1 ${MOUNT_POINT}/boot
swapon ${DEVICE}${PART_PREFIX}3
echo -e "${GREEN}✓ Filesystems mounted${NC}"
sleep 2

# Step 4: Generate initial configuration (just for initial hardware-configuration.nix)
echo -e "${YELLOW}[4/7] Generating hardware configuration...${NC}"
nixos-generate-config --root ${MOUNT_POINT}
echo -e "${GREEN}✓ Hardware configuration generated${NC}"
sleep 2

# Step 5: Clone nixos-config
echo -e "${YELLOW}[5/7] Cloning configuration repository...${NC}"
mkdir -p ${CONFIG_DIR}
git clone ${CONFIG_REPO} ${CONFIG_DIR} || {
  echo -e "${RED}ERROR: Failed to clone repository${NC}"
  exit 1
}
echo -e "${GREEN}✓ Configuration cloned${NC}"
sleep 2

# Step 6: Copy hardware-configuration.nix to repo
echo -e "${YELLOW}[6/7] Updating hardware configuration in repo...${NC}"
cp ${MOUNT_POINT}/etc/nixos/hardware-configuration.nix ${CONFIG_DIR}/hardware-configuration.nix
echo -e "${GREEN}✓ Hardware configuration updated${NC}"
sleep 2

# Step 7: Enable flakes and install NixOS
echo -e "${YELLOW}[7/7] Enabling flakes and installing NixOS (this will take a while)...${NC}"
mkdir -p ${MOUNT_POINT}/etc/nix
echo "experimental-features = nix-command flakes" > ${MOUNT_POINT}/etc/nix/nix.conf
echo ""
nixos-install --flake ${CONFIG_DIR}#NixOS-Laptop

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Remove the USB drive"
echo "2. Reboot"
echo "3. Log in as jpfieber"
echo "4. Your NixOS system with Niri compositor is ready!"
echo ""
read -p "Press Enter to reboot or Ctrl+C to stay in live environment..."
reboot
