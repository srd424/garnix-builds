{
  description = "flake to build various useful packages on garnix";

  inputs = {
    nixpkgs2605.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs2511.url = "github:nixos/nixpkgs/nixos-25.11";
    ssh-agent-switcher = {
      url = "github:jmmv/ssh-agent-switcher?rev=9cf67475a143b70b5f5076eb1d3747cbac10220b";
      inputs.nixpkgs.follows = "nixpkgs2605";
    };
    sboot-srvr = {
      url = "git+https://codeberg.org/srd424/snowboot-server.git?ref=hydra-notls";
      inputs.nixpkgs.follows = "nixpkgs2511";
    };
  };

  outputs = { self, sboot-srvr, ssh-agent-switcher, ... }:
    {
      packages.x86_64-linux.ssh-agent-switcher = ssh-agent-switcher.packages.x86_64-linux.default;
      packages.x86_64-linux.snowboot = sboot-srvr.packages.x86_64-linux.package;

      hydraJobs =
        let
          packages = self.outputs.packages;
        in {
          ssh-agent-switcher = packages.x86_64-linux.ssh-agent-switcher;
          snowboot = packages.x86_64-linux.snowboot;
        };
  };
}

# vim: set ts=2 sw=2 et sta:
