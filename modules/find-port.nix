{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ lib, pkgs, ... }:
    let
      findPort = pkgs.writeShellApplication {
        name = "find-port";
        runtimeInputs = [ pkgs.python3 ];
        text = ''
          python3 - <<EOF
          import socket
          s=socket.socket()
          s.bind(("", 0))
          print(s.getsockname()[1])
          s.close()
          EOF
        '';
      };
    in
    {
      options.shell-utils.findPort = lib.mkOption {
        type = lib.types.package;
        default = findPort;
        readOnly = true;
      };
    });
}
