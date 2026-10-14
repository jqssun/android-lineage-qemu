#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export _JAVA_OPTIONS="-Xmx25g"
export LZ4_COMPRESSION_LEVEL=9
export ANDROID_QUIET_BUILD=true
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export PYTHONDONTWRITEBYTECODE=true
export BUILD_ENFORCE_SELINUX=1
export DEBIAN_FRONTEND=noninteractive
ccache -M 50G
cd lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --no-clone-bundle --depth=1
repo sync -j 4 --fail-fast --force-sync --no-clone-bundle
source build/envsetup.sh
breakfast virtio_arm64only user 
m vm-utm-zip
