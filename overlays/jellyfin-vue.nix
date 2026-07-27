{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpmConfigHook,
  fetchPnpmDeps,
  pnpm,
  nodejs,
  breakpointHookCntr,
  cntr,
  ...
}:

let

  pnpm11_9 = pnpm.override {
    version = "11.9.0";
    hash = "sha256-K1Z6pmAmI4B4rC4KM77D/r1g6WKYeqxpdFbzGAgZsoc=";
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "jellyfin-vue";
  version = "7f9101399d603d6b5d3b0f7009f7f8164e81ead3";
  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-vue";
    rev = finalAttrs.version;
    hash = "sha256-sGks+ZUT7kTY9GNJ9FHc+7X3yYecBjbPz+Nl5SPzC+w=";
  };

  pnpmInstallFlags = [
    "--no-optional"
    "--cpu=x64"
    "--os=linux"
  ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm11_9
    breakpointHookCntr
    cntr
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmInstallFlags
      ;
    nativeBuildInputs = [
      breakpointHookCntr
      nodejs
    ];
    postPatch = "pnpmInstallFlags=($pnpmInstallFlags)";
    pnpm = pnpm11_9;
    fetcherVersion = 2;
    hash = "sha256-C9gt844L2DujwQNlrIJ0sf5xsKiCPcAqXtUWaOK00zU=";
  };

  # postPatch = ''
  #   exit 1
  # '';
  postPatch = ''
    pnpmInstallFlags=($pnpmInstallFlags)
    # substituteInPlace pnpm-workspace.yaml \
    #   --replace-fail 'esbuild: true' 'esbuild: false'
    exit 1
  '';
  buildPhase = ''
    cd packages/frontend
    pnpm build
  '';

  installPhase = ''
    mkdir -p $out/share/jellyfin-web
    cp -rf dist/* $out/share/jellyfin-web
  '';
})
