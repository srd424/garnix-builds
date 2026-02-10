{
  description = "flake to build various useful packages on garnix";

  inputs = {
    nixpkgs2505.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs2511.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs2305.url = "github:nixos/nixpkgs/nixos-23.05";
    tgt-glfs = {
      url = "git+https://codeberg.org/srd424/tgt-glfs-nix.git";
      inputs.nixpkgs.follows = "nixpkgs2505";
    };
    gpiod-dbus = {
      url = "git+https://codeberg.org/srd424/libgpiod-nix.git";
      inputs.nixpkgs.follows = "nixpkgs2505";
    };
    sboot-srvr = {
      url = "git+https://codeberg.org/srd424/snowboot-server.git?ref=hydra-notls";
      inputs.nixpkgs.follows = "nixpkgs2505";
    };
    sys-mgr = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs2505";
    };
    ufi-forgejo = {
      url = "git+https://codeberg.org/srd424/update-flake-inputs-forgejo.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs2305, nixpkgs2511,
                tgt-glfs, gpiod-dbus, sboot-srvr, sys-mgr, ufi-forgejo, ... }: let
      pkgs2305 = nixpkgs2305.legacyPackages.x86_64-linux;
      pkgs2511 = nixpkgs2511.legacyPackages.x86_64-linux;

    in {
      packages.aarch64-linux.libgpiod = gpiod-dbus.packages.aarch64-linux.libgpiod;

      packages.x86_64-linux.snowboot = sboot-srvr.packages.x86_64-linux.package;

      packages.x86_64-linux.update-flake-inputs-forgejo = ((import ufi-forgejo) { system = "x86_64-linux"; });

      packages.x86_64-linux.tgt-glfs = tgt-glfs.packages.x86_64-linux.tgt;

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
        pkgs2511.arcanechat-tui.overrideAttrs (prevAttrs: {
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


  };
}

# vim: set ts=2 sw=2 et sta:
