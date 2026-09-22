# trzsz Flake

a Nix flake of [trzsz-go](https://github.com/trzsz/trzsz-go)

current version: [1.2.0](https://github.com/trzsz/trzsz-go/releases/tag/v1.2.0)

## Platforms

- x86_64-linux
- aarch64-linux
- armv6l-linux
- armv7l-linux
- i686-linux
- aarch64-darwin
- x86_64-freebsd

## Usage

### Temporary

```console
$ nix shell github:BioniCosmos/trzsz
```

### Persistent

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    trzsz.url = "github:BioniCosmos/trzsz";
  };
  outputs = { nixpkgs, trzsz, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [ (_: { nixpkgs.overlays = [ trzsz.overlay ]; }) ./configuration.nix ];
    };
  };
}
```

```nix
# configuration.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ trzsz ];
}
```
