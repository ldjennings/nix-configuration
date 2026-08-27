# Paperless-ngx document management on minifridge. Documents, search index and
# database live on the /srv data disk (see disko.nix) so the archive survives
# OS reinstalls and doesn't fill the OS drive. Web UI on :28981.
#
# The admin password is loaded at service start via systemd LoadCredential,
# which reads the file as root -- so it just needs to exist and be root-readable
# (not owned by the paperless user). Create it before deploying, or the service
# fails with status=243/CREDENTIALS and deploy-rs rolls back:
#   printf pw | sudo install -Dm600 /dev/stdin /etc/paperless/admin.pw
_: {
  flake.nixosModules.minifridgePaperless = _: {
    services.paperless = {
      enable = true;
      # listen on the LAN, not just localhost
      address = "0.0.0.0";
      passwordFile = "/etc/paperless/admin.pw";
      # keep documents/index/db on the dedicated /srv data disk
      dataDir = "/srv/paperless";
      # let LAN users drop files into the consume directory for ingestion
      consumptionDirIsPublic = true;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        # correct link generation + CSRF/allowed-host when reached by name
        PAPERLESS_URL = "http://minifridge.local:28981";
      };
    };

    networking.firewall.allowedTCPPorts = [28981];
  };
}
