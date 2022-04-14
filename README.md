# sslscan

This is a flake for `sslscan`, it provides an override for OpenSSL with `zlib`, and some deprecated ciphers enabled for `sslscan` to do additional testing without impacting the security posture of your entire system.

`nix build github:akacase/sslscan`

to review the source and do additional development against the current pin:

`nix develop github:akacase/sslscan`
