{
  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  outputs = params@{ nixpkgs, ... }: let inherit (nixpkgs) lib legacyPackages; in
    lib.foldl (acc: x: lib.recursiveUpdate acc x) {} (
      map (x: import x (params // { inherit lib legacyPackages; })) [
        ./pkg/trzsz.nix
        ./pkg/b2-browser-bin.nix
      ]
    );
}
