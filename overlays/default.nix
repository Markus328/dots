{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  nixpkgs.overlays = [
    inputs.hyprland.overlays.default
    inputs.niri-flake.overlays.niri

    (final: prev:
      with final;
        {
          # Correct package for hyprland, because the NixOS module overrides like this
          # using this will avoid duplicate builds of hyprland binary
          hyprland = prev.hyprland.override {enableXWayland = true;};
          # hyprland plugins
          hyprlandPlugins =
            prev.hyprlandPlugins
            // {
              hypr-darkwindow = inputs.hyprdarkwindow.packages.${system}.default;
              hypr-dynamic-cursors = inputs.hypr-dynamic-cursors.packages.${system}.default;
            };

          # Caelestia
          caelestia-cli = inputs.caelestia-shell.inputs.caelestia-cli.packages.${system}.default;
          caelestia-shell = inputs.caelestia-shell.packages.${system}.default;
          noctalia-shell = inputs.noctalia-shell.packages.${system}.default;

          # Neovim (AstroVIM support)
          astrovim = runCommand "astrovim" {nativeBuildInputs = [makeWrapper];} ''
            mkdir -p $out/bin
            makeWrapper ${neovim}/bin/nvim $out/bin/nvim --prefix PATH ":" "${lib.makeBinPath [nodejs ripgrep cargo lazygit gcc tabby-agent go nil alejandra clang-tools shellcheck python3]}"
          '';
        }
        // (let
          patchArgs = ''
            # add specialisation flag after switch
            new_args=(--flake git+file://"''${NIXCONFIG:-$defaultConfig}")
            for arg in "$@"; do
                new_args+=("$arg")
                if [[ "$arg" == "switch" || "$arg" == "test" ]]; then
                    new_args+=(-c "''${NIXOS_SPEC:-default}")
                fi
            done
            set -- "''${new_args[@]}"
          '';
        in {
          # Home-manager wrapper
          home-manager-wrapper = writeShellApplication {
            name = "hm";
            runtimeInputs = [hmrice home-manager];
            text = ''
              defaultConfig=~/.config/home-manager
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
            ${patchArgs}

            sudo -s nixos-rebuild "$@"
          '';

          home-manager = inputs.home-manager.packages.${system}.default;
          hmrice = inputs.hm-ricing-mode.packages.${system}.hm-ricing-mode;

          nixos-chspec = writeShellApplication {
            name = "nixos-chspec";
            runtimeInputs = [nixos-rebuild-wrapper home-manager-wrapper];
            text = ''
              spec="''${1:-''${NIXOS_SPEC:-default}}"
              shift
              nrb switch -c "$spec" "$@" && hm switch -c "$spec" "$@"
            '';
          };
        }))
  ];
}
