{ flake-parts-lib, inputs, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ lib, pkgs, ... }:
    let
      shell = pkgs.callPackage ./../shell.nix { inherit (inputs) fzf-tab; };
    in
    {
      options.shell-utils.shell = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
        default = shell;
        readOnly = true;
      };
    });
}
