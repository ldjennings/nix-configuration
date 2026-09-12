# Paperless-ngx document management on minifridge. Documents, search index and
# database live on the /srv data disk (see disko.nix) so the archive survives
# OS reinstalls and doesn't fill the OS drive. Web UI on :28981.
#
# The admin password comes from the sops secret, decrypted to /run/secrets at
# activation. Paperless loads it via systemd LoadCredential, which reads the
# file as root, so the default root-owned secret is fine. Edit with:
#   sops secrets/minifridge.yaml   (key paperless-admin)
_: {
  flake.nixosModules.minifridgePaperless = {config, ...}: {
    sops.secrets."paperless-admin" = {};

    services.paperless = {
      enable = true;
      # listen on the LAN, not just localhost
      address = "0.0.0.0";
      passwordFile = config.sops.secrets."paperless-admin".path;
      # keep documents/index/db on the dedicated /srv data disk
      dataDir = "/srv/paperless";
      # let LAN users drop files into the consume directory for ingestion
      consumptionDirIsPublic = true;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        # correct link generation + CSRF/allowed-host when reached by name.
        # Fronted by Caddy (see caddy.nix), which passes this Host through, so
        # it must match the proxied name.
        PAPERLESS_URL = "http://paperless.minifridge.home";
      };
    };

    networking.firewall.allowedTCPPorts = [28981];
  };
}
