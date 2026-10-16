{ self, lib, legacyPackages, ... }: let pname = "b2-browser"; in {
  packages = lib.genAttrs lib.systems.flakeExposed (platform: {
    ${pname} = let
      pkgs = legacyPackages.${platform};
      version = "0.1.1";
      src = pkgs.fetchFromGitHub {
        owner = "BioniCosmos";
        repo = pname;
        # tag = "v${version}";
        rev = "39b08b2";
        hash = "sha256-kQatA9wZ+CnS8exxBatzziOMn6muzRNAp/eJ5HYep0g=";
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
