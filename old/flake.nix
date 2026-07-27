{
  description = "flake to build various useful packages on garnix";

  inputs = {
    nixpkgs2605.url = "github:nixos/nixpkgs/nixos-26.05";
    ssh-agent-switcher = {
      url = "github:jmmv/ssh-agent-switcher?rev=9cf67475a143b70b5f5076eb1d3747cbac10220b";
      inputs.nixpkgs.follows = "nixpkgs2605";
    };
  };

  outputs = { self, ssh-agent-switcher, ... }:
    {
      packages.x86_64-linux.ssh-agent-switcher = ssh-agent-switcher.packages.x86_64-linux.default;
      hydraJobs =
        let
          packages = self.outputs.packages;
        in {
          ssh-agent-switcher = packages.x86_64-linux.ssh-agent-switcher;
        };
  };
}

# vim: set ts=2 sw=2 et sta:
