{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
}:

let
  version = "202607270148";
  src = fetchFromGitHub {
    owner = "lxc";
    repo = "incus-os";
    rev = "${version}";
    hash = "sha256-mSoMrdvmSfI0AKKIyg0nIpefjhByb84Lve4IRBbneg0=";
  };
in
buildGoModule {
  pname = "incusos-flasher";
  inherit version src;

  sourceRoot = "${src.name}/incus-osd";
  subPackages = [ "cmd/flasher-tool" ];

  vendorHash = "sha256-mQFPsTAmuwJVnxH4DnLQHOsOOb2h4DSZRKpUXNB/doE=";

  meta = with lib; {
    homepage = "https://github.com/lxc/incus-os";
    description = "IncusOS image flasher tool";
    license = licenses.asl20;
    mainProgram = "flasher-tool";
#    maintainers = with maintainers; [ ironicbadger ];
  };
}
