{
  description = "CLI for fallow, Rust-native codebase intelligence for TypeScript and JavaScript";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fallow = pkgs.rustPlatform.buildRustPackage {
          pname = "fallow";
          version = "2.86.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          # Skip tests in the Nix sandbox: 24 tests fail due to filesystem
          # sandbox constraints (e.g. path resolution, network, temp dir).
          # `cargo test` passes outside Nix; use it for local validation.
          doCheck = false;
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
          ];
          meta = {
            description = "CLI for fallow, Rust-native codebase intelligence for TypeScript and JavaScript";
            homepage = "https://github.com/fallow-rs/fallow";
            license = pkgs.lib.licenses.mit;
            mainProgram = "fallow";
          };
        };
      in
      {
        packages = {
          default = fallow;
          source = fallow;
        };

        apps = {
          default = {
            type = "app";
            program = "${fallow}/bin/fallow";
          };
          source = {
            type = "app";
            program = "${fallow}/bin/fallow";
          };
        };

        checks = {
          build = fallow;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ fallow ];
          buildInputs = with pkgs; [
            rustc
            cargo
            rust-analyzer
            pkg-config
          ];
        };
      }
    );
}
