{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [54995 55000 55001 55021];
    allowedUDPPortRanges = [
      {
        from = 55009;
        to = 55011;
      }
      {
        from = 15011;
        to = 15021;
      }
    ];
  };

  services.udev.packages = [
    pkgs.vuinputd
  ];

  systemd.services.vuinputd = {
    enable = true;
    wantedBy = ["multi-user.target"];
    unitConfig = {
      Description = "Virtual input (/dev/vuinput) daemon";
    };
    serviceConfig = {
      Type = "exec";
      ExecStartPre = pkgs.writeShellScript "mount-tmpfs-dev-input" ''
        mkdir -p /run/vuinputd/vuinput/dev-input
        ${lib.getExe pkgs.mount} -t tmpfs -o rw,dev,nosuid tpmfs /run/vuinputd/vuinput/dev-input
      '';
      ExecStart = "${lib.getExe pkgs.vuinputd} --major 120 --minor 414795 --placement on-host";
      ExecStopPost = pkgs.writeShellScript "umount-dev-input" ''
        ${lib.getExe pkgs.umount} /run/vuinputd/vuinput/dev-input
      '';
      Restart = "on-failure";
      DeviceAllow = "char-* rwm";

      Environment = [
        "RUST_LOG=debug"
      ];
    };
  };
  systemd.services.vuinputd-chmod = {
    unitConfig.Description = "Chmod 666 the /dev/vuinput";
    wantedBy = ["vuinputd.service"];
    after = ["vuinputd.service"];

    serviceConfig = {
      ExecStart = pkgs.writeShellScript "chmod-vuinput" ''
        sleep 2 && chmod 666 /dev/vuinput
      '';
    };
  };
  systemd.services."container@nixos-remote" = {
    bindsTo = ["vuinputd.service"];
    after = ["vuinputd-chmod.service"];

    serviceConfig = {
      SystemCallFilter = [
        # "~@clock @cpu-emulation @debug @module @obsolete @raw-io @reboot @swap"
        # "@default @process"
      ];
    };
  };

  containers.nixos-remote = rec {
    autoStart = true;
    privateUsers = "no";

    allowedDevices = [
      {
        node = "/dev/dri";
        modifier = "rw";
      }
      {
        modifier = "rw";
        node = "/dev/dri/renderD128";
      }
      {
        modifier = "rw";
        node = "/dev/dri/card1";
      }
      {
        node = "/dev/vuinput";
        modifier = "rw";
      }
      {
        node = "char-input";
        modifier = "rw";
      }
    ];

    bindMounts = {
      dotfiles = {
        mountPoint = "/etc/dotfiles";
        hostPath = "/userdata/@dotfiles";
      };
      flatpak = {
        mountPoint = "/var/lib/flatpak";
        isReadOnly = false;
      };
      dri = {
        mountPoint = "/dev/dri";
        isReadOnly = false;
      };

      vuinput = {
        mountPoint = "/dev/uinput";
        hostPath = "/dev/vuinput";
        # hostPath = "/dev/uinput";
        isReadOnly = false;
      };
      vuinput-udev = {
        mountPoint = "/run/udev";
        hostPath = "/run/vuinputd/vuinput/udev";
        isReadOnly = false;
      };

      vuinput-dev = {
        mountPoint =
          if privateUsers == "no"
          then "/dev/input"
          else "/dev/input:idmap";
        hostPath = "/run/vuinputd/vuinput/dev-input";
        isReadOnly = false;
      };
      # input-dev = {
      #   mountPoint = "/dev/input";
      #   hostPath = "/dev/input";
      #   isReadOnly = false;
      # };
    };

    # Use the flake.nix nixos-remote as host, but rename the path to nixosConfigurations.container
    # and add boot.isNspawnContainer to enable the container to boot.
    # Note that a container will not always be a nspawn one.
    flake = "${pkgs.runCommand "nixos-remote-flake" {
        # nativeBuildInputs = [pkgs.breakpointHook];
      } ''
        mkdir -p $out
        cp -r ${builtins.path {
          path = ../..;
          name = "dotfiles";
        }}/* $out
        chmod -R 744 $out

        sed -i 's/nixosConfigurations."nixos-remote"/nixosConfigurations."container"/' $out/flake.nix
        sed -i '/system.stateVersion =/i\
          boot.isNspawnContainer = true;' $out/nixos/configuration.nix
      ''}";
  };
}
