{ config, lib, pkgs, ... }:

let
  cfg = config.apps.git;
in
{
  options.apps.git = {
    enable = lib.mkEnableOption "git configuration";
    
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Joseph Fieber";
      description = "Git user name";
    };
    
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "jpfieber@gmail.com";
      description = "Git user email";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        
        init.defaultBranch = "main";
        pull.rebase = false;
        credential.helper = "store";
        
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };
      };
    };
  };
}
