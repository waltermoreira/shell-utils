{
  description = "Shell utils to use starship";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, fzf-tab }:

    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tomlFormat = pkgs.formats.toml { };
        in
        rec {
          myShell =
            { name ? ""
            , starshipConfig ? { }
            , shellHook ? ""
            , extraInitRc ? ""
            , packages ? [ ]
            , ...
            }@params:
            let
              promptName = "nix" + pkgs.lib.optionalString (name != "") " " + name;
              histFile = "~/.history-" + (if name == "" then "noname" else name);
              zshConfig = pkgs.writeTextFile {
                name = "zshrc";
                text = ''
                  export HISTFILE="$(realpath ${histFile})"
                  ZSH_THEME="robbyrussell"
                  source ${pkgs.oh-my-zsh}/share/oh-my-zsh/oh-my-zsh.sh
                  source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
                  source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/fzf/fzf.plugin.zsh
                  source ${fzf-tab}/fzf-tab.plugin.zsh
                  alias l='exa -l'
                  alias ls='exa'
                  export STARSHIP_CONFIG=${config}
                  export LESSOPEN="|${pkgs.lesspipe}/bin/lesspipe.sh %s"
                  eval "$(starship init zsh)"
                  ${extraInitRc}
                '';
                destination = "/.zshrc";
              };
              zshBin = pkgs.writeShellApplication {
                name = "zsh";
                runtimeInputs = [ pkgs.zsh ];
                text = ''
                  export SHELL_SESSIONS_DISABLE=1
                  ZDOTDIR=${zshConfig} ${pkgs.zsh}/bin/zsh -o NO_GLOBAL_RCS
                '';
              };
              baseStarshipConfig = {
                add_newline = true;
                format = " $directory$character";
                character = {
                  success_symbol = "[➜](bold green)";
                };
              };
              myStarshipConfig = with pkgs.lib; fix (
                extends
                  (self: super: { format = "[\\[${promptName}\\]](green)" + super.format; })
                  (self: baseStarshipConfig // starshipConfig)
              );
              config = tomlFormat.generate "starship.toml" myStarshipConfig;
              new_packages = packages ++
                (with pkgs; [
                  starship
                  fzf
                  fd
                  exa
                  bat
                  bashInteractive
                  zsh
                  oh-my-zsh
                  zsh-autosuggestions
                  zshBin
                  lesspipe
                ]);
              new_params = builtins.removeAttrs params [
                "starshipConfig"
                "extraInitRc"
              ];
              new_shellhook = shellHook + ''
                exec ${zshBin}/bin/zsh
              '';
            in
            pkgs.mkShell (new_params // {
              packages = new_packages;
              shellHook = new_shellhook;
            });
          devShells.default = myShell {
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
            '';
          };
        }
      );
}
