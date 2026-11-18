#!/usr/bin/env python3
"""Generate or check a qBittorrent WebUI password digest.

qBittorrent stores `WebUI\\Password_PBKDF2` as

    @ByteArray(<base64 salt>:<base64 derived key>)

where the key is PBKDF2-HMAC-SHA512 over the password with a random
16-byte salt, 100000 iterations, and a 64-byte output. Those parameters
were confirmed against qbittorrent-nox 5.2.2 by generating a digest for a
known password and logging in with it over the WebUI API.

The salt is fresh on every run, so generating twice from the SAME password
gives two different digests. That is the point of a salt, not a bug -- it
means two accounts with the same password do not share a hash, and a
precomputed table cannot be reused against them. It also means you cannot
tell whether you typed the password correctly by comparing two digests;
use `--check` instead, which re-derives using the salt stored inside the
digest you already have.

Usage:
    just qbt-hash     # prompt twice, print a digest to paste into sandbox.nix
    just qbt-check    # prompt once, verify against the digest in sandbox.nix
"""

import base64
import getpass
import hashlib
import hmac
import pathlib
import re
import sys

ITERATIONS = 100_000
KEY_LEN = 64
SALT_LEN = 16

SANDBOX = pathlib.Path(__file__).resolve().parent.parent / (
    "modules/system/services/sandbox.nix"
)


def derive(password: str, salt: bytes) -> bytes:
    return hashlib.pbkdf2_hmac(
        "sha512", password.encode(), salt, ITERATIONS, KEY_LEN
    )


def generate() -> int:
    first = getpass.getpass("New qBittorrent WebUI password: ")
    if not first:
        print("Empty password, aborting.", file=sys.stderr)
        return 1
    # Double entry is the only protection against a typo: once hashed, a
    # mistyped password is indistinguishable from the intended one.
    if first != getpass.getpass("Retype to confirm: "):
        print("Passwords do not match, nothing generated.", file=sys.stderr)
        return 1

    import os

    salt = os.urandom(SALT_LEN)
    digest = "{}:{}".format(
        base64.b64encode(salt).decode(),
        base64.b64encode(derive(first, salt)).decode(),
    )
    print("\nPaste this into Password_PBKDF2 in sandbox.nix:\n")
    print('              Password_PBKDF2 = "@ByteArray({})";'.format(digest))
    print("\nThen commit and `just deploy`. Changing it in the WebUI will not")
    print("stick: a non-empty serverConfig reinstalls the config on every start.")
    return 0


def stored_digest() -> "tuple[bytes, bytes] | None":
    """Pull the committed digest out of sandbox.nix."""
    if not SANDBOX.is_file():
        print("Cannot find {}".format(SANDBOX), file=sys.stderr)
        return None
    match = re.search(
        r'Password_PBKDF2\s*=\s*"@ByteArray\(([^:]+):([^)]+)\)"', SANDBOX.read_text()
    )
    if not match:
        print("No Password_PBKDF2 digest found in {}".format(SANDBOX), file=sys.stderr)
        return None
    try:
        return base64.b64decode(match.group(1)), base64.b64decode(match.group(2))
    except Exception as exc:  # noqa: BLE001 -- surface any malformed base64
        print("Digest in sandbox.nix is not valid base64: {}".format(exc), file=sys.stderr)
        return None


def check() -> int:
    parsed = stored_digest()
    if parsed is None:
        return 1
    salt, expected = parsed

    password = getpass.getpass("Password to check against sandbox.nix: ")
    # compare_digest rather than == so a wrong guess cannot be narrowed down
    # by timing. Barely matters locally, but it costs nothing.
    if hmac.compare_digest(derive(password, salt), expected):
        print("MATCH -- this is the password qBittorrent will accept.")
        return 0
    print("NO MATCH -- qBittorrent would reject this password.")
    return 1


if __name__ == "__main__":
    sys.exit(check() if "--check" in sys.argv[1:] else generate())
