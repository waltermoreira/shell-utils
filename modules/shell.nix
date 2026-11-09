{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ lib, pkgs, fzf-tab, ... }:
    let
      shell = pkgs.callPackage ./../shell.nix { inherit fzf-tab; };
    in
    {
      options.shell-utils.shell = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
        default = shell;
        readOnly = true;
      };
    });
}
