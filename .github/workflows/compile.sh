# Kernel compile script
ROOT_DIR=$(pwd)

function compile() {
    export ARCH=arm64
    export PATH="${ROOT_DIR}/clang/bin:${ROOT_DIR}/gcc/bin:${PATH}"

    make O=out onc_defconfig

    make -j$(nproc --all) O=out \
        ARCH=arm64 \
        CC=clang \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE=aarch64-linux-android-
}

compile
