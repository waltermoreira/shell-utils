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
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, ... }:
        let
          shell = pkgs.callPackage ./shell.nix { inherit fzf-tab; };
          demoShell = pkgs.callPackage ./demo.nix { inherit shell; }; 
        in
        {
          lib.shell = shell;
          devShells = {
            default = demoShell;
            cmd = demoShell.override { cmdShell = true; };
          };
        };
    };
}
