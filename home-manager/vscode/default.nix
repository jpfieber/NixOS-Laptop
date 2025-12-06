{ config, lib, pkgs, ... }:

let
  cfg = config.apps.vscode;
in
{
  options.apps.vscode = {
    enable = lib.mkEnableOption "VSCode configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      
      # User settings
      userSettings = {
        # Editor settings
        "editor.formatOnSave" = true;
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;
        "editor.linkedEditing" = true;
        "editor.minimap.enabled" = true;
        "editor.tabSize" = 2;
        "editor.wordWrap" = "on";
        
        # Code actions
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
        
        # Terminal
        "terminal.integrated.fontFamily" = "monospace";
        "terminal.integrated.fontSize" = 14;
        
        # Files
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        
        # Git
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        
        # Workbench
        "workbench.colorTheme" = "Default Dark Modern";
        "workbench.iconTheme" = "vs-seti";
        
        # Disable telemetry and updates (managed by Nix)
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
      };
      
      # Extensions
      extensions = with pkgs.vscode-extensions; [
        # Nix language support
        jnoortheen.nix-ide
        
        # Python
        ms-python.python
        ms-python.vscode-pylance
        
        # Node.js / JavaScript / TypeScript
        dbaeumer.vscode-eslint
        
        # PowerShell
        ms-vscode.powershell
        
        # Git
        eamodio.gitlens
        
        # General development
        editorconfig.editorconfig
        
        # Markdown
        yzhang.markdown-all-in-one
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # Add additional extensions from marketplace here
        # Format: { name = "extension-name"; publisher = "publisher"; version = "x.x.x"; sha256 = "..."; }
      ];
    };
  };
}
