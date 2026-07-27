{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  secrets = import ./secrets.nix;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    inherit secrets;
  };
}
