{
  description = "Shell utils to use starship";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    fzf-tab = {
      url = "github:lincheney/fzf-tab-completion";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, fzf-tab }:

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
              zshConfig = pkgs.writeTextFile {
                name = "zshrc";
                text = ''
                  export MYVAR="myvar"
                  alias l='exa -l'
                  alias ls='exa'
                  export STARSHIP_CONFIG=${config}
                  eval "$(starship init zsh)"
                  source "${pkgs.fzf}/share/fzf/completion.zsh"
                  source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
                '';
                destination = "/.zshrc";
              };
              zshBin = pkgs.writeShellApplication {
                name = "zsh";
                runtimeInputs = [ pkgs.zsh ];
                text = ''
                  ZDOTDIR=${zshConfig} ${pkgs.zsh}/bin/zsh 
                '';
              };
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
              new_packages = packages ++
                (with pkgs; [
                  starship
                  fzf
                  fd
                  exa
                  bat
                  bashInteractive
                  zsh
                  zshBin
                ]);
              new_params = builtins.removeAttrs params [ "starshipConfig" ];
              new_shellhook = shellHook + ''
                exec ${zshBin}/bin/zsh
              '';
            in
            pkgs.mkShell (new_params // {
              packages = new_packages;
              shellHook = new_shellhook;
            });
          devShells.default = myShell {
            packages = [ pkgs.graphviz ];
            shellHook = ''alias bar='echo "Bar!"'; '';
          };
        }
      );
}
