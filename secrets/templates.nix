# Render secrets into a predictable location, useful for scripts or non-NixOS managed software
{
  config,
  lib,
  inputs,
  ...
}:
let
  createTemplates =
    secrets:
    lib.mergeAttrsList (
      map (
        s:
        let
          secret = if builtins.isAttrs s then s.secret else s;
          opts =
            if builtins.isAttrs s then
              (builtins.removeAttrs s [ "secret" ]) // { content = config.sops.placeholder."${s.secret}"; }
            else
              {
                content = config.sops.placeholder."${s}";
                mode = "400";
              };
        in
        {
          "${secret}" = opts;
        }
      ) secrets
    );
in
{
  imports = [ inputs.sops-nix.nixosModules.default ];

  sops.templates = createTemplates [
    {
      secret = "avante-litellm-api-key";
      mode = "444";
    }
  ];
}
