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

  systemd.user.slices = {
    session = {
      Slice = {
        CPUWeight = 150;
        MemoryHigh = "512M";
      };
    };
  };
  systemd.user.services = {
    gnome-keyring.Service.Slice = "session.slice";
  };

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
    dotDir = config.home.homeDirectory + "/.config/zsh";
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
    enable = true;
    name = lib.mkDefault "Bibata-Modern-Ice";
    package = lib.mkDefault pkgs.bibata-cursors;
    size = 24;
  };

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Markus328";
      user.email = "markus328@tutanota.com";
      alias.s = "status";
      credential.helper = "${pkgs.git-credential-keepassxc}/bin/git-credential-keepassxc";
    };
  };

  programs.mpv = {
    enable = true;
    bindings = {
      "Ctrl+Shift+LEFT" = "sub-step -1";
      "Ctrl+Shift+RIGHT" = "sub-step 1";
      "-" = "multiply speed 1/1.1";
      "=" = "multiply speed 1.1";
      "_" = "multiply speed 0.5";
      "+" = "multiply speed 2.0";
      "p" = "show-progress";
      "P" = "script-binding webtorrent/toggle-info";
      "u" = "script-binding stats/display-stats";
      "U" = "script-binding stats/display-stats-toggle";
      ")" = "add audio-delay 0.100";
      "(" = "add audio-delay -0.100";
      "/" = "add volume -2";
      "'" = "add volume 2";
      "l" = "cycle mute";
      "t" = "cycle fullscreen";
      "o" = "ab-loop";
    };
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

  ];

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
  };

  programs.hm-ricing-mode = {
    enable = true;
    apps.systemd.dest_dir = ".config/systemd/user";
    apps.sunshine.dest_dir = ".config/sunshine";
    apps.udiskie.dest_dir = ".config/udiskie";
  };

  home.activation.set-x11-kblayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe pkgs.setxkbmap} -layout us -variant workman -option ctrl:swapcaps || true
  '';

  specialisation = {
    gaming.configuration = {
      xdg.dataFile."home-manager/specialisation".text = "gaming";
      home.activation.set-x11-kblayout = lib.mkForce (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe pkgs.setxkbmap} -layout br -variant abnt2 -option ctrl:swapcaps || true
        ''
      );
      services.easyeffects.enable = lib.mkForce false;
      services.udiskie.enable = lib.mkForce false;
    };
  };
}
