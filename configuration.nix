# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [
      # Hardware configuration
      ./hardware-configuration.nix
      
      # Modular configuration
      ./modules/system.nix
      ./modules/desktop.nix
      ./modules/services.nix
      ./modules/storage.nix
      ./modules/packages.nix
      ./modules/users.nix
    ];
}
