# Real TLS certificates for the internal services, via Let's Encrypt and the
# ACME DNS-01 challenge against Cloudflare (which hosts jenningsliamd.me).
#
# DNS-01 rather than HTTP-01 on purpose: the challenge is answered by writing a
# TXT record, so Let's Encrypt never has to reach this box. Nothing is exposed
# to the internet, the names don't need public A records, and one wildcard
# covers every service so adding one later needs no new issuance.
#
# The certificate is NOT a repo secret -- lego fetches it at runtime into
# /var/lib/acme and renews it on a timer. The only secret is the Cloudflare API
# token, which sops decrypts to /run/secrets at activation.
#
# One-time setup BEFORE deploying this:
#   1. Cloudflare dashboard -> My Profile -> API Tokens -> Create Token,
#      template "Edit zone DNS", scoped to the jenningsliamd.me zone only.
#   2. sops secrets/minifridge.yaml
#      Add a key in EnvironmentFile syntax (lego reads it as env vars):
#        cloudflare-dns-token: |
#          CF_DNS_API_TOKEN=<token>
# sops-nix validates the manifest at BUILD time, so until that key exists the
# whole minifridge build fails with "the key 'cloudflare-dns-token' cannot be
# found" -- it can't half-deploy.
_: {
  flake.nixosModules.acme = {config, ...}: {
    sops.secrets."cloudflare-dns-token" = {};

    security.acme = {
      acceptTerms = true;
      defaults.email = "jenningsliamd@gmail.com";

      # Named for the zone, not the wildcard, so the state directory is a plain
      # /var/lib/acme/jenningsliamd.me with no "*" in the path.
      certs."jenningsliamd.me" = {
        # Covers jellyfin./files./paperless./pihole./home. -- one label deep,
        # which is all a wildcard matches and all we use.
        domain = "*.jenningsliamd.me";
        dnsProvider = "cloudflare";
        # systemd reads EnvironmentFile as root before dropping privileges, so
        # the default root-owned 0400 secret is readable as-is.
        environmentFile = config.sops.secrets."cloudflare-dns-token".path;
        # Caddy is the only consumer: it terminates TLS for every service, and
        # the backends stay plain HTTP on localhost.
        group = "caddy";
        # Caddy does not reliably notice cert files changing underneath it.
        reloadServices = ["caddy.service"];
      };
    };
  };
}
