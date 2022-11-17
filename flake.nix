{
  description = "Shell utils to use starship";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          myShell =
            { starshipConfig ? ""
            , shellHook ? ""
            , packages ? [ ]
            , ...
            }@params:
            let
              config = pkgs.writeTextFile {
                name = "starship.toml";
                text = ''
                  add_newline = true
                  format = """
                  [nix ](green)$directory$character """

                  [character]
                  success_symbol = "[➜](bold green)"
                '' + starshipConfig;
              };
              new_packages = packages ++ [ pkgs.starship ];
              new_params = builtins.removeAttrs params [ "starshipConfig" ];
              new_shellhook = ''
                alias foo='echo "I am foo"'
                export STARSHIP_CONFIG=${config}
                eval "$(starship init bash)"
              '' + shellHook;
            in
            pkgs.mkShell (new_params // {
              packages = new_packages;
              shellHook = new_shellhook;
            });
          devShells.default = myShell {
            packages = [ pkgs.graphviz ];
            shellHook = ''alias bar='echo "Bar!"' '';
          };
        }
      );
}
