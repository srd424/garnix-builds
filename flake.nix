{
  description = "flake to build various useful packages on garnix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs2305.url = "github:nixos/nixpkgs/nixos-23.05";
    tgt-glfs = {
      url = "git+https://codeberg.org/srd424/tgt-glfs-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gpiod-dbus = {
      url = "git+https://codeberg.org/srd424/libgpiod-nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sboot-srvr = {
      url = "git+https://codeberg.org/srd424/snowboot-server.git?ref=hydra-notls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs2305, tgt-glfs, gpiod-dbus, sboot-srvr }: let
      pkgs2305 = nixpkgs2305.legacyPackages.x86_64-linux;

    in {
      packages.aarch64-linux.libgpiod = gpiod-dbus.packages.aarch64-linux.libgpiod;

      packages.x86_64-linux.snowboot = sboot-srvr.packages.x86_64-linux.package;

      packages.x86_64-linux.tgt-glfs = tgt-glfs.packages.x86_64-linux.tgt;

      packages.x86_64-linux.gnucash54 =
        pkgs2305.gnucash.overrideAttrs (prevAttrs: {
          patches = (prevAttrs.patches or []) ++ [
            ./gnucash54/python-env.patch
           ];
          cmakeFlags = [
            "-DWITH_PYTHON=\"ON\""
            "-DPYTHON_SYSCONFIG_BUILD=\"$out\""
          ];
          buildInputs = prevAttrs.buildInputs ++ (with pkgs2305; [
            python3
          ]);
          postPatch = ''
            substituteInPlace bindings/python/__init__.py \
            --subst-var-by gnc_dbd_dir "${pkgs2305.libdbiDrivers}/lib/dbd" \
            --subst-var-by gsettings_schema_dir ${pkgs2305.glib.makeSchemaPath "$out" "gnucash-${prevAttrs.version}"};
          '';
        });
      packages.x86_64-linux.gnucash54-pymodule = pkgs2305.python3Packages.toPythonModule self.packages.x86_64-linux.gnucash54;
  };
}

# vim: set ts=2 sw=2 et sta:
