# Enables running AppImage binaries directly as executables by registering
# a binfmt_misc handler that automatically routes execution through
# appimage-run based on the AppImage type 2 magic bytes.
#
# Usage:
#   Add self.nixosModules.appimage to your host's modules list:
#
#   modules = [
#     self.nixosModules.appimage
#   ];
#
#   Then AppImages can be run directly without invoking appimage-run manually:
#
#   chmod +x myapp.AppImage
#   ./myapp.AppImage
{
  flake.nixosModules.appimageSupport = {pkgs, ...}: {
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
