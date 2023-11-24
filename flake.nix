{
  description = "WhisperX: Automatic Speech Recognition with Word-level Timestamps (& Diarization)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-nvidia.url = "https://github.com/nixos/nixpkgs/archive/0fdc7224a24203d9489bc52892e3d6121cacb110.tar.gz";
  };

  outputs = { self, nixpkgs, flake-utils, pkgs-nvidia }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };

        pythonEnv = pkgs.python310.withPackages (ps: [
          ps.pytorch
        ]);
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pythonEnv ];

          shellHook = ''
            export CUDA_PATH=${pkgs-nvidia.cudatoolkit}
            export LD_LIBRARY_PATH=${pkgs-nvidia.linuxPackages.nvidia_x11}/lib:${pkgs-nvidia.ncurses5}/lib
            export EXTRA_LDFLAGS="-L/lib -L${pkgs-nvidia.linuxPackages.nvidia_x11}/lib"
            export EXTRA_CCFLAGS="-I/usr/include"
          '';
        };
      }
    )
}
