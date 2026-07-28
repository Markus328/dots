{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # This host will be a headless one run in a container or VM, just for remote access.
  # Usually will be exposed to the web, as well as controlled from a smartphone or tablet.
  # You will not want this as your main system, it's just a second temporary OS for emergency
  # This host requires a correct external managment of devices, such as /dev/uinput and /dev/dri
  # Also, mount the dotfiles in /etc/dotfiles and optionally mount a flatpak lib dir in /var/lib/flatpak

  boot.isContainer = true;
  boot.isNspawnContainer = true; # FIX: Remove this!
  console.enable = true;

  environment.systemPackages = with pkgs; [
    libinput
  ];

  environment.sessionVariables.NIXCONFIG = "/etc/dotfiles";

  services.seatd.enable = true;
  systemd.services = {
    seatd = {
      serviceConfig.Environment = [ "SEATD_VTBOUND=0" ];
    };

    # This came out from a really annoying issue about not being to able to run almost
    # any container solution inside this host if runinng inside a nspawn container.
    # Kernel disallows mounting a procfs using a nested user ns, due to a masked procfs on /proc
    # on nspawn user,mount,pid ns.
    # Mounting an unmasked procfs from the higher level namespaces would allow mounting procfs inside nested ns.
    # About security issues, I THINK trusting on private-users + another layer of of user ns + permissions in /proc would be enough
    fix-nested-container-proc = lib.mkIf config.boot.isNspawnContainer {
      description = "Fix bubblewrap procfs issue in nspawn container";
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "fix-procfs" ''
          mkdir -p /proc2
          ${lib.getExe pkgs.mount} -t proc proc /proc2
          # This last an issue of bwrap on flatpak where it for some reason
          # wants to write on /proc/sys/user but get error of read-only filesystems
          # not aware if some security issue would happen, but mounting a raw procfs
          # as did before is much worse anyway
          ${lib.getExe pkgs.mount} -o remount,rw /proc/sys
        '';
        RemainAfterExit = "yes";
      };
    };
  };

  users.users.markus = {
    extraGroups = lib.mkForce [ "seat" ];
    linger = true;
    initialPassword = "remote";
    packages = [ pkgs.home-manager-wrapper ];
  };

  systemd.user.services = {
    session-headless = {
      unitConfig = {
        Description = "Run a headless session";
      };

      wantedBy = [ "default.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
      before = [ "graphical-session.target" ];

      serviceConfig = {
        Environment = [
          "WLR_RENDERER=vulkan"
          "WLR_BACKENDS=headless,libinput"
          "WLR_LIBINPUT_NO_DEVICES=1"
        ];
        ExecStart = "${lib.getExe pkgs.bash} -l -c 'exec /run/current-system/sw/bin/driftwm-session'";
        Restart = "on-failure";
        RestartSec = "3s";
      };
    };
  };
  #   fix-session-input = {
  #     unitConfig = {
  #       Description = "Workaround for input hotplug when using vuinputd and sunshine";
  #     };
  #     wantedBy = ["sunshine.service"];
  #     serviceConfig = {
  #       ExecStart = pkgs.writeShellScript "fix-session-input" ''
  #         sleep 3
  #         checkFile="''${XDG_RUNTIME_DIR}/session-headless-first-run"
  #         touch "$checkFile"
  #         if [[ "$(cat $checkFile)" != "1" ]]; then
  #           echo 1 > "$checkFile"
  #           ${pkgs.systemd}/bin/systemctl --user restart session-headless
  #         fi
  #       '';
  #     };
  #   };
  # };

  services.sunshine = {
    enable = true;
    autoStart = true;
    settings = {
      port = 55000;
      system_tray = false;
      max_bitrate = 10000;

      capture = "wlr";

      qp = 34;
      encoder = "quicksync";
      qsv_preset = "veryfast";
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt # QSV
    ];
  };

  services.openssh.ports = [
    8022
  ];

  networking.useDHCP = false;
  networking.hostName = "nixos-remote";

  services.flatpak.enable = true;
}
