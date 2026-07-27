{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
}:

let
  version = "202607072359";
  src = fetchFromGitHub {
    owner = "lxc";
    repo = "incus-os";
    rev = "${version}";
    hash = "sha256-9MEkGbKlCVm6S9wVpF+Rtn8Ws5gst0eiqxP205isOC0=";
  };
in
buildGoModule {
  pname = "incusos-flasher";
  inherit version src;

  sourceRoot = "${src.name}/incus-osd";
  subPackages = [ "cmd/flasher-tool" ];

  vendorHash = "sha256-PI5r//RzrBU7Ocy3I5T400S4dmV6ELy6BPnVvW5pYQw=";

  meta = with lib; {
    homepage = "https://github.com/lxc/incus-os";
    description = "IncusOS image flasher tool";
    license = licenses.asl20;
    mainProgram = "flasher-tool";
#    maintainers = with maintainers; [ ironicbadger ];
  };
}
