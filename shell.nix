{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

pkgs.mkShell {
  name = "llama-cpp-cuda-env";

  buildInputs = with pkgs; [
    # Build tools
    cmake
    ninja
    pkg-config

    # Compilers
    gcc

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

    # Create helper scripts
    mkdir -p .direnv/bin
    cat > .direnv/bin/build <<'EOF'
#!/usr/bin/env bash
cmake -B build -DGGML_CUDA=ON -DGGML_BLAS=ON -DGGML_NATIVE=ON -DCMAKE_CUDA_ARCHITECTURES="86" && cmake --build build --config Release -j 24
EOF
    cat > .direnv/bin/rebuild <<'EOF'
#!/usr/bin/env bash
cmake --build build --config Release -j 24
EOF
    cat > .direnv/bin/clean <<'EOF'
#!/usr/bin/env bash
rm -rf build
EOF
    cat > .direnv/bin/sync <<'EOF'
#!/usr/bin/env bash
git remote add upstream git@github.com:ggml-org/llama.cpp.git 2>/dev/null || true && git fetch --all && git rebase upstream/master
EOF
    chmod +x .direnv/bin/*

    export PATH="$PWD/.direnv/bin:${pkgs.cudaPackages.cuda_nvcc}/bin:$PATH"

    echo "🔨 build - Full build from scratch"
    echo "⚡ rebuild - Incremental rebuild"
    echo "🧹 clean - Remove build directory"
    echo "🔄 sync - Sync with upstream and rebase"
  '';
}
