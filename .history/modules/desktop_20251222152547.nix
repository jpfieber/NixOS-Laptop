{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable GNOME Desktop Environment.
  # To switch back to Plasma, comment out the GNOME lines below and uncomment the Plasma lines
  
  # GNOME (currently active)
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # KDE Plasma (uncomment to switch back)
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable xrdp for RDP access
  services.xrdp = {
    enable = true;
    defaultWindowManager = "gnome-session";  # Use "startplasma-x11" for Plasma
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
