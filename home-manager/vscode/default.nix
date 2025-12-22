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
        # User settings imported from your existing VS Code configuration
        userSettings = {
          "[nix]" = {
            # Disable automatic formatting for Nix files to avoid the slow
            # "Nix IDE" formatter running on save. Re-enable after configuring
            # a fast formatter/LSP (rnix/rnix-lsp) if you prefer auto-format.
            "editor.formatOnSave" = false;
          };
          "breadcrumbs.enabled" = true;
          "editor.codeActionsOnSave" = {
            "source.fixAll" = true;
            "source.organizeImports" = true;
          };
          "editor.formatOnPaste" = true;
          "editor.formatOnSave" = true;
          "editor.rulers" = [ 80 100 ];
          "editor.tabSize" = 2;
          "eslint.run" = "onSave";
          "eslint.validate" = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
          "explorer.compactFolders" = false;
          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;
          "files.exclude" = {
            "**/.DS_Store" = true;
            "**/.git" = true;
          };
          "files.insertFinalNewline" = true;
          "files.restoreUndoStack" = true;
          "files.trimTrailingWhitespace" = true;
          "files.watcherExclude" = {
            "**/.cache/**" = true;
            "**/.git/**" = true;
            "**/node_modules/**" = true;
            "**/target/**" = true;
          };
          "git.alwaysShowStagedChangesResourceGroup" = true;
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          "github.copilot.editor.enableAutoCompletions" = true;
          "github.copilot.enable" = { "*" = true; };
          "python.formatting.blackArgs" = [ "--line-length" "88" ];
          "python.formatting.provider" = "black";
          "search.exclude" = {
            "**/node_modules" = true;
            "**/target" = true;
          };
          "telemetry.telemetryLevel" = "off";
          "terminal.integrated.commandsToSkipShell" = [
            "workbench.action.terminal.copySelection"
            "workbench.action.terminal.paste"
            "workbench.action.clipboardCopyAction"
            "workbench.action.clipboardPasteAction"
          ];
          "terminal.integrated.copyOnSelection" = true;
          "terminal.integrated.defaultProfile.linux" = "bash";
          "terminal.integrated.fontFamily" = "monospace";
          "terminal.integrated.fontSize" = 14;
          "update.mode" = "none";
          "window.restoreWindows" = "all";
          "workbench.editor.enablePreview" = false;
          "workbench.startupEditor" = "none";
        };

        # Extensions
        extensions = with pkgs.vscode-extensions; [
          # Nix language support
          jnoortheen.nix-ide

          # Python
          ms-python.python
          ms-python.vscode-pylance
          ms-python.debugpy

          # Formatters / linters
          esbenp.prettier-vscode
          dbaeumer.vscode-eslint

          # Git / SCM
          eamodio.gitlens
          mhutchie.git-graph

          # Remote / container / docker
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh

          # Markdown / note tooling
          davidanson.vscode-markdownlint
          foam.foam-vscode
          shd101wyy.markdown-preview-enhanced
          tomoki1207.pdf

          # Languages / LSPs
          rust-lang.rust-analyzer

          # Web / UI
          svelte.svelte-vscode

          # Productivity / misc
          streetsidesoftware.code-spell-checker
          yzhang.markdown-all-in-one
          editorconfig.editorconfig
          ms-vscode.powershell
          github.copilot
          github.copilot-chat
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # Marketplace extension entries must include `version` and `sha256` for
        # reproducible builds. Leave empty for now — add specific pinned
        # entries later if you want these installed declaratively.
      ];
      };
    };
  };
}
