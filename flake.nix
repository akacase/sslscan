{
  description = "sslscan";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    utils.url = "github:numtide/flake-utils";
    sslscan-src = {
      url = "github:rbsec/sslscan";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, sslscan-src }: utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import nixpkgs {
          inherit system; overlays = [
          self.overlay
          (final: prev: {
            openssl-zlib = prev.openssl.overrideAttrs (old: {
              pname = "openssl";
              configureFlags = old.configureFlags ++ [ "-D_FORTIFY_SOURCE=2" "-fPIC" "enable-weak-ssl-ciphers" "zlib" ];
              nativeBuildInputs = old.nativeBuildInputs ++ [ final.pkgs.zlib ];
            });
          })
        ];
        };
        sslscan = (with pkgs; stdenv.mkDerivation {
          name = "sslscan";
          src = sslscan-src;
          nativeBuildInputs = [ gnumake gcc ];
          buildInputs = [ openssl-zlib ];

          buildPhase = ''
            make 
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp sslscan $out/bin/sslscan
          '';

          meta = with lib; {
            description = "sslscan tests SSL/TLS enabled services to discover supported cipher suites";
            homepage = https://github.com/rbsec/sslscan;
            license = licenses.gpl3Only;
            maintainers = with maintainers; [ case ];
          };
        });
      in
      rec
      {
        defaultPackage = sslscan;
        packages.${system} = sslscan;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            openssl-zlib
            gcc
            gnumake
            zlib
          ];
          shellHook = ''
            ln -s "${sslscan-src}" ./src
          '';
        };
      }) // {
    overlay = final: prev: {
      openssl-zlib = prev.openssl.overrideAttrs (old: {
        pname = "openssl";
        configureFlags = old.configureFlags ++ [ "-D_FORTIFY_SOURCE=2" "-fPIC" "enable-weak-ssl-ciphers" "zlib" ];
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.pkgs.zlib ];
      });

      sslscan = with final; (stdenv.mkDerivation {
        name = "sslscan";
        src = sslscan-src;
        nativeBuildInputs = [ gnumake gcc ];
        buildInputs = [ openssl-zlib glibc ];

        buildPhase = ''
          make 
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp sslscan $out/bin/sslscan
        '';

        meta = with lib; {
          description = "sslscan tests SSL/TLS enabled services to discover supported cipher suites";
          homepage = https://github.com/rbsec/sslscan;
          license = licenses.gpl3Only;
          maintainers = with maintainers; [ case ];
        };
      });
    };
  };
}
