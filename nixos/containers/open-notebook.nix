{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  containers.open-notebook = {
    autoStart = true;
    privateUsers = "pick";
    bindMounts = {
      data = {
        mountPoint = "/data:idmap";
        hostPath = "/userdata/@workspace/open-notebook/data";
        isReadOnly = false;
      };
    };
    config =
      { config, lib, ... }:
      {
        nixpkgs.config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "surrealdb"
          ];
        nixpkgs.overlays = [
          (final: prev: {
            surrealdb =
              with prev;
              rustPlatform.buildRustPackage (finalAttrs: {
                pname = "surrealdb";
                version = "2.6.5";

                __structuredAttrs = true;

                src = fetchFromGitHub {
                  owner = "surrealdb";
                  repo = "surrealdb";
                  tag = "v${finalAttrs.version}";
                  hash = "sha256-oWW7dIMv2YJSZKLUNlk04LX+h610M0whsRTxZIzLT6Q=";
                };

                cargoHash = "sha256-Cg4zW18dH6fFiIheA6/8SWYYZFfDdo/JUFfeFTx2W1k=";

                # Upstream hard-codes `aarch64-linux-gnu-gcc` in `.cargo/config.toml`.
                # Remove it so Cargo uses nixpkgs' wrapped C toolchain instead.
                postPatch = ''
                  rm .cargo/config.toml
                '';

                buildNoDefaultFeatures = true;
                buildFeatures = [
                  "allocator"
                  "allocation-tracking"
                  "http"
                  "scripting"
                  "storage-mem"
                  "storage-surrealkv"
                  "storage-rocksdb"
                ];

                env = {
                  PROTOC = "${protobuf}/bin/protoc";
                  PROTOC_INCLUDE = "${protobuf}/include";
                  ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
                  ROCKSDB_LIB_DIR = "${rocksdb}/lib";
                };

                nativeBuildInputs = [
                  pkg-config
                  rustPlatform.bindgenHook
                ];

                buildInputs = [
                  openssl
                ];

                doCheck = false;

                checkFlags = [
                  # requires docker
                  "--skip=database_upgrade"
                ];

                __darwinAllowLocalNetworking = true;

                passthru.tests.version = testers.testVersion {
                  package = finalAttrs.finalPackage;
                  command = "surreal version";
                };
              });
          })
        ];

        services.surrealdb = {
          enable = true;
          dbPath = "rocksdb:///data/surrealdb/open-notebook.db";
          extraFlags = [
            "--user"
            "root"
            "--pass"
            "root"
          ];
        };

        # for some reason, surrealdb fails with coredump only in the systemd service. This workaround disables many protections to allow it run, maybe a bad idea.
        systemd.services.surrealdb.serviceConfig =
          let
            cfg = config.services.surrealdb;
          in
          lib.mkForce {
            ExecStart = "${cfg.package}/bin/surreal start --bind ${cfg.host}:${toString cfg.port} ${lib.strings.concatStringsSep " " cfg.extraFlags} -- ${cfg.dbPath}";
            Restart = "on-failure";
            StateDirectory = "surrealdb";
          };

        systemd.services.open-notebook = {
          enable = true;
          wantedBy = [ "multi-user.target" ];
          after = [ "surrealdb.service" ];

          serviceConfig = {
            EnvironmentFile = "/data/open-notebook/.env";
            ExecStart = lib.getExe' pkgs.open-notebook "open-notebook";
            WorkingDirectory = "/data/open-notebook";
          };
        };

        services.postgresql = {
          enable = true;
          dataDir = "/data/litellm/db/18/docker";
          package = pkgs.postgresql_18;

          initialScript = pkgs.writeText "psql-setup-user" ''
            CREATE USER root WITH SUPERUSER PASSWORD 'root';
            CREATE DATABASE litellm OWNER root;
          '';
        };
      };
  };

  virtualisation.oci-containers.containers.litellm = {
    image = "docker.litellm.ai/berriai/litellm:main-stable";
    ports = [ "4000:4000" ];

    environment = {
      DATABASE_URL = "postgresql://root:root@localhost:5432/litellm";
    };

    cmd = [ "--config=/app/config.yaml" ];
    volumes = [
      "/userdata/@workspace/open-notebook/data/litellm/config.yaml:/app/config.yaml"
    ];

    extraOptions = [ "--network=host" ];
    environmentFiles = [ config.sops.secrets.litellm-secrets.path ];
  };
}
