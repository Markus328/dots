{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../baremetal-common.nix
    ../desktop-common.nix
    ../notebook-common.nix
  ];

  # Device-specific boot configuration
  boot.initrd.kernelModules = [
    "vmd"
  ];
  boot.loader.grub.extraConfig = "nvme_load=YES";

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowSuspendThenHibernate = "no";
  };

  systemd.user.services.fix-sunshine-absolute-input = lib.mkIf config.services.sunshine.enable {
    unitConfig = {
      Description = "Fix sunshine absotlute device offset on multi-monitor setup";
    };

    wantedBy = [ "sunshine.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart =
        let
          wlr-randr = lib.getExe pkgs.wlr-randr;
          jq = lib.getExe pkgs.jq;
        in
        pkgs.writeShellScript "fix-abs-input-sunshine" ''
          ${wlr-randr} --output HDMI-A-1 --off
          preferredPos="$(${wlr-randr} --json | ${jq} '.[] | select(.name == "eDP-1").position | "\(.x),\(.y)"' -r)"
          ${wlr-randr} --output eDP-1 --pos 0,0
          systemctl --user restart sunshine
          sleep 2 && ${wlr-randr} --output eDP-1 --pos "$preferredPos"
          ${wlr-randr} --output HDMI-A-1 --on
        '';
    };
  };

  # services.sunshine.settings = {
  #   output_name = 1;
  # };

  myContainers = {
    nixarr.enable = true;
    nixos-remote.enable = true;
    open-notebook.enable = true;
  };

  services.displayManager.sddm.enable = true;

  # Device-specific networking
  networking.hostName = "nixos-desktop-notebook";
}
