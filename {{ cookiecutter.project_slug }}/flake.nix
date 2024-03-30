{
  description = "{{ cookiecutter.description }}";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # Construct an output set that supports a number of default systems
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Legacy packages that have not been converted to flakes
        legacyPackages = nixpkgs.legacyPackages.${system};
        # OCaml packages available on nixpkgs
        ocamlPackages = legacyPackages.ocamlPackages;
        # Library functions from nixpkgs
        lib = legacyPackages.lib;
      in
      {
        packages = {
          default = self.packages.${system}.{{ cookiecutter.project_slug }};

          {{ cookiecutter.project_slug }} = ocamlPackages.buildDunePackage rec {
            pname = "{{ cookiecutter.project_slug }}";
            version = "{{ cookiecutter.version }}";

            minimumOCamlVersion = "4.10";
            duneVersion = "3";
            meta.mainProgram = "{{ cookiecutter.project_slug }}";

            src = ./.;

            buildInputs = with ocamlPackages; [
              ppx_deriving
              ppxlib
              merlin
              ocp-indent
            ];
          };
        };

        devShells = {
          default = legacyPackages.mkShell {
            packages = [
              legacyPackages.nixpkgs-fmt
              legacyPackages.ocamlformat
              legacyPackages.fswatch
              ocamlPackages.odoc
              ocamlPackages.ocaml-lsp
              ocamlPackages.ocamlformat-rpc-lib
              ocamlPackages.utop
            ];

            # Tools from packages
            inputsFrom = [
              self.packages.${system}.{{ cookiecutter.project_slug }}
            ];
          };
        };

        apps.{{ cookiecutter.project_slug }} = {
          type = "app";
          program = "${self.packages."${system}".{{ cookiecutter.project_slug }}}/bin/{{ cookiecutter.project_slug }}";
        };
      });
}
