{...}: {
  programs.caelestia-dots = {
    hypr.variables.terminal = "footclient";
    foot = {
      settings = {
        main = {
          shell = "zsh";
          pad = "0x0";
        };
        colors = {
          alpha = 1;
          background = "000000";
        };
      };
    };
  };

  programs.foot = {
    enable = true;
    server.enable = true;
  };

  programs.hm-ricing-mode.apps = {
    foot.dest_dir = ".config/foot";
  };
}
