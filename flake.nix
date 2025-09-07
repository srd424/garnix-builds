{
  description = "flake to build various useful packages on garnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    tgt-glfs = {
      url = "git+https://codeberg.org/srd424/tgt-glfs-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, tgt-glfs }: let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      packages.x86_64-linux.tgt = tgt-glfs.packages.x86_64-linux.tgt;
    };
}

# vim: set ts=2 sw=2 et sta:
