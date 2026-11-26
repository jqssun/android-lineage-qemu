#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y sudo git android-sdk-platform-tools python-is-python3 python3-yaml qemu-utils # libncurses5
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
sudo apt install -y meson-1.5 glslang-tools python3-mako
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git config --global trailer.changeid.key "Change-Id"
git config --global color.ui true
git lfs install

unset REPO_URL
mkdir -p bin android/lineage
curl https://storage.googleapis.com/git-repo-downloads/repo > bin/repo
chmod a+x bin/repo
export PATH="$(realpath .)/bin:$PATH"
cd android/lineage
export PATH="$(realpath .)/prebuilts/sdk/tools/linux/bin/:$PATH"
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --no-clone-bundle --depth 1
repo sync -c --prune --force-sync --fail-fast --retry-fetches=8 -j 8
sed -i 's/-$(LINEAGE_BUILDTYPE)/-jqssun/g' vendor/lineage/config/version.mk

source build/envsetup.sh
export AB_OTA_UPDATER=false ROOMSERVICE_BRANCHES="lineage-24.0 lineage-23.2"

breakfast virtio_arm64only user
sed -i 's#</resources>#<integer name="config_defaultRefreshRate">0</integer><integer name="config_defaultPeakRefreshRate">1000</integer>\n</resources>#' device/virt/virt-common/overlays/overlay/frameworks/base/core/res/res/values/config.xml
sed -i 's/^BOARD_KERNEL_IMAGE_NAME := Image$/BOARD_KERNEL_CMDLINE += arm64.nobti\n&/' device/virt/virtio_arm64/BoardConfig.mk
sed -i 's/^# Camera$/&\nTARGET_SUPPORTS_EXTERNAL_CAMERAS := true/' device/virt/virt-common/virt-common.mk
sed -i 's/context=u:object_r:firmware_file:s0/context=u:object_r:firmware_mnt_file:s0/' device/virt/virt-common/configs/init/init.virt.rc
sed -i 's#^firmware_directories /vendor/firmware_mnt$#&/#' device/virt/virt-common/configs/init/ueventd.virt.rc
sed -i '$a allow kernel firmware_mnt_file:system firmware_load;' device/virt/virt-common/sepolicy/vendor/kernel.te
sed -i '/^ro\.boot\.wifi_mac_prefix=/d' device/virt/virt-common/configs/properties/vendor.prop
for p in ../../patches/*.patch; do patch -p1 < "$p"; done

breakfast virtio_x86_64 userdebug
m recoveryimage
mv out/target/product/virtio_x86_64/recovery.img ../../recovery_x86_64-userdebug.img

breakfast virtio_x86_64 user
m vm-utm-zip otapackage
mv out/target/product/virtio_x86_64/boot.img ../../boot_x86_64.img
mv out/target/product/virtio_x86_64/recovery.img ../../recovery_x86_64.img

breakfast virtio_arm64only userdebug
m recoveryimage
mv out/target/product/virtio_arm64only/recovery.img ../../recovery_arm64only-userdebug.img

breakfast virtio_arm64only user
m vm-utm-zip otapackage
mv out/target/product/virtio_arm64only/boot.img ../../boot_arm64only.img
mv out/target/product/virtio_arm64only/recovery.img ../../recovery_arm64only.img
