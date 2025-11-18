{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

pkgs.mkShell {
  name = "llama-cpp-cuda-env";

  buildInputs = with pkgs; [
    # Build tools
    cmake
    ninja
    pkg-config
    just

    # Compilers
    gcc
    go

    # CUDA packages
    cudaPackages.cudatoolkit
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cccl
    cudaPackages.libcublas

    # Optional dependencies
    curl
    openblas
    ccache  # For faster rebuilds
  ];

  shellHook = ''
    export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
    export CUDA_HOME="${pkgs.cudaPackages.cudatoolkit}"
    export CUDA_TOOLKIT_ROOT_DIR="${pkgs.cudaPackages.cudatoolkit}"
    export CMAKE_CUDA_COMPILER="${pkgs.cudaPackages.cuda_nvcc}/bin/nvcc"
    export LD_LIBRARY_PATH="${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cuda_cudart}/lib:/run/opengl-driver/lib:$LD_LIBRARY_PATH"

    export PATH="${pkgs.cudaPackages.cuda_nvcc}/bin:$PATH"

    echo "Environment loaded. Use 'just' to run commands."
  '';
}
