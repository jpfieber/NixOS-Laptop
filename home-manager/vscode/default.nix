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

      profiles.default = {
        # User settings
        userSettings = {
          # Editor & formatting
          "editor.formatOnSave" = true;
          "editor.formatOnPaste" = true;
          "editor.tabSize" = 2;
          "editor.rulers" = [ 80 100 ];
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = true;
            "source.fixAll" = true;
          };

          # Visual / UX
          "workbench.startupEditor" = "none";
          "workbench.editor.enablePreview" = false;
          "breadcrumbs.enabled" = true;
          "explorer.compactFolders" = false;

          # Files / performance
          "files.trimTrailingWhitespace" = true;
          "files.insertFinalNewline" = true;
          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;

          "files.watcherExclude" = {
            "**/.git/**" = true;
            "**/node_modules/**" = true;
            "**/target/**" = true;
            "**/.cache/**" = true;
          };

          "search.exclude" = {
            "**/node_modules" = true;
            "**/target" = true;
          };

          "files.exclude" = {
            "**/.DS_Store" = true;
            "**/.git" = true;
          };

          # Git / SCM
          "git.autofetch" = true;
          "git.enableSmartCommit" = true;
          "git.confirmSync" = false;
          "git.alwaysShowStagedChangesResourceGroup" = true;

          # Terminal
          "terminal.integrated.defaultProfile.linux" = "bash";
          "terminal.integrated.fontFamily" = "monospace";
          "terminal.integrated.fontSize" = 14;

          # Linting / language specifics
          "eslint.validate" = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
          "eslint.run" = "onSave";

          "python.formatting.provider" = "black";
          "python.formatting.blackArgs" = [ "--line-length" "88" ];

          # Session / restore
          "window.restoreWindows" = "all";
          "files.restoreUndoStack" = true;

          # Updates & telemetry (managed by Nix)
          "update.mode" = "none";
          "telemetry.telemetryLevel" = "off";

          # GitHub Copilot (install Copilot + Copilot Chat extension below)
          "github.copilot.enable" = {
            "*" = true;
          };
          "github.copilot.editor.enableAutoCompletions" = true;
        };

        # Extensions
        extensions = with pkgs.vscode-extensions; [
          # Nix language support
          jnoortheen.nix-ide

          # Python
          ms-python.python
          ms-python.vscode-pylance

          # Formatters / linters
          esbenp.prettier-vscode
          dbaeumer.vscode-eslint

          # Git / SCM
          eamodio.gitlens
          mhutchie.git-graph

          # Remote / container / docker
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh

          # Languages / LSPs
          rust-lang.rust-analyzer

          # Productivity / misc
          streetsidesoftware.code-spell-checker
          yzhang.markdown-all-in-one
          editorconfig.editorconfig
          ms-vscode.powershell
          github.copilot
          github.copilot-chat
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # Add additional extensions from marketplace here
        # Format: { name = "extension-name"; publisher = "publisher"; version = "x.x.x"; sha256 = "..."; }
      ];
      };
    };
  };
}
