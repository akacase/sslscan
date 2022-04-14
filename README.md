# sslscan

This is a flake for `sslscan`, it provides an override for OpenSSL with `zlib`, and some deprecated ciphers enabled for `sslscan` to do additional testing without impacting the security posture of your entire system.

`nix build github:akacase/sslscan`

to review the source and do additional development against the current pin:

`nix develop github:akacase/sslscan`

to use in a flake:

```nix
# add to inputs
  inputs = {
    sslscan = {
      url = "github:akacase/sslscan";
    };
  };
  
  # add to outputs
  outputs = { self, nixpkgs, stable, flake-utils, sslscan }:

  # add the overlay
  overlays = [ sslscan.overlay ];

  # and reference the sslscan pkg
