{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  udev,
  fuse3,
  isDebug ? false,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vuinputd";
  version = "0.3.2-git";

  buildType =
    if isDebug
    then "debug"
    else "release";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    # breakpointHook
  ];
  buildInputs = [udev fuse3];

  src = fetchFromGitHub {
    owner = "joleuger";
    repo = "vuinputd";
    rev = "8c40fdc12005319ea16dceb752a8822abfc6039a";
    hash = "sha256-8Q34B04BngZqRLyixeFq8F1t5wFnk6JpaG3EEbgKRcU=";
  };

  cargoHash = "sha256-nJw9bRh6Yn9g1H5SeoT6zxgZLCqV3AtAs9gMfE+P+CU=";

  # Recent versions of fuse3 can also have libfuse_* types
  postPatch = ''
    substituteInPlace cuse-lowlevel/build.rs \
      --replace-fail '.allowlist_type("(?i)^fuse.*")' '.allowlist_type("(?i)^(fuse|libfuse).*")'
  '';

  postInstall = ''
    mkdir -p $out/lib/udev/rules.d
    mkdir $out/lib/udev/hwdb.d
    cp vuinputd/udev/*.rules $out/lib/udev/rules.d/
    cp vuinputd/udev/*.hwdb $out/lib/udev/hwdb.d/
  '';
  
    meta.mainProgram = "vuinputd";
})
