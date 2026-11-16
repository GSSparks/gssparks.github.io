{
  description = "Gary Sparks personal website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              hugo   # extended variant (includes Dart Sass / libsass)
              rsync
              git    # needed for submodule theme
            ];

            shellHook = ''
              echo "hugo $(hugo version)"
            '';
          };
        }
      );
    };
}
