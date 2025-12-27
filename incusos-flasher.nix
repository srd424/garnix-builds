{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
}:

let
  version = "202512250102";
  src = fetchFromGitHub {
    owner = "lxc";
    repo = "incus-os";
    rev = "${version}";
    hash = "sha256-ZWLlI1Wis9LA7x1RTCoiJBGzL7lSHTezyI93WRBNA48=";
  };
in
buildGoModule {
  pname = "incusos-flasher";
  inherit version src;

  sourceRoot = "${src.name}/incus-osd";
  subPackages = [ "cmd/flasher-tool" ];

  vendorHash = "sha256-bXC9O6cYt5t0KkQqhEAZuGb3/MtNyAXASVfj1IVWnuc=";

  meta = with lib; {
    homepage = "https://github.com/lxc/incus-os";
    description = "IncusOS image flasher tool";
    license = licenses.asl20;
#    maintainers = with maintainers; [ ironicbadger ];
  };
}
