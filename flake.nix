{
  description = "sslscan";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    utils.url = "github:numtide/flake-utils";
    sslscan-src = {
      url = "github:rbsec/sslscan";
      flake = false;
    };
  };


  outputs = { self, nixpkgs, utils, sslscan-src }:
    let
      systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" "aarch64-darwin" "x86-64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;

          overlays = [
            self.overlay
          ];
        }
      );
    in
    {
      overlay = final: prev: {
        openssl-zlib = prev.openssl.overrideAttrs (old: {
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

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) sslscan;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.sslscan);

      devShell = forAllSystems (system:
        with nixpkgsFor.${system}; pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
            gcc
            gnumake
            glibc
            zlib
          ];
          shellHook = ''
            ln -s "${sslscan-src}" ./src
          '';
        });
    };
}
