# Paperless-ngx document management on minifridge. Documents, search index and
# database live on the /srv data disk (see disko.nix) so the archive survives
# OS reinstalls and doesn't fill the OS drive. Web UI on :28981.
#
# The admin password is read at service start from a runtime file (never enters
# the Nix store); create it before first use, readable by the paperless user:
#   printf pw | sudo install -Dm600 -o paperless /dev/stdin /etc/paperless/admin.pw
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
