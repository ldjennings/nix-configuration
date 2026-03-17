# custom-nix-code/required-option.nix
# Flake-parts module exposing requiredOption via flake.lib.
# Creates a required NixOS option that throws a clear error if not set.
#
# Usage from any NixOS module:
#   { self, lib, ... }: {
#     options.foo = self.lib.requiredOption {
#       name = "foo.bar";
#       type = lib.types.str;
#       usedFor = "something important";
#       suggestion = "\"some-value\"";
#       description = "What this option does.";
#       example = "some-value";
#     };
#   }
{ lib, ... }: {
  flake.lib.requiredOption = { name, type, usedFor, suggestion, description, example }:
    lib.mkOption {
      inherit type description example;
      default = throw ''

        ${name} is required but not set.
        Check the stack trace above to see which module requires it.

        Used for: ${usedFor}
        Suggested value: ${suggestion}

        Set it in your host module:
          ${name} = ${suggestion};
      '';
    };
}