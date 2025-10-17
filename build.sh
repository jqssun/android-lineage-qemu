#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y sudo git android-sdk-platform-tools python-is-python3 python3-yaml # libncurses5
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev
sudo apt install -y meson glslang-tools python3-mako
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
repo init -u https://github.com/LineageOS/android.git -b lineage-23.0 --git-lfs --no-clone-bundle
repo sync -j 8 # $(nproc)

# Clone MindTheGapps repository
git clone https://github.com/MindTheGapps/vendor_gapps.git vendor/gapps

# Create a makefile to include GApps
mkdir -p vendor/extra
cat <<'EOF' > vendor/extra/product.mk
ifeq ($(WITH_GMS),true)
$(call inherit-product, vendor/gapps/products/gms.mk)
endif
EOF

sed -i 's/-$(LINEAGE_BUILDTYPE)/-jqssun/g' vendor/lineage/config/version.mk

source build/envsetup.sh
export AB_OTA_UPDATER=false
# Set the flag to include GApps in the build
export WITH_GMS=true

breakfast virtio_arm64only userdebug
m recoveryimage
mv out/target/product/virtio_arm64only/recovery.img ../../recovery-userdebug.img
breakfast virtio_arm64only user # breakfast virtio_arm64only
m vm-utm-zip otapackage