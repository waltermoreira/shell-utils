{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ lib, pkgs, ... }:
    let
      tomlMap = pkgs.writeShellApplication {
        name = "toml-map";
        runtimeInputs = [ (pkgs.python313.withPackages (p: [ p.tomlkit ])) ];
        text = ''
          python -c "
          import tomlkit, sys
          doc = tomlkit.load(sys.stdin)
          $1 
          tomlkit.dump(doc, sys.stdout)
          "
        '';
      };
    in
    {
      options.shell-utils.tomlMap = lib.mkOption {
        type = lib.types.package;
        default = tomlMap;
        readOnly = true;
      };
    });
}
