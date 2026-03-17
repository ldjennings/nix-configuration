## Host Configuration Options

Modules in this flake that require per-host values (such as `host.username`,
`host.hostname`, and `host.flakeDirectory`) declare their dependencies by
importing `flake/modules/host-config.nix` directly. This file defines the
`host.*` option namespace as required NixOS options with no defaults.

NixOS deduplicates imports automatically, so even though multiple modules
import `host-config.nix`, the options are only defined once.

Each required option uses a `throw` default rather than `null`, meaning
accessing an unset option causes an immediate evaluation error with a clear
message indicating what needs to be set and where. The stack trace will show
which module triggered the error.

To satisfy these requirements, set the following in your host module:
```nix
host = {
  username = "your-username";
  hostname = "your-hostname";
  flakeDirectory = "/home/your-username/nix-configuration";
};
```

### Why a relative import rather than a flake-parts module

The natural approach would be to expose `hostConfig` as a flake-parts module
via `self.nixosModules.hostConfig` and import it in each dependent module like:
```nix
imports = [ self.nixosModules.hostConfig ];
```

However, this causes infinite recursion. The NixOS module system evaluates
`imports` before anything else — before `config`, before `_module.args`, and
before `specialArgs`. But `self` is provided via `_module.args`, which is part
of `config`. So accessing `self` in `imports` requires `config` to be
evaluated, which requires `imports` to be resolved first.

Another solution would be turning the relative import into an absolute import by
accessing `self` to get the base flake directory:

```nix
  imports = [ "${self}/flake/modules/host-config.nix" ];
```

A plain path import avoids this entirely: paths are static and resolved at
parse time, before any evaluation occurs.

### Adding new host-scoped options

If you need to add a new option to the `host.*` namespace, add it to
`flake/modules/host-config.nix` using the `requiredOption` helper from
`flake/modules/required-option.nix`. See existing options for examples.

### Adding new modules that depend on host options

Import `host-config.nix` at the top of your module:
```nix
{ config, lib, pkgs, ... }: {
  imports = [ ./modules/host-config.nix ];

  config = {
    # use config.host.* here
  };
}
```