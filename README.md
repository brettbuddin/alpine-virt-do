# Alpine Linux Image for DigitalOcean

This project uses
[alpinelinux/alpine-make-vm-image](https://github.com/alpinelinux/alpine-make-vm-image)
to create an Alpine Linux image for use in DigitalOcean droplets. The image
collects hostname and root public key information from the [DigitalOcean
Metadata Service](https://developers.digitalocean.com/documentation/metadata/)
when the droplet is booted. The image also provides some sane defaults for
things like disabling `root` login via `sshd` and the creation of a non-root
`admin` user that has `sudo` access.

This repository contains submodules (for the VM image builder) which must be
initialized. You should clone the repository recursively:

```
git clone --recursive https://github.com/brettbuddin/alpine-virt-do
```

## Building

### From Linux

Ensure you have `gzip`, `qemu-img`, `qemu-nbd`, and `e2fsprogs` dependencies installed.

```
$ sudo ./build.sh
```

### From macOS

You will need [Vagrant](https://vagrantup.com) to build the image from a Linux
VM.

```
$ vagrant up
$ vagrant ssh -c "cd /vagrant && sudo ./build.sh"
```

The build will pause towards the end to ask for a password. This is for the new
administrative user the script is creating. It's safest to do this
interactively.

### Uploading to DigitalOcean

Upload the image at `build/*.qcow2.gz` at [Images > Custom
Images](https://cloud.digitalocean.com/images/custom_images).
