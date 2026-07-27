{
  lib,
  inputs,
  writeShellScriptBin,
  runCommand,
  python312,
  callPackage,
  callPackages,
  fetchFromGitHub,
  makeWrapper,
  buildNpmPackage,
  buildEnv,
  inter,
  ...
}:
let
  inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;

  src = fetchFromGitHub {
    owner = "lfnovo";
    repo = "open-notebook";
    rev = "v1.13.0";
    hash = "sha256-Ly23IFq450YVzDHv7jEMYPqLFxCQhvNVDNvgJyKK1x4=";
  };

  open-notebook-api =
    let
      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = src; };
      overlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel";
      };
      overridedSrc = final: prev: {
        open_notebook = prev.app.overrideAttrs (old: {
          src =
            with lib.fileset;
            toSource {
              root = src;
              fileset = union [
                ./pyproject.toml
                ./open_notebook
              ];
            };
        });
      };
      fixLangdetect = final: prev: {
        langdetect = prev.langdetect.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [
            (final.resolveBuildSystem {
              setuptools = [ ]; # to use setuptools, seems to have a problem with the pyproject.toml of this package
            })
          ];
        });
      };

      pythonSet = (callPackage pyproject-nix.build.packages { python = python312; }).overrideScope (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.wheel
          overlay
          overridedSrc
          fixLangdetect
        ]
      );
      venv = pythonSet.mkVirtualEnv "open-notebook-api" workspace.deps.default;

      worker =
        let
          inherit (callPackages pyproject-nix.build.util { }) mkApplication;
          surreal-commands = mkApplication {
            inherit venv;
            package = pythonSet.surreal-commands;
          };
        in
        # runCommand "open-notebook-worker" { } ''
        #   mkdir -p $out/bin
        #   ln -sf ${api}/commands $out
        #   cat << EOF > $out/surreal-commands-worker
        #   cd $out
        #   ${surreal-commands}/bin/surreal-commands-worker --import-modules commands
        #   EOF
        #
        #   chmod +x $out/surreal-commands-worker
        #   ln -sf $out/surreal-commands-worker $out/bin/open-notebook-worker
        # '';
        surreal-commands;

      api =
        runCommand "open-notebook-api"
          {
            nativeBuildInputs = [ makeWrapper ];
            buildInputs = [ venv ];
          }
          ''
            mkdir -p $out/bin
            cp -L ${src}/run_api.py ${worker}/bin/surreal-commands-worker $out # copy deference executables so resources can be found
            cp -r ${src}/pyproject.toml ${src}/api ${src}/commands ${src}/open_notebook/database/migrations ${src}/prompts $out

            chmod +x $out/run_api.py

            makeWrapper $out/run_api.py $out/bin/open-notebook-api \
              --set-default PROMPTS_PATH $out/prompts

            makeWrapper $out/surreal-commands-worker $out/bin/open-notebook-worker \
              --set-default SURREAL_COMMANDS_MODULES commands

            patchShebangs $out/run_api.py
          '';
    in
    api;

  open-notebook-frontend = buildNpmPackage {
    name = "open-notebook-frontend";
    src = "${src}/frontend";
    npmDepsHash = "sha256-MLA3+U4N5bN2z6W/LNSAGGG3ygc23JN/NbJWb3m20kM=";
    postPatch = ''
      ln -sf ${inter}/share/fonts/truetype/* ./src/app/
      substituteInPlace src/app/layout.tsx \
        --replace-fail \
          'import { Inter } from "next/font/google";' \
          'import Inter from "next/font/local";'
      substituteInPlace src/app/layout.tsx \
        --replace-fail \
          'const inter = Inter({ subsets: ["latin"] });' \
          'const inter = Inter({src: "./InterVariable.ttf"});'

      substituteInPlace package.json \
          --replace-fail \
            '"private": true,' \
            '"private": true,
        "bin": {
          "open-notebook-frontend": ".next/standalone/server.js"
        },'
    '';
    postInstall = ''
      ln -sf $out/lib/node_modules/frontend/.next/static $out/lib/node_modules/frontend/.next/standalone/.next
      ln -sf $out/lib/node_modules/frontend/public $out/lib/node_modules/frontend/.next/standalone/public
    '';
  };

  open-notebook = writeShellScriptBin "open-notebook" ''
    mkdir -p open_notebook/database
    ln -sf ${open-notebook-api}/migrations open_notebook/database

    ${lib.getExe open-notebook-api} &
    ${open-notebook-api}/bin/open-notebook-worker >/dev/null &
    PORT=8502 exec ${lib.getExe open-notebook-frontend} 
  '';
in
buildEnv {
  name = "open-notebook";
  pathsToLink = [ "/bin" ];
  paths = [
    open-notebook-frontend
    open-notebook-api
    open-notebook
  ];
}
