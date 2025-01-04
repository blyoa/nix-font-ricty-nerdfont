# nix-font-ricty-nerdfont

A Nix flake that provides an overlay for a composite font of [Ricty](https://rictyfonts.github.io/) and [Nerd Font](https://www.nerdfonts.com/).

## Example Usage

### Quick Generation of Ricty Nerd Font

You can generate the Ricty Nerd Font with the following command:

```bash
nix build 'github:blyoa/nix-font-ricty-nerdfont'
```

### Example flake.nix

The `ricty-nerdfont` is available through the overlay exported by this project. The following is an example of `flake.nix` that uses the overlay:

```nix
{
  description = "Example configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ricty-nerdfont = {
      url = "github:blyoa/nix-font-ricty-nerdfont";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ricty-nerdfont,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              ricty-nerdfont.overlays.default
            ];
          };
        in
        {
          # You can built the Ricty Nerd Font with `nix build`
          default = pkgs.ricty-nerdfont;
        }
      );
    };
}
```
