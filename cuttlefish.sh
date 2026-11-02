#!/bin/bash

# Variables d'environnement pour virgl
export ANDROID_ACCELERATOR=guest_virtio_gpu
export VIRGL_RENDERER=1
export MESA_GL_VERSION_OVERRIDE=4.5

# Démarrage Cuttlefish
cd ~/cuttlefish-install
./launch_cvd.sh \
  --target=aosp_cf_phone-userdebug \
  --gpu_mode=vulkan \
  --num_cpus=4 \
  --memory_size_mb=4096 \
  --enable-webview=true \
  --enable_selinux=enforcing \
  --system_image_path=/chemin/vers/system.img
