{ pkgs, shell, ... }:
shell {
  name = "demo";
  packages = [ pkgs.graphviz ];
  starshipConfig = {
    format = " $env_var$directory$character";
    env_var.FOO.default = "no user";
  };
  extraInitRc = ''
    alias extra='echo "Extra init"'
  '';
  shellHook = ''
    echo "In shellhook"
    export BAR="bar"
  '';
  onExit = ''
    echo "Exiting..."
    echo "BAR = $BAR"
  '';
}
