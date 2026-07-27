{
  description = "flake to build various useful packages on garnix";

  inputs = {
    nixpkgs2305.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs2605.url = "github:nixos/nixpkgs/nixos-26.05";
    tgt-glfs = {
      url = "git+https://codeberg.org/srd424/tgt-glfs-nix.git";
      inputs.nixpkgs.follows = "nixpkgs2511";
    };
    gpiod-dbus = {
      url = "git+https://codeberg.org/srd424/libgpiod-nix.git";
      inputs.nixpkgs.follows = "nixpkgs2511";
    };
    sys-mgr = {
      url = "github:numtide/system-manager";
      # don't set nixpkgs input to follow a stable branch, system-manager
      # does not reliably support this: https://github.com/numtide/system-manager/issues/490
    };
    forgejo-runner-fix = {
      url = "git+https://codeberg.org/srd424/forgejo-runner-fix";
      inputs.nixpkgs.follows = "nixpkgs2511";
    };
  };

  outputs = { self, nixpkgs2305, nixpkgs2511, nixpkgs2605,
                forgejo-runner-fix, tgt-glfs, gpiod-dbus, sys-mgr, ... }: let
      pkgs2305 = nixpkgs2305.legacyPackages.x86_64-linux;
      pkgs2511 = nixpkgs2511.legacyPackages.x86_64-linux;
      pkgs2605 = nixpkgs2605.legacyPackages.x86_64-linux;

    in {
      packages.aarch64-linux.libgpiod = gpiod-dbus.packages.aarch64-linux.libgpiod;
      packages.x86_64-linux.libgpiod = gpiod-dbus.packages.x86_64-linux.libgpiod;

      packages.x86_64-linux.tgt-glfs = tgt-glfs.packages.x86_64-linux.tgt;

      packages.x86_64-linux.forgejo-runner = forgejo-runner-fix.packages.x86_64-linux.default;

      # packages.x86_64-linux.system-manager is now in nixpkgs
      packages.x86_64-linux.system-manager = sys-mgr.packages.x86_64-linux.default;

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

      packages.x86_64-linux.arcanechat-tui =
        pkgs2605.arcanechat-tui.overrideAttrs (prevAttrs: {
          version = "0.11.2";
          src = pkgs2511.fetchFromGitHub {
            owner = "ArcaneChat";
            repo = "arcanechat-tui";
            rev = "9618940621907b5ea1a70dece5b5f6aa385dc310";
            hash = "sha256-hwggqPuNBR+ENSdHos1326g8TZRjzVNi8tl64JrrKrE=";
          };
        });

      packages.x86_64-linux.incusos-flasher =
            pkgs2511.callPackage ./incusos-flasher.nix {};
      packages.aarch64-linux.incusos-flasher =
        nixpkgs2511.legacyPackages.aarch64-linux.callPackage ./incusos-flasher.nix {};

      hydraJobs =
        let
          packages = self.outputs.packages;
        in {
          libgpiod-x64 = packages.x86_64-linux.libgpiod;
          # TODO: build arm version one day
          tgt-glfs = packages.x86_64-linux.tgt-glfs;
          forgejo-runner = packages.x86_64-linux.forgejo-runner;
          gnucash54 = packages.x86_64-linux.gnucash54;
          gnucash54-pymodule = packages.x86_64-linux.gnucash54-pymodule;
          arcanechat-tui = packages.x86_64-linux.arcanechat-tui;
          incusos-flasher = packages.x86_64-linux.incusos-flasher;
          system-manager = packages.x86_64-linux.system-manager;
        };
  };
}

# vim: set ts=2 sw=2 et sta:
