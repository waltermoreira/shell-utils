{
  description = "Shell utils to use starship";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    simple-flake.url = "github:waltermoreira/simple-flake";
    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };
  };

  outputs = inputs@{ simple-flake, fzf-tab, ... }:
    simple-flake.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/toml.nix
        ./modules/shell.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      flake.flakeModule = import ./modules;
      perSystem = { pkgs, config, ... }:
        let
          demoShell = pkgs.callPackage ./demo.nix { inherit (config.shell-utils) shell; };
        in
        {
          _module.args.fzf-tab = builtins.trace fzf-tab fzf-tab;
          _module.args.foo = true;
          packages.toml-map = config.shell-utils.tomlMap;
          devShells = {
            default = demoShell;
            cmd = demoShell.override { cmdShell = true; };
          };
        };
    };
}
