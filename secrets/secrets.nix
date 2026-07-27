{
  cloudflared-cert = {
    sopsFile = ./cloudflared.yaml;
    key = "cert";
  };
  cloudflared-jelly = {
    sopsFile = ./cloudflared.yaml;
    key = "tunnel-jelly";
  };
  cloudflared-owp = {
    sopsFile = ./cloudflared.yaml;
    key = "tunnel-owp";
  };
  cloudflared-jelly-cred = {
    sopsFile = ./cloudflared.yaml;
    key = "tunnel-jelly-cred";
  };
  cloudflared-owp-cred = {
    sopsFile = ./cloudflared.yaml;
    key = "tunnel-owp-cred";
  };

  litellm-secrets = {
    sopsFile = ./litellm.env;
    format = "dotenv";
  };

  avante-litellm-api-key = {
    sopsFile = ./keys.yaml;
    key = "avante_litellm_api_key";
  };
}
