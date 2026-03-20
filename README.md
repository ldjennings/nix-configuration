# Liam's NixOS Configuration

A [dendritic](https://www.youtube.com/watch?v=-TRbzkw6Hjs) NixOS configuration built with [flake-parts](https://github.com/hercules-ci/flake-parts) and [home-manager](https://github.com/nix-community/home-manager).

## Structure
```
.
├── modules/
│   ├── home/                       # Home-manager modules (no rebuild needed)
│   │   ├── desktop/                # Graphical environment
│   │   │   ├── hyprland/           # Hyprland-specific config
│   │   │   │   ├── animations.nix
│   │   │   │   ├── default.nix     # Core config, startup, input, decorations
│   │   │   │   ├── face.jpg        # Profile picture for hyprlock
│   │   │   │   ├── hyprbinds.nix
│   │   │   │   ├── hypridle.nix
│   │   │   │   ├── hyprlock.nix
│   │   │   │   ├── pyprland.nix    # Scratchpad daemon
│   │   │   │   ├── scripts.nix     # brightness-gamma, toggle-light-filter
│   │   │   │   ├── waybar.nix
│   │   │   │   └── windowrules.nix
│   │   │   ├── niri/               # Niri-specific config
│   │   │   │   └── default.nix     # Core config, binds, window rules, startup
│   │   │   ├── wlogout/            # Logout menu
│   │   │   │   ├── icons/          # PNG icons for logout buttons
│   │   │   │   └── wlogout.nix
│   │   │   ├── gammastep.nix       # Automatic blue light filter
│   │   │   ├── rofi.nix            # App launcher
│   │   │   ├── swappy.nix          # Screenshot annotation
│   │   │   ├── swaync.nix          # Notification center
│   │   │   ├── theming.nix         # GTK/Qt theming, icon theme, stylix targets
│   │   │   ├── wayland-env.nix     # Wayland environment variables
│   │   │   └── xdg.nix             # MIME associations, user directories
│   │   ├── dev/
│   │   │   └── git.nix
│   │   ├── editors/
│   │   │   ├── helix.nix           # Primary editor
│   │   │   └── lsp.nix             # Language server installations
│   │   ├── personal/               # Project-specific tools
│   │   ├── shell/
│   │   │   ├── scripts/
│   │   │   │   ├── formula.nix     # FSAE inventory and KiCad utilities
│   │   │   │   └── hm-find.nix     # Finds HM backup files blocking rebuilds
│   │   │   ├── bat.nix
│   │   │   ├── eza.nix
│   │   │   ├── fzf.nix
│   │   │   └── zsh.nix
│   │   └── terminal/
│   │       ├── btop.nix
│   │       ├── fastfetch.nix
│   │       ├── htop.nix
│   │       ├── kitty.nix
│   │       └── yazi.nix
│   ├── hosts/
│   │   └── brick/                  # Framework 13 (12th gen Intel)
│   │       ├── hardware.nix        # Hardware-specific boot and kernel config
│   │       ├── home.nix            # Brick-specific HM config
│   │       ├── speaker-tuning.nix  # EasyEffects DSP for Framework speakers
│   │       ├── system.nix          # Flake-parts entry, module imports
│   │       └── user.nix            # User definition + HM wiring
│   ├── lib/
│   │   ├── host-config.nix         # Per-host option definitions (host.*)
│   │   └── required-option.nix     # Helper for required options with clear errors
│   ├── system/                     # NixOS modules (require rebuild to change)
│   │   ├── core/                   # Boot-level and fundamental system config
│   │   │   ├── appimageSupport.nix # binfmt handler for AppImage binaries
│   │   │   ├── boot-config.nix     # EFI bootloader, Plymouth, initrd
│   │   │   ├── default-editor.nix  # Neovim as $EDITOR fallback
│   │   │   ├── fonts.nix           # System font packages
│   │   │   ├── locale.nix          # Locale, timezone, console keymap
│   │   │   ├── nix-configuration.nix # Nix daemon settings, flake support
│   │   │   └── security.nix        # PAM, sudo, polkit
│   │   ├── desktop/
│   │   │   ├── input/
│   │   │   │   ├── input.nix       # keyd, libinput, XKB layout
│   │   │   │   ├── periphreals.nix # ratbagd, piper for gaming mice
│   │   │   │   └── pinyin-input.nix # fcitx5 Chinese input
│   │   │   ├── desktop-programs.nix # dconf, fuse, hyprland.enable etc.
│   │   │   ├── gaming.nix
│   │   │   ├── niri.nix            # Niri system module + portal config
│   │   │   ├── stylix.nix          # Base16 color scheme, fonts, wallpaper
│   │   │   └── thunar.nix
│   │   ├── hardware/
│   │   │   ├── intel-graphics.nix
│   │   │   ├── mount-services.nix  # gvfs, udisks2, smartd
│   │   │   └── printing.nix
│   │   ├── programs/
│   │   │   ├── cli-utils.nix       # Essential CLI tools for any shell session
│   │   │   ├── desktop-utils.nix   # Fundamental GUI tools for any desktop
│   │   │   └── sys-utils.nix       # Tools requiring hardware access or privileges
│   │   └── services/
│   │       ├── bluetooth.nix
│   │       ├── greetd.nix
│   │       ├── mullvad.nix
│   │       ├── networking.nix
│   │       ├── nfs.nix
│   │       ├── pipewire.nix
│   │       ├── power-saving.nix    # tlp, thermald, logind, sleep
│   │       ├── syncthing.nix
│   │       └── virtualization.nix
│   └── flake-parts.nix             # Top-level flake-parts module imports
├── wallpapers/
├── flake.lock
├── flake.nix
└── README.md
```

## Hosts

### brick
Framework 13 (12th gen Intel) laptop.

**Set in `hosts/brick/system.nix`:**
```nix
host = {
  username       = "liam";
  hostname       = "brick";
  flakeDirectory = "/home/liam/nix-configuration";
  gitUsername    = "Liam";
  gitEmail       = "your@email.com";
};
```

## Rebuilding
```bash
nh os switch --hostname brick   # switch to new config
nh os test --hostname brick     # test without making it the boot default
nh os build --hostname brick    # build without activating
```

Shell aliases:
```bash
fr    # switch
ft    # test
fu    # switch + update flake inputs
ncg   # nix-collect-garbage -- clean up old generations
```

## Host Configuration Options

Modules that require per-host values use the `host.*` option namespace,
defined in `lib/host-config.nix`.

### Available options

| Option                | Type   | Description                                  |
| --------------------- | ------ | -------------------------------------------- |
| `host.username`       | string | Primary user account name                    |
| `host.hostname`       | string | Machine hostname                             |
| `host.flakeDirectory` | string | Path to this flake, used by `nh`             |
| `host.gitUsername`    | string | Git commit author name                       |
| `host.gitEmail`       | string | Git commit author email                      |
| `host.compositor`     | enum   | Wayland compositor: `"niri"` or `"hyprland"` |

### Error handling

Each option uses a `throw` default — accessing an unset option causes an
immediate evaluation error with a clear message pointing to what needs to be
set and where.

### Adding new host-scoped options

Add to `lib/host-config.nix` using the `requiredOption` helper:
```nix
newOption = requiredOption {
  name        = "host.newOption";
  type        = lib.types.str;
  usedFor     = "description of what uses this";
  suggestion  = "\"example-value\"";
  description = "What this option controls.";
  example     = "example-value";
};
```

### Using host options in modules

In HM modules, receive `hostConfig` via `extraSpecialArgs`:
```nix
{ hostConfig, ... }: {
  programs.git.userName = hostConfig.gitUsername;
}
```

In NixOS modules, use `config.host`:
```nix
{ config, ... }: {
  networking.hostName = config.host.hostname;
}
```

## Theming

Theming is handled by [Stylix](https://github.com/danth/stylix) using a
base16 color scheme. To change the scheme, edit `system/desktop/stylix.nix`:
```nix
# Use a community scheme from tinted-theming/schemes:
base16Scheme = "${inputs.tinted-schemes}/base16/catppuccin-macchiato.yaml";

# Or define a custom scheme:
base16Scheme = {
  base00 = "1e1e2e"; # background
  base0D = "89b4fa"; # blue / accent
  # ...
};
```

Colors are accessible in any HM module via:
```nix
{ config, ... }: {
  some.color = "#${config.lib.stylix.colors.base0D}";
}
```

See `lib/host-config.nix` for the base16 slot reference.

## Adding a New Host

1. Create `hosts/newhost/` with `system.nix`, `hardware.nix`, `home.nix`, and `user.nix`
2. Put options that are not present in `modules/system/core/boot-config.nix` in `hardware.nix`. This file should put these options in the same main module as `system.nix`. 
3. Add user configuration to `user.nix`, and home-manager config to `home.nix`.
4. Define the flake-parts entry in `system.nix`:
```nix
{ inputs, self, ... }: {
  flake.nixosConfigurations.newhost = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.hostConfig
      self.nixosModules.hostNewhost
    ];
  };
  flake.nixosModules.hostNewhost = { ... }: {
    imports = with self.nixosModules; [
      # add appropriate system modules here
      # user config, if used
    ];
    host = {
      username       = "user";
      hostname       = "newhost";
      flakeDirectory = "/home/user/nix-configuration";
      gitUsername    = "Name";
      gitEmail       = "email@example.com";
      compositor     = "niri";
    };
  };
}
```
1. Run `nixos-install --flake .#newhost` on the new machine