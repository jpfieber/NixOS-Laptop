{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.jpfieber = {
    isNormalUser = true;
    description = "Joseph Fieber";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # This block enables and configures Home Manager for the specified user
  home-manager.users.jpfieber = import ../home-manager/home.nix;
}
