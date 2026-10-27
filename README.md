# LineageOS for QEMU Virtual Machines

[![GitHub](https://img.shields.io/github/downloads/jqssun/android-lineage-qemu/total?label=GitHub%20downloads&logo=GitHub)](https://github.com/jqssun/android-lineage-qemu/releases)
[![license](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/jqssun/android-lineage-qemu/blob/main/LICENSE)
[![build](https://img.shields.io/github/actions/workflow/status/jqssun/android-lineage-qemu/build.yml)](https://github.com/jqssun/android-lineage-qemu/actions/workflows/build.yml)

[LineageOS](https://lineageos.org/Changelog-32/) builds for running Android VM on 
- [any macOS/iOS device (via UTM)](https://wiki.lineageos.org/utm-vm-on-apple-silicon-mac), or 
- [generic libvirt QEMU virtual machines](https://wiki.lineageos.org/libvirt-qemu#create-and-configure-the-virtual-machine-using-virt-manager)

For the latest builds, see [Releases](https://github.com/jqssun/android-lineage-qemu/releases/latest).

<img alt="lineage" src="https://github.com/user-attachments/assets/442b5d82-1b32-4702-b3c1-70c6b033ee58" />

## Usage

- For first time installs, download [`UTM-VM-lineage-*.zip`](https://github.com/jqssun/android-lineage-qemu/releases/latest) and unzip. For iPhone, iPad, Mac (Apple silicon), Windows on Arm, and ARM64 Linux, using the `arm64only` build is recommended. For Mac (Intel), Windows PC, x86_64 Linux, or specific cases where UTM is limited to JIT mode, use the `x86_64` build. To run via `qemu-system` directly, see [Development](#development).

- To install an update package, boot into **LineageOS Recovery**, select **Apply update**, then **Apply from ADB**. Use [`lineage_virtio_arm64only-ota.zip`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/lineage_virtio_arm64only-ota.zip) or [`lineage_virtio_x86_64-ota.zip`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/lineage_virtio_x86_64-ota.zip) from releases if updating to a new LineageOS build, or use your own update package. On the host, run
```shell
adb sideload [*.zip]
```

### Generic System Images (GSI)

[These `arm64` and `x86_64` virtual machine images are typically compatible with GSIs of an equivalent or later Android version.](https://wiki.lineageos.org/libvirt-qemu#run-generic-system-images-inside-the-virtual-machine) First, download and unzip the image archive from [Generic System Image releases](https://developer.android.com/topic/generic-system-image/releases) to obtain `system.img`. You generally want `{gsi_gms,aosp}_{arm64,x86_64}*.zip` archives, but other GSI compatible Android/ALOS images may also be supported. Once you have the image, you can either [try running it directly](#using-gsi-directly) or [flash it to the virtual machine's partition permanently](#installing-gsi-to-virtual-machine-permanently).

#### Using GSI Directly

If you are using UTM, [import the image as the third `VirtIO Drive`](https://docs.getutm.app/settings-qemu/drive/drive/#importing) by going to **Drives**, select **New...**, **Import**, then locate the GSI `system.img` file, and **Save**. For `virt-manager`, use **Add Hardware**, then **Storage** to attach the system image. Alternatively if using `qemu-system-*`, append the `-drive` option to add the image directly.
```shell
-device virtio-blk-pci,drive=vdc \
-drive file=$SYSTEM_IMG,if=none,id=vdc,discard=unmap,detect-zeroes=unmap
```

#### Installing GSI to Virtual Machine Permanently

Flash the GSI in `fastbootd` by booting into **LineageOS Recovery**. Select **Advanced**, then **Enter fastboot**. On the host, run
```shell
fastboot -s tcp:$HOST_IP delete-logical-partition product
fastboot -s tcp:$HOST_IP delete-logical-partition system_ext
fastboot -s tcp:$HOST_IP flash system $SYSTEM_IMG
```

#### Using GSI

Unless this is the first boot of the virtual machine, you must perform a factory reset before booting into the GSI. If you run into issues, you can set `SELinux` to permissive mode at boot by selecting **Settings**, **SELinux**, then **Permissive**. To boot the GSI, select **Advanced options**, then **Boot GSI from /dev/block/vdc with LineageOS \* (Kernel version \*)**.

If you experience any input issues when using a GSI in UTM, you should use **View**, **Enter Full Screen**, and re-enable **Capture input devices** mode. [You can exit this mode by pressing `⌃`+`⌥` at the same time.](https://docs.getutm.app/preferences/macos/#input)

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

[LineageOS Recovery supports sideloading unsigned update files.](https://review.lineageos.org/c/LineageOS/android_bootable_recovery/+/368223) To allow this, you need to install a non-release version of the recovery image. To put the virtual machine in `fastbootd`, boot into **LineageOS Recovery**, select **Advanced**, then **Enter fastboot**. On the host, download [`recovery_arm64only-userdebug.img`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/recovery_arm64only-userdebug.img) from releases and run
```shell
fastboot -s tcp:$HOST_IP flash recovery recovery_*-userdebug.img
```

### Installing Google Apps

[If you choose to install Google apps](https://wiki.lineageos.org/gapps/#installation), they must be installed immediately after a factory reset (or at first boot) via recovery. Additionally, you need to first [bypass signature verification in recovery](#bypassing-signature-verification-in-recovery).

Follow the [instructions to install an update package](#usage). Use the [Google apps package for the **Mobile**, **ARM64** variant](https://wiki.lineageos.org/gapps/#downloads) on `arm64` builds.

For the `x86_64` virtual machine image, you may need to additionally resize the `product` partition while in `fastbootd`
```shell
fastboot -s tcp:$HOST_IP resize-logical-partition product 1610612736
```

To complete the resizing for the `x86_64` image, boot back into **LineageOS Recovery** and use
```shell
adb -s $HOST_IP:5555 shell e2fsck -fy /dev/block/mapper/product
adb -s $HOST_IP:5555 shell resize2fs /dev/block/mapper/product
```

### Installing Magisk

To install [Magisk](https://github.com/topjohnwu/Magisk/releases/latest), download [`boot_arm64only.img`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/boot_arm64only.img) or [`boot_x86_64.img`](https://github.com/jqssun/android-lineage-qemu/releases/latest/download/boot_x86_64.img) from releases, and patch it on a running instance of this LineageOS build following the [instructions](https://topjohnwu.github.io/Magisk/install.html#patching-images). Pull the patched image `magisk_patched*.img` from the device, [put the device in `fastbootd`](#bypassing-signature-verification-in-recovery), then run
```shell
fastboot -s tcp:$HOST_IP flash boot magisk_patched*.img
```

## Building

All releases are built using [Actions](https://github.com/features/actions). Current releases can also be attested using [GitHub CLI](https://github.com/cli/cli).

```shell
gh attestation verify *.zip -R jqssun/android-lineage-qemu
```

This repository provides the build script to compile LineageOS on the latest Ubuntu, and assumes you already have root access via `sudo` with `apt` and `git` in your `$PATH`. It may also work with other Linux distributions, but these configurations are not tested.

To build these images yourself via CI (e.g. GitHub Actions), fork this repository, then go to **Actions**, select **Build**, and select **Run workflow**. Under **Runner**, you can either use a GitHub-hosted runner by entering `ubuntu-latest`, or `self-hosted` for your own hardware.

## Development

To run the virtual machine via `qemu-system-*`, you may use these commands in the directory containing the extracted `LineageOS_on_*.utm` from `UTM-VM-lineage-*.zip`. This assumes you are using `qemu` installed via `Homebrew`, `nix-darwin` (macOS), `Procursus` (iOS), or your distribution's repositories (Linux).

Run the following to set the platform-agnostic `QEMU_OPTS` first, and then apply the platform-specific [`DARWIN_QEMU_OPTS`](#running-on-macos-or-ios) or [`LINUX_QEMU_OPTS`](#running-on-linux) accordingly before starting the virtual machine via `qemu-system-*`. Graphical output will appear on the `virtio-gpu-*` device. You can switch to this display by selecting **View** in the menu bar after boot selection.

```shell
read -r -d '' QEMU_OPTS << EOM
    -m 2048 \
    -smp 2 \
    -device virtio-blk-pci,drive=vda,bootindex=0 \
    -device virtio-blk-pci,drive=vdb,bootindex=1 \
    -drive if=pflash,unit=1,file=$(find ./LineageOS_on_*.utm/Data/efi_vars.fd) \
    -drive file=$(find ./LineageOS_on_*.utm/Data/vda.qcow2),if=none,id=vda,discard=unmap,detect-zeroes=unmap \
    -drive file=$(find ./LineageOS_on_*.utm/Data/vdb.qcow2),if=none,id=vdb,discard=unmap,detect-zeroes=unmap \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp:0.0.0.0:5555-:5555,hostfwd=tcp:0.0.0.0:5554-:5554 \
    -device usb-tablet,bus=usb-bus.0 \
    -device usb-mouse,bus=usb-bus.0 \
    -device usb-kbd,bus=usb-bus.0 \
    -device virtio-serial \
    -device virtio-rng-pci \
    -chardev stdio,mux=on,id=charconsole \
    -serial chardev:charconsole
EOM
```

### Running on macOS or iOS

Set `DARWIN_QEMU_OPTS` for macOS or iOS:
```shell
VMF_CODE=$(find /opt/homebrew/Cellar/qemu /nix/store/*-qemu-*/share -name "edk2-$(uname -m | sed 's/arm64/aarch64/')-code.fd" 2>/dev/null)
read -r -d '' DARWIN_QEMU_OPTS << EOM
    -device virtio-gpu-pci \
    -display cocoa,show-cursor=on \
    -device intel-hda \
    -device hda-output,audiodev=audio0 \
    -audiodev coreaudio,id=audio0 \
    -drive if=pflash,unit=0,file=$VMF_CODE,file.locking=off,format=raw,readonly=on \
    -device nec-usb-xhci,id=usb-bus \
    -device qemu-xhci,id=usb-controller-0 \
    $QEMU_OPTS
EOM
```
- For faster Hypervisor framework (HVF) acceleration on Mac (Apple silicon), use:
```shell
qemu-system-aarch64 -machine virt -accel hvf $DARWIN_QEMU_OPTS
```
- For slower cross-architecture emulation, use:
```shell
qemu-system-aarch64 -machine virt -cpu max,pauth-impdef=on -accel tcg,tb-size=1024,thread=multi $DARWIN_QEMU_OPTS
```
- For faster Hypervisor framework (HVF) acceleration on Mac (Intel), use:
```shell
qemu-system-x86_64 -machine q35 -vga none -cpu host -accel hvf $DARWIN_QEMU_OPTS
```

### Running on Linux

Set `LINUX_QEMU_OPTS` for Linux:
```shell
VMF_CODE=$(find /usr/share/ -name $([ "$(uname -m)" = "x86_64" ] && echo OVMF_CODE_4M || echo AAVMF_CODE).fd 2>/dev/null)
read -r -d '' LINUX_QEMU_OPTS << EOM
    -device virtio-gpu-pci -display sdl,gl=off \
    -drive if=pflash,unit=0,file=$VMF_CODE,file.locking=off,format=raw,readonly=on \
    -device usb-ehci,id=usb-bus \
    $QEMU_OPTS
EOM
```
If your device supports OpenGL acceleration, use `-device virtio-gpu-gl-pci -display sdl,gl=on` instead of `-device virtio-gpu-pci -display sdl,gl=off`.
- For faster KVM acceleration via Virtualization Host Extensions (VHEs) on ARM64 Linux, use:
```shell
qemu-system-aarch64 -machine virt,gic-version=3,highmem=off -cpu host -accel kvm $LINUX_QEMU_OPTS
```
- For slower cross-architecture emulation, use:
```shell
qemu-system-aarch64 -machine virt -cpu max,pauth-impdef=on -accel tcg,tb-size=1024,thread=multi $LINUX_QEMU_OPTS
```
- For faster KVM acceleration on x86_64 Linux, use:
```shell
qemu-system-x86_64 -machine q35 -vga none -cpu host -accel kvm $LINUX_QEMU_OPTS
```

## Credits

- [LineageOS](https://github.com/lineageos)
- [0xCAFEBABE](https://github.com/me-cafebabe)
