#!/bin/bash

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
AOSP_DIR="$SCRIPT_DIR/../../.."
OUT_DIR="$AOSP_DIR/out/target/product/pc_x86_64"

KERNEL_PATH="$OUT_DIR/kernel"
RAMDISK_PATH="$OUT_DIR/ramdisk.img"
CMDLINE=()
CMDLINE+=("loop.max_part=7")
CMDLINE+=("androidboot.hardware=pc")
CMDLINE+=("androidboot.boot_devices=any")
CMDLINE+=("androidboot.init_fatal_reboot_target=recovery")
CMDLINE+=("androidboot.first_stage_console=2")
CMDLINE+=("androidboot.selinux=permissive")
CMDLINE+=("8250.nr_uarts=1")
CMDLINE+=("console=ttyS0,115200n8")
CMDLINE+=("printk.devkmsg=on")

BIOS_PATH="/usr/share/edk2/x64/OVMF.4m.fd"

QEMU_FLAGS=()

# KVM
QEMU_FLAGS+=("-enable-kvm")

# Serial and monitor
QEMU_FLAGS+=("-serial" "stdio")
QEMU_FLAGS+=("-chardev" "vc,id=monitor")
QEMU_FLAGS+=("-mon" "monitor")

# Platform
QEMU_FLAGS+=("-machine" "q35,accel=kvm")
QEMU_FLAGS+=("-bios" "$BIOS_PATH")
QEMU_FLAGS+=("-no-shutdown")
QEMU_FLAGS+=("-no-reboot")

# Kernel
QEMU_FLAGS+=("-kernel" "$KERNEL_PATH")
QEMU_FLAGS+=("-initrd" "$RAMDISK_PATH")
QEMU_FLAGS+=("-append" "${CMDLINE[*]}")

# CPU and memory
QEMU_FLAGS+=("-cpu" "host")
QEMU_FLAGS+=("-smp" "24")
QEMU_FLAGS+=("-m" "16G")

# Display
QEMU_FLAGS+=("-display" "sdl,gl=on,show-cursor=on")
QEMU_FLAGS+=("-vga" "none")
QEMU_FLAGS+=("-device" "virtio-vga-gl,hostmem=4G,blob=true,venus=true")

# Network
QEMU_FLAGS+=("-device" "e1000,netdev=net0")
QEMU_FLAGS+=("-netdev" "user,id=net0,hostfwd=tcp::5555-:5555")

# USB
QEMU_FLAGS+=("-device" "qemu-xhci")

# Input devices
QEMU_FLAGS+=("-device" "usb-mouse")

# Audio devices
QEMU_FLAGS+=("-device" "ich9-intel-hda")
QEMU_FLAGS+=("-device" "hda-duplex")
QEMU_FLAGS+=("-device" "usb-audio")

# RTC
QEMU_FLAGS+=("-rtc" "base=utc")

# Storage
QEMU_FLAGS+=("-blockdev" "node-name=q1,driver=raw,file.driver=host_device,file.filename=/dev/sda")
QEMU_FLAGS+=("-device" "virtio-blk,drive=q1")

qemu-system-x86_64 "${QEMU_FLAGS[@]}"
