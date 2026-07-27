{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openwatchparty";
  version = "0.1.0";

  src = "${fetchFromGitHub {
    owner = "mhbxyz";
    repo = "OpenWatchParty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zl8TKYeCbq0FGPrUx9cG4EuqVnX0SEt3TcsxndByrhk=";
  }}/src/server";

  cargoHash = "sha256-Elx2TSuGJhPpT1JSIc1fstRCUnro/QOUG6V5aGsDeQ0=";

  meta = {
    mainProgram = "session-server";
    description = "Server for OpenWatchParty: Jellyfin plugin that enables synchronized media playback across multiple clients";
    homepage = "https://mhbxyz.github.io/OpenWatchParty";
    license = lib.licenses.mit;
  };
})
