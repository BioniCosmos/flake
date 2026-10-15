{ self, lib, legacyPackages, ... }: {
  packages = lib.mapAttrs (system: { target, sha256 }: {
    trzsz = derivation (let version = "1.2.0"; pkgs = legacyPackages.${system}; in {
      name = "trzsz-${version}";
      inherit system;
      builder = "/bin/sh";
      PATH = "${pkgs.coreutils}/bin";
      args = [
        "-c"
        ''
        mkdir $out
        cp -r \
          ${pkgs.fetchzip {
            url = "https://github.com/trzsz/trzsz-go/releases/download/v${version}/trzsz_${version}_${target}.tar.gz";
            inherit sha256;
          }} \
          $out/bin
        ''
      ];
    });
  }) {
    x86_64-linux = {
      target = "linux_x86_64";
      sha256 = "sha256-LYLU58g5Gc3oRIG6BG4Egrdp0J/eeNsUTxTwxX0jdaE=";
    };
    aarch64-linux = {
      target = "linux_aarch64";
      sha256 = "sha256-BojVLMwlFRGFoAc46mMGQhutJLBGEf/0wAsQgNaJvZU=";
    };
    armv6l-linux = {
      target = "linux_armv6";
      sha256 = "sha256-E4oTSfUZT0LvY2lx9e2g8INIZsgswXPN3q0NZ/pbbfU=";
    };
    armv7l-linux = {
      target = "linux_armv7";
      sha256 = "sha256-8IplQjUJbFhnbHGfYslwpJ24AFnn+sQ2u7JtRxIntPA=";
    };
    i686-linux = {
      target = "linux_i386";
      sha256 = "sha256-DuOuxph2WGFUfXjBCdKs6H4i/6xrBy93q0ZB5CyV6Zc=";
    };
    aarch64-darwin = {
      target = "macos_aarch64";
      sha256 = "sha256-h9QvaMLw3WMHEBy/+dhjRuAk2hBXDFr+4wtkDJ85IO4=";
    };
    x86_64-freebsd = {
      target = "freebsd_x86_64";
      sha256 = "sha256-6Nm3rg1wDymkbs6NAo4op7EPbFVBOFqqihKJvhzC5To=";
    };
  };

  overlays.trzsz = final: prev: { trzsz = self.packages.${prev.stdenv.hostPlatform.system}.trzsz; };
  nixosModules.trzsz = _: { nixpkgs.overlays = [ self.overlays.trzsz ]; };
}
