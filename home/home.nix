{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.hm-ricing-mode.homeManagerModules.hm-ricing-mode
    inputs.zen-browser.homeModules.beta
    ./fonts.nix
    ./kblayout.nix

    ./caelestia
    ./niri
  ];

  programs.caelestia-dots.hypr.enable = lib.mkForce false; # Do not using Hyprland

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.man.generateCaches = true;

  programs.zen-browser.enable = true;

  home.username = "markus";
  home.homeDirectory = "/home/markus";
  home.stateVersion = "25.11";

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initContent = ''
      source ~/.zshrc
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.home-manager = {
    enable = true;
  };

  home.pointerCursor = {
    name = lib.mkDefault "Bibata-Modern-Ice";
    package = lib.mkDefault pkgs.bibata-cursors;
    size = 24;
  };

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      };
      device_config = [
        {
          id_uuid = "606b3d07-4bd2-4c7b-9987-4c5f7e2c8030";
          automount = false;
        }
      ];
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
      credential.helper = "${pkgs.git-credential-keepassxc}/bin/git-credential-keepassxc";
    };
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [ mpris ];
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "zathura.desktop" ];
    "video/mp4" = [ "mpv.desktop" ];
    "image/png" = [ "imv.desktop" ];
    "image/jpeg" = [ "imv.desktop" ];
    "text/plain" = [ "nvim.desktop" ];

    "text/x-csrc" = [ "nvim.desktop" ];
    "text/x-lua" = [ "nvim.desktop" ];
    "text/x-c++src" = [ "nvim.desktop" ];
    "text/x-chdr" = [ "nvim.desktop" ];
    "text/markdown" = [ "obsidian.desktop" ];
    "inode/directory" = [ "nvim.desktop" ];
  };

  services.easyeffects.enable = true;

  home.packages = with pkgs; [
    gcr
    libnotify
    foot
    wlr-randr
    pwvucontrol
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
    super-productivity

    adwaita-icon-theme
  ];

  programs.hm-ricing-mode = {
    enable = true;
    apps.systemd.dest_dir = ".config/systemd/user";
    apps.sunshine.dest_dir = ".config/sunshine";
    apps.udiskie.dest_dir = ".config/udiskie";
  };

  home.activation.set-x11-kblayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe pkgs.setxkbmap} -layout us -variant workman -option ctrl:swapcaps
  '';

  specialisation = {
    gaming.configuration = {
      xdg.dataFile."home-manager/specialisation".text = "gaming";
      home.activation.set-x11-kblayout = lib.mkForce (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe pkgs.setxkbmap} -layout br -variant abnt2 -option ctrl:swapcaps
        ''
      );
      services.easyeffects.enable = lib.mkForce false;
    };
  };
}
