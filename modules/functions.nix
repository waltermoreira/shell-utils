{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ lib, pkgs, ... }:
    let
      functions = pkgs.stdenv.mkDerivation {
        name = "functions";
        src = ./../scripts;
        buildPhase = ''
          cp functions.sh $out
        '';
      };
    in
    {
      options.shell-utils.functions = lib.mkOption {
        type = lib.types.package;
        default = functions;
        readOnly = true;
      };
    });
}
