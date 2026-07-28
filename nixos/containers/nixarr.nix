{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.firewall = rec {
    allowedTCPPorts = [
      8989 # Sonarr
      50000 # Transmission Peer Listening Port
      8096 # Jellyfin
      3000
    ];

    allowedUDPPorts = allowedTCPPorts;
  };

  systemd.services =
    let
      genCloudService = tunnel-secret: name: {
        description = "Cloudflare tunnel for ${name} instance";
        wantedBy = [ "container@nixarr.service" ];
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.cloudflared} tunnel --config=${tunnel-secret} --no-autoupdate --origincert=${config.sops.secrets.cloudflared-cert.path} run";
        };
      };
    in
    {
      cloudflare-tunnel-jellyfin = genCloudService config.sops.secrets.cloudflared-jelly.path "Jellyfin";
      cloudflare-tunnel-owp = genCloudService config.sops.secrets.cloudflared-owp.path "OWP";
    };

  containers.nixarr = {
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
    ];

    autoStart = true;
    bindMounts = {
      data = {
        mountPoint = "/data";
        hostPath = "/userdata/@workspace/media-download/data";
        isReadOnly = false;
      };

      dri = {
        mountPoint = "/dev/dri";
        hostPath = "/dev/dri/";
        isReadOnly = false;
      };
    };
    config =
      {
        config,
        lib,
        ...
      }:
      {
        imports = [ inputs.nixarr.nixosModules.default ];

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        system.activationScripts = {
          copyJellyfinWeb = ''
            JELLYFIN_WEB_SRC=${pkgs.jellyfin-web}/share/jellyfin-web
            TARGET_DIR="/data/.state/jellyfin-web"


            if [ ! -d "$TARGET_DIR" ]; then
              mkdir -p "$TARGET_DIR"
              cp -r "$JELLYFIN_WEB_SRC"/* "$TARGET_DIR/"
              chown -R jellyfin: "$TARGET_DIR"
              chmod -R u+rw "$TARGET_DIR"
            fi
          '';
          setup-owp-vars = ''
            if [ ! -f /data/.state/owp-vars ]; then
              tee /data/.state/owp-vars <<< "ALLOWED_ORIGINS=http://localhost:8096"
            fi
          '';
        };

        nixarr = {
          enable = true;

          jellyfin =
            let
              jellyfin-mutable-webdir = pkgs.jellyfin.overrideAttrs (prev: {
                makeWrapperArgs = [
                  "--add-flags"
                  "--ffmpeg=${pkgs.jellyfin-ffmpeg}/bin/ffmpeg"
                  "--add-flags"
                  "--webdir=/data/.state/jellyfin-web"
                ];
              });
            in
            {
              enable = true;
              package = jellyfin-mutable-webdir;
            };
          transmission.enable = true;
          sonarr.enable = true;
          prowlarr.enable = true;
          recyclarr = {
            enable = true;
            configuration = {
              sonarr.anime-sonar-v4 = {
                base_url = "http://localhost:8989";
                api_key = "!env_var SONARR_API_KEY";

                include = [
                  { template = "sonarr-quality-definition-anime"; }
                  { template = "sonarr-v4-quality-profile-anime"; }
                  { template = "sonarr-v4-custom-formats-anime"; }
                ];
                custom_formats = [
                  {
                    trash_ids = [ "026d5aadd1a6b4e550b134cb6c72b3ca" ]; # Uncensored
                    assign_scores_to = [
                      {
                        name = "Remux-1080p - Anime";
                        score = 1;
                      }
                    ];
                  }
                  {
                    trash_ids = [ "418f50b10f1907201b6cfdf881f467b7" ]; # Dual Audio
                    assign_scores_to = [
                      {
                        name = "Remux-1080p - Anime";
                        score = 5;
                      }
                    ];
                  }
                ];
              };
            };
          };
        };

        # Dirty service for unpackerr
        systemd.services.unpackerr =
          let
            sonarr_api_key = "$(cat ${config.nixarr.stateDir}/api-keys/sonarr.key)";
          in
          {
            enable = true;
            wantedBy = [ "multi-user.target" ];

            unitConfig = {
              Description = "Unpacks media torrents for Sonarr/Radarr";
            };
            serviceConfig = {
              ExecStart = pkgs.writeShellScript "unpackerr-service" ''
                UN_SONARR_0_URL=http://localhost:8989 UN_SONARR_0_API_KEY=${sonarr_api_key} UN_SONARR_0_PATHS=/data ${lib.getExe pkgs.unpackerr}
              '';
            };
          };

        # Dirty service for OWP (OpenWatchParty)
        # Note that this server requires a jellyfin plugin.
        systemd.services.openwatchparty = {
          enable = true;
          wantedBy = [ "multi-user.target" ];

          unitConfig = {
            Description = pkgs.openwatchparty.meta.description;
          };
          serviceConfig = {
            EnvironmentFile = "/data/.state/owp-vars";
            ExecStart = lib.getExe pkgs.openwatchparty;
          };
        };

        # Fix transmission error when running inside container
        # https://github.com/NixOS/nixpkgs/issues/258793#issuecomment-3097629849
        systemd.services.transmission.serviceConfig = {
          RootDirectoryStartOnly = lib.mkForce null;
          RootDirectory = lib.mkForce null;
        };

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            vpl-gpu-rt # QSV
          ];
        };

        system.stateVersion = "25.05";
      };
  };
}
