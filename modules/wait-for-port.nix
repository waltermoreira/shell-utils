{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ lib, pkgs, ... }:
    let
      waitForPort = pkgs.writeShellApplication {
        name = "wait-for-port";
        runtimeInputs = [ pkgs.netcat ];
        text = ''
          host="$1"
          port="$2"
          timeout="''${3:-10}"
          sleep="''${4:-0.1}"

          SECONDS=0
          while ! nc -z "$host" "$port" >/dev/null 2>&1; do 
              if [ "$SECONDS" -gt "$timeout" ]; then
                  exit 1
              fi
              sleep "$sleep" 
          done  
          exit 0
        '';
      };
    in
    {
      options.shell-utils.waitForPort = lib.mkOption {
        type = lib.types.package;
        default = waitForPort;
        readOnly = true;
      };
    });
}
