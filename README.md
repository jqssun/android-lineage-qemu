# LineageOS for QEMU Virtual Machines

[![license](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/jqssun/android-lineage-qemu/blob/main/LICENSE)
[![build](https://img.shields.io/github/actions/workflow/status/jqssun/android-lineage-qemu/build.yml)](https://github.com/jqssun/android-lineage-qemu/actions/workflows/build.yml)

[LineageOS](https://lineageos.org/Changelog-30/) builds for running Android VM on 
- [any macOS/iOS device (via UTM)](https://wiki.lineageos.org/utm-vm-on-apple-silicon-mac), or 
- [generic libvirt QEMU virtual machines](https://wiki.lineageos.org/libvirt-qemu#create-and-configure-the-virtual-machine-using-virt-manager)

For the latest CI release, see [releases](https://github.com/jqssun/android-lineage-qemu/releases/latest).

<img alt="lineage" src="https://github.com/user-attachments/assets/442b5d82-1b32-4702-b3c1-70c6b033ee58" />

## Usage

- For first time installs, download `UTM-VM-lineage-*.zip` from releases and unzip.

- To install an update package, boot into **LineageOS Recovery**, select **Apply update**, then **Apply from ADB**. Use [`lineage_virtio_arm64only-ota.zip`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/lineage_virtio_arm64only-ota.zip) from releases if updating to a new LineageOS build, or use your own update package. On the host, run
```shell
adb sideload [lineage_virtio_arm64only-ota.zip|*.zip]
```

### Android Debug Bridge (ADB)

[These targets offer ADB access over Ethernet or VirtIO VSOCK.](https://wiki.lineageos.org/libvirt-qemu#adb-connection) If running on macOS/iOS devices (via UTM), ports 5555 and 5554 (for `adbd` and `fastbootd`) are forwarded to the host device by default via `Emulated VLAN`. This means you can connect via
```shell
adb connect $HOST_IP
```
```shell
fastboot -s tcp:$HOST_IP [flash|reboot|...]
```
If running `adb` on the same host, no further configuration is needed and the device will be automatically detected as an emulator.

### Bypassing Signature Verification in Recovery

[LineageOS Recovery supports sideloading unsigned update files.](https://review.lineageos.org/c/LineageOS/android_bootable_recovery/+/368223) To allow this, you need to install a non-release version of the recovery image. To put the device in `fastbootd`, boot into **LineageOS Recovery**, select **Advanced**, then **Enter fastboot**. On the host, download [`recovery-userdebug.img`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/recovery-userdebug.img) from releases and run
```shell
fastboot -s tcp:$HOST_IP flash recovery recovery-userdebug.img
```

### Installing Google Apps

[If you choose to install Google apps](https://wiki.lineageos.org/gapps/#installation), they must be installed immediately after a factory reset (or at first boot) via recovery. Additionally, you need to first [bypass signature verification in recovery](#bypassing-signature-verification-in-recovery).

Follow the [instructions to install an update package](#usage). Use the [Google apps package for the **Mobile**, **ARM64** variant](https://wiki.lineageos.org/gapps/#downloads).

### Installing Magisk

To install [Magisk](https://github.com/topjohnwu/Magisk/releases/latest), download the [`boot.img`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/boot.img) from releases and patch it on a running instance of this LineageOS build following the [instructions](https://topjohnwu.github.io/Magisk/install.html#patching-images). Pull the patched image `magisk_patched*.img` from the device, [put the device in `fastbootd`](#bypassing-signature-verification-in-recovery), then run
```shell
fastboot -s tcp:$HOST_IP flash boot magisk_patched*.img
```

## Building

This repository provides the build script to compile LineageOS on the latest Ubuntu, and assumes you already have root access via `sudo` with `apt` and `git` in your `$PATH`. It may also work with other Linux distributions, but these configurations are not tested.

To build these images yourself via CI (e.g. GitHub Actions), fork this repository, then go to **Actions**, select **Build**, and select **Run workflow**. Under **Runner**, you can either use a GitHub-hosted runner by entering `ubuntu-latest`, or `self-hosted` for your own hardware.

## Credits

- [LineageOS](https://github.com/lineageos)
- [0xCAFEBABE](https://github.com/me-cafebabe)
