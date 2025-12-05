# Setup Instructions for Secrets Management

## What was added:
1. **Swap file**: 4GB swap to prevent OOM kills during builds
2. **sops-nix**: Encrypted secrets management so you can safely commit rclone.conf to Git

## Steps to complete setup on NixOS:

### 1. First rebuild (to install tools)
Close Chrome first to free up memory, then:
```bash
sudo nixos-rebuild switch
```

The rebuild might fail because secrets/rclone.conf isn't encrypted yet. That's OK - it installs the tools we need.

### 2. Generate age encryption key from host SSH key
```bash
# Create directory for the key
sudo mkdir -p /var/lib/sops-nix

# Find SSH host keys
ls -la /etc/ssh/ssh_host_*

# Install ssh-to-age if not already available
nix-shell -p ssh-to-age

# Generate the age private key (use the key type that exists on your system)
# Try ed25519 first:
sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key -o /var/lib/sops-nix/key.txt

# If ed25519 doesn't exist, try rsa:
# sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_rsa_key -o /var/lib/sops-nix/key.txt

# Get the age PUBLIC key (you'll need this for .sops.yaml)
# Use the same key type as above:
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# OR if using RSA:
# ssh-to-age < /etc/ssh/ssh_host_rsa_key.pub
```

Copy the output from the last command - it looks like: `age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
age1q3ntzavjjy565kzldeqsaxrnmqlmw626uq3vk9hhlsj47frt05rsvmh2q4


### 3. Configure sops
```bash
cd ~/path/to/NixOS-Laptop
cp .sops.yaml.template .sops.yaml
nano .sops.yaml
```

Replace `YOUR_AGE_PUBLIC_KEY_HERE` with the age public key from step 2.

### 4. Encrypt your rclone.conf
```bash
# Copy your current rclone config content
cat ~/.config/rclone/rclone.conf

# Edit and encrypt the secrets file
sops secrets/rclone.conf
```

This will open an editor. Replace the placeholder content with your actual rclone.conf content, save and exit. The file will be encrypted automatically.

### 5. Commit the encrypted secret
```bash
git add secrets/rclone.conf .sops.yaml
git commit -m "Add encrypted rclone configuration"
git push
```

Now your rclone OAuth tokens are encrypted and safe to commit!

### 6. Final rebuild
```bash
sudo nixos-rebuild switch
```

This will deploy the encrypted rclone.conf to `/home/jpfieber/.config/rclone/rclone.conf` automatically.

### 7. Clean up old unencrypted file
After verifying rclone works:
```bash
# The old file should be gone, but if there's any backup:
rm -f ~/.config/rclone/rclone.conf.backup
```

## Benefits:
- ✅ OAuth tokens encrypted with age
- ✅ Safe to commit secrets to Git
- ✅ Automatic deployment during rebuild
- ✅ 4GB swap prevents OOM during builds
- ✅ Based on best practices from modern NixOS configs

## To edit secrets later:
```bash
sops secrets/rclone.conf
```
