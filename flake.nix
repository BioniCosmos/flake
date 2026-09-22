{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  outputs = { self, nixpkgs, ... }: {
    defaultPackage = builtins.mapAttrs (system: { target, sha256 }: derivation (let
      version = "1.2.0";
    in {
      name = "trzsz-${version}";
      inherit system;
      builder = "/bin/sh";
      PATH = "${nixpkgs.legacyPackages.${system}.coreutils}/bin";
      args = [
        "-c"
        ''
        mkdir $out
        cp -r \
          ${fetchTarball {
            url = "https://github.com/trzsz/trzsz-go/releases/download/v${version}/trzsz_${version}_${target}.tar.gz";
            inherit sha256;
          }} \
          $out/bin
        ''
      ];
    })) {
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

    overlay = final: prev: { trzsz = self.defaultPackage.${prev.stdenv.hostPlatform.system}; };
  };
}
