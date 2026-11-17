# Paperless-ngx document management on minifridge. Documents, search index and
# database live on the /srv data disk (see disko.nix) so the archive survives
# OS reinstalls and doesn't fill the OS drive. Web UI on :28981.
#
# Log in as `admin` (PAPERLESS_ADMIN_USER's default). The password comes from
# the sops secret, decrypted to /run/secrets at activation; paperless loads it
# via systemd LoadCredential, which reads the file as root, so the default
# root-owned secret is fine. Edit with:
#   sops secrets/minifridge.yaml   (key paperless-admin)
#
# CAVEAT, learned the hard way: passwordFile only applies on FIRST CREATION.
# Upstream's manage_superuser returns early ("a user admin already exists") if
# the account is there, so it never updates a password. Worse, the NixOS module
# records "$user:$password" in ${dataDir}/superuser-state and skips the command
# entirely when that matches -- so after editing this secret, the state file
# agrees with sops while the Django hash still holds the ORIGINAL password, and
# nothing ever reconciles them. Changing the secret alone does nothing.
#
# To actually change it, edit the secret, deploy, then reset the hash to match:
#   sudo cat /run/secrets/paperless-admin | paperless-manage shell -c '
#   import sys
#   from django.contrib.auth.models import User
#   pw = sys.stdin.read()
#   u = User.objects.get(username="admin")
#   u.set_password(pw); u.save()'
# Verify with u.check_password(pw) before and after -- it should flip to True.
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
        # it must match the proxied name -- including the scheme, since Caddy
        # now terminates TLS and Django builds absolute URLs from this.
        PAPERLESS_URL = "https://paperless.jenningsliamd.me";
      };
    };

    networking.firewall.allowedTCPPorts = [28981];
  };
}
