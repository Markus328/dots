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
  google-fonts,
  ...
}:
let
  inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;

  src = fetchFromGitHub {
    owner = "lfnovo";
    repo = "open-notebook";
    rev = "62b071b9172a2c823ddd918e0947a782df63be13";
    hash = "sha256-PpQgKghFSHad6uF9vPlFhpMbrf2bFHZft3eHwy9NM2E=";
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

  open-notebook-frontend =
    let

      fonts = google-fonts.override {
        fonts = [
          "InstrumentSans"
          "BricolageGrotesque"
          "SplineSansMono"
        ];
      };

    in
    buildNpmPackage {
      name = "open-notebook-frontend";
      src = "${src}/frontend";
      npmDepsHash = "sha256-gwxGxzYt1dgo0iYv8qa9dl1GrAhoLkZOE01m7KuZE0g=";
      postPatch = ''
        # Replace network fonts to to local fonts
        ln -sf ${fonts}/share/fonts/truetype/* src/app/
        substituteInPlace src/app/layout.tsx \
          --replace-fail \
            $'import {\n  Bricolage_Grotesque,\n  Instrument_Sans,\n  Spline_Sans_Mono,\n} from "next/font/google";' \
            'import Fonts from "next/font/local"' \
          --replace-fail \
            $'const instrumentSans = Instrument_Sans({\n  subsets: ["latin"]' \
            $'const instrumentSans = Fonts({\n  src: "./InstrumentSans[wdth,wght].ttf"' \
          --replace-fail \
            $'const bricolageGrotesque = Bricolage_Grotesque({\n  subsets: ["latin"],\n  weight: ["600", "700"]' \
            $'const bricolageGrotesque = Fonts({\n  src: "BricolageGrotesque[opsz,wdth,wght].ttf"' \
          --replace-fail \
            $'const splineSansMono = Spline_Sans_Mono({\n  subsets: ["latin"]' \
            $'const splineSansMono = Fonts({\n  src: "SplineSansMono[wght].ttf"'

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

    ${lib.getExe' open-notebook-api "open-notebook-api"} &
    ${open-notebook-api}/bin/open-notebook-worker >/dev/null &
    PORT=8502 exec ${lib.getExe' open-notebook-frontend "open-notebook-frontend"}
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
