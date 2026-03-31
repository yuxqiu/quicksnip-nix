# QuickSnip for NixOS

Unofficial Nix flake for [QuickSnip](https://github.com/Ronin-CK/QuickSnip).

## Installation

### Flake Input (NixOS / Home Manager)

```nix
inputs.quicksnip.url = "github:yuxqiu/quicksnip-nix";
```

Add to `systemPackages` or `home.packages`:

```nix
quicksnip.packages.${system}.default
```

### Run directly

```sh
nix run github:yuxqiu/quicksnip-nix
```

## Development

```sh
nix develop github:yuxqiu/quicksnip-nix
```
