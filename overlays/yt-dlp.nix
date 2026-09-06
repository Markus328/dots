{
  yt-dlp,
  fetchFromGitHub,
  ...
}:
yt-dlp.overrideAttrs (
  final: prev: rec {
    version = "2026.08.19";
    src = fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      tag = version;
      hash = "sha256-BM5ZeGTmHq+1xH6G/zsuCtjLgYgfRA11ya0zIHK5p4g=";
    };
  }
)
