function setup() {
    sudo apt update
    sudo apt install -y bc bash git-core gnupg build-essential \
        zip curl make automake autogen autoconf autotools-dev \
        libtool shtool python3 m4 gcc libtool zlib1g-dev \
        flex bison libssl-dev libelf-dev device-tree-compiler

    # Proton Clang — patched for kernel 4.9
    git clone https://github.com/kdrag0n/proton-clang \
        --depth=1 clang

    # GCC as linker fallback
    git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 \
        -b android-10.0.0_r47 --depth=1 gcc

    # AnyKernel3
    git clone https://github.com/crsvt/AnyKernel3
}

setup
