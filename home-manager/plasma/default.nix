{ config, lib, pkgs, ... }:

with lib;

let
  # Import the generated plasma configuration
  plasmaConfig = import ./generated.nix;
in
{
  options.apps.plasma = {
    enable = mkEnableOption "KDE Plasma configuration";
  };

  config = mkIf config.apps.plasma.enable (
    # Merge the generated plasma configuration
    plasmaConfig
  );
}
