{ self, lib, legacyPackages, ... }: let pname = "b2-browser"; in {
  packages = lib.genAttrs lib.systems.flakeExposed (platform: {
    ${pname} = let
      pkgs = legacyPackages.${platform};
      version = "0.1.4";
      src = pkgs.fetchFromGitHub {
        owner = "BioniCosmos";
        repo = pname;
        tag = "v${version}";
        hash = "sha256-dVrznwU+Z0w4VVDqoMYQOcZfv4+s3hdQhG6jOYmfP2o=";
      };
    in pkgs.rustPlatform.buildRustPackage {
      inherit pname version src;
      cargoLock = { lockFile = "${src}/Cargo.lock"; };
      nativeBuildInputs = [ pkgs.tailwindcss_4 ];
    };
  });

  overlays.${pname} = final: prev:
    { ${pname} = self.packages.${prev.stdenv.hostPlatform.system}.${pname}; };
}
