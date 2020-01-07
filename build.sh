#!/bin/bash

mkdir -p build

IMG="build/alpine-virt-do-$(date +%Y-%m-%d).qcow2"

./alpine-make-vm-image/alpine-make-vm-image \
    --image-format qcow2 \
    --script-chroot \
    --packages "$(cat packages)" \
    --repositories-file repositories \
    $IMG configure.sh

gzip $IMG
