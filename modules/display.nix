{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ lib, pkgs, ... }:
    let
      display = pkgs.writeShellApplication {
        name = "display";
        runtimeInputs = [ pkgs.gum ];
        text = ''
          text="$1"
          min_size="''${2:-10}"
          max_size="''${3:-30}"
          size=$(( "''${#text}" + 2 ))
          if [ "$size" -lt "$min_size" ]; then
            size="$min_size"
          elif [ "$size" -gt "$max_size" ]; then
            size="$max_size"
          fi
          gum style \
            --foreground 212 --border-foreground 212 --border double \
            --align center --width "$size" --margin "1 1" --padding "1 1" \
            "$1"
        '';
      };
    in
    {
      options.shell-utils.display = lib.mkOption {
        type = lib.types.package;
        default = display;
        readOnly = true;
      };
    });
}
