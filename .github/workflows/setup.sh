function setup() {
    sudo apt update
    sudo apt install -y bc bash git-core gnupg build-essential \
        zip curl make automake autogen autoconf autotools-dev \
        libtool shtool python3 m4 gcc zlib1g-dev \
        flex bison libssl-dev libelf-dev device-tree-compiler

    # LineageOS GCC aarch64
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 \
        -b cm-14.1 --depth=1 gcc64

    # LineageOS GCC arm32 (for vdso)
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 \
        -b cm-14.1 --depth=1 gcc32

    # AnyKernel3
    git clone https://github.com/crsvt/AnyKernel3
}

setup
