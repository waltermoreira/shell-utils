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
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      flake.flakeModule = import ./modules;
      perSystem = { pkgs, config, ... }:
        let
          shell = pkgs.callPackage ./shell.nix { inherit fzf-tab; };
          demoShell = pkgs.callPackage ./demo.nix { inherit shell; };
        in
        {
          lib.shell = shell;
          packages.toml-map = config.shell-utils.tomlMap;
          devShells = {
            default = demoShell;
            cmd = demoShell.override { cmdShell = true; };
          };
        };
    };
}
