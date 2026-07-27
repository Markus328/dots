{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  nixpkgs.overlays = [
    inputs.hyprland.overlays.default
    inputs.niri-flake.overlays.niri

    (
      final: prev:
      with final;
      {
        # Correct package for hyprland, because the NixOS module overrides like this
        # using this will avoid duplicate builds of hyprland binary
        hyprland = prev.hyprland.override { enableXWayland = true; };
        # hyprland plugins
        hyprlandPlugins = prev.hyprlandPlugins // {
          hypr-darkwindow = inputs.hyprdarkwindow.packages.${system}.default;
          hypr-dynamic-cursors = inputs.hypr-dynamic-cursors.packages.${system}.default;
        };

        # Caelestia
        caelestia-cli = inputs.caelestia-shell.inputs.caelestia-cli.packages.${system}.default;
        caelestia-shell = inputs.caelestia-shell.packages.${system}.default;
        noctalia-shell = inputs.noctalia-shell.packages.${system}.default;

        # Neovim (AstroVIM support)
        astrovim = runCommand "astrovim" { nativeBuildInputs = [ makeWrapper ]; } ''
          mkdir -p $out/bin
          makeWrapper ${neovim}/bin/nvim $out/bin/nvim --prefix PATH ":" "${
            lib.makeBinPath [
              nodejs
              ripgrep
              cargo
              gnumake
              lazygit
              gcc
              tabby-agent
              go
              nil
              alejandra
              clang-tools
              shellcheck
              python3
            ]
          }"
        '';

        openwatchparty = callPackage ./openwatchparty.nix { };
        vuinputd = callPackage ./vuinputd { };
        open-notebook = callPackage ./open-notebook.nix { inherit inputs; };
        # litellm = callPackage ./litellm.nix { inherit inputs; };
        jellyfin-vue = callPackage ./jellyfin-vue.nix { };
        apollo = callPackage ./apollo { };
      }
      // (
        let
          patchArgs = ''
            new_args=(--flake git+file://"''${NIXCONFIG:-$defaultConfig}")

            if [[ "''${SPEC:-}" && "$SPEC" != "__default__" ]]; then
            tmp_args=()
            # add specialisation flag after switch
              for arg in "$@"; do
                  tmp_args+=("$arg")
                  if [[ "$arg" == "switch" || "$arg" == "test" ]]; then
                      tmp_args+=(-c "''${SPEC}")
                  fi
                  # cmd line option has greater priority than env var
                  if [[ "$arg" == "-c" || "$arg" == "--specialisation" ]]; then
                    tmp_args=("$@")
                    break
                  fi
              done
              new_args+=("''${tmp_args[@]}")
            else
              new_args+=("$@")
            fi

            set -- "''${new_args[@]}"
          '';
        in
        {
          # Home-manager wrapper
          home-manager-wrapper = writeShellApplication {
            name = "hm";
            runtimeInputs = [
              hmrice
              home-manager
            ];
            text = ''
              defaultConfig=~/.config/home-manager
              SPEC=''${HM_SPEC:-}
              [[ ! "''${SPEC:-}" && -f "$HOME/.local/share/home-manager/specialisation" ]] && SPEC=$(cat ~/.local/share/home-manager/specialisation)
              ${patchArgs}

                if hmrice status | grep -q "RICING"; then
                   echo "Unrice first (hmrice unrice), then run again"
                else
                  home-manager "$@"
                fi
            '';
          };

          # nixos-rebuild wrapper
          nixos-rebuild-wrapper = writeShellScriptBin "nrb" ''
            defaultConfig=/etc/nixos
            SPEC=''${NIXOS_SPEC:-}
            [[ ! "''${SPEC:-}" && -f "/etc/specialisation" ]] && SPEC=$(cat /etc/specialisation)
            ${patchArgs}

            sudo -s nixos-rebuild "$@"
          '';

          home-manager = inputs.home-manager.packages.${system}.default;
          hmrice = inputs.hm-ricing-mode.packages.${system}.hm-ricing-mode;

          nixos-chspec = writeShellApplication {
            name = "nixos-chspec";
            runtimeInputs = [
              nixos-rebuild-wrapper
              home-manager-wrapper
              getopt
            ];
            excludeShellChecks = [
              "SC2086"
              "SC2181"
            ];
            text = ''
              nixos_spec=
              hm_spec=
              spec=

              do_hm=false
              do_nixos=false
              use_default=false

              help(){
              echo "Usage: $0 [--help|-h] [--os|-O] [--home|-H] [--default|-d|<specialisation>]"
              exit 1
              }

              VALID_ARGS=$(getopt -o hOHd --long help,os,home,default -- "$@")

              if [[ $? -ne 0 ]]; then
              help
              fi

              eval set -- "$VALID_ARGS"

              while true; do
                case "$1" in
                  -h | --help)    help             ; ;;
                  -O | --os)      do_nixos=true    ; shift ;;
                  -H | --home)    do_hm=true       ; shift ;;
                  -d | --default) use_default=true ; shift ;;
                  --)             shift            ; break ;;
                esac
              done

              if [[ "''${1:-}" ]]; then
                spec="$1"
                shift
              fi

              if ! ($do_hm || $do_nixos); then
                do_hm=true
                do_nixos=true
              fi


              if ! $use_default; then
                if ! [[ "''${spec:-}" ]]; then
                  [[ -f "/etc/specialisation" ]] && nixos_spec="-c $(cat /etc/specialisation)"
                  [[ -f "$HOME/.local/share/home-manager/specialisation" ]] && hm_spec="-c $(cat ~/.local/share/home-manager/specialisation)"
                else
                  nixos_spec="-c $spec"
                  hm_spec="-c $spec"
                fi
              else
                export NIXOS_SPEC="__default__"
                export HM_SPEC="__default__"
              fi

              $do_nixos && nrb switch ''${nixos_spec:-} "$@"

              $do_hm && hm switch ''${hm_spec:-} "$@"
            '';
          };
        }
      )
    )
  ];
}
