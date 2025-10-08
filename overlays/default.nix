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

    (final: prev:
      with final; {
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

        # Neovim (AstroVIM support)
        astrovim = runCommand "astrovim" {nativeBuildInputs = [makeWrapper];} ''
          mkdir -p $out/bin
          makeWrapper ${neovim}/bin/nvim $out/bin/nvim --prefix PATH ":" "${lib.makeBinPath [nodejs ripgrep cargo lazygit gcc tabby-agent go nil alejandra clang-tools shellcheck]}"
        '';

        # Home-manager wrapper
        home-manager-wrapper = writeShellScriptBin "hm" ''
          if ${hmrice}/bin/hmrice status | grep -q "RICING"; then
             echo "Unrise first (hmrice unrice), then run again"
          else
            ${home-manager}/bin/home-manager --flake git+file://''${NIXCONFIG:-~/.config/home-manager} $@
          fi
        '';

        # nixos-rebuild wrapper
        nixos-rebuild-wrapper = writeShellScriptBin "nrb" ''
          sudo nixos-rebuild --flake git+file:''${NIXCONFIG:-/etc/nixos} $@
        '';

        home-manager = inputs.home-manager.packages.${system}.default;
        hmrice = inputs.hm-ricing-mode.packages.${system}.hm-ricing-mode;
      })
  ];
}
