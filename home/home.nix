{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hm-ricing-mode.homeManagerModules.hm-ricing-mode
    ./caelestia
    ./hosts/nixos-desktop-notebook
    ./fonts.nix
    ./kblayout.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home.username = "markus";
  home.homeDirectory = "/home/markus";
  home.stateVersion = "25.11";
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initContent = ''
      source ~/.zshrc
    '';
    loginExtra = ''source .zlogin'';
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.hm-ricing-mode = {
    enable = true;
    apps.systemd.dest_dir = ".config/systemd/user";
  };

  programs.home-manager = {
    enable = true;
  };
  services.udiskie = {
    enable = true;
    settings = {
      # workaround for
      # https://github.com/nix-community/home-manager/issues/632
      program_options = {
        # replace with your favorite file manager
        file_manager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      };
    };
  };

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Markus328";
    userEmail = "markus328@tutanota.com";
    aliases = {
      s = "status";
    };
    extraConfig = {
      credential.helper = "${
        pkgs.git-credential-keepassxc
      }/bin/git-credential-keepassxc";
    };
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [mpris];
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = ["zathura.desktop"];
    "video/mp4" = ["mpv.desktop"];
    "image/png" = ["imv.desktop"];
    "image/jpeg" = ["imv.desktop"];
    "text/plain" = ["nvim.desktop"];

    "text/x-csrc" = ["nvim.desktop"];
    "text/x-lua" = ["nvim.desktop"];
    "text/x-c++src" = ["nvim.desktop"];
    "text/x-chdr" = ["nvim.desktop"];
    "text/markdown" = ["obsidian.desktop"];
    "inode/directory" = ["nvim.desktop"];
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  home.packages = with pkgs; [
    gcr
    libnotify
    foot
    tmux
    zathura
    obsidian
    yt-dlp
    shellcheck
    keepassxc
    astrovim
    home-manager-wrapper
    imv

    pavucontrol
  ];
}
