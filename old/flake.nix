{
  description = "flake to build various useful packages on garnix";

  inputs = {
    nixpkgs2511.url = "github:nixos/nixpkgs/nixos-25.11";
    sys-mgr = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs2511";
    };
  };

  outputs = { self, sys-mgr, ... }: let

    in {
      packages.x86_64-linux.system-manager = sys-mgr.packages.x86_64-linux.default;

      hydraJobs =
        let
          packages = self.outputs.packages;
        in {
          system-manager = packages.x86_64-linux.system-manager;
        };
  };
}

# vim: set ts=2 sw=2 et sta:
