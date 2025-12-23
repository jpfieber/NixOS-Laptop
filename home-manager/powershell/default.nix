{ config, lib, pkgs, ... }:

let
  cfg = config.apps.powershell;
in
{
  options.apps.powershell = {
    enable = lib.mkEnableOption "PowerShell configuration";
  };

  config = lib.mkIf cfg.enable {
    # PowerShell profile configuration
    home.file.".config/powershell/Microsoft.PowerShell_profile.ps1".text = ''
      # NixOS rebuild alias
      function nrs {
        sudo nixos-rebuild switch --flake ~/nixos-config#nixos
      }
      
      # Additional useful aliases
      Set-Alias -Name ll -Value Get-ChildItem
    '';
  };
}
