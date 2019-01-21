#!/bin/sh
kernel_version=4.14.93

kernel_volumes="--volume $PWD/kernel_config:/home/tc/kernel_config \
                --volume $PWD/kernel_defconfig:/home/tc/kernel_defconfig \
                --volume $PWD/kernel_patches:/home/tc/kernel_patches"

sudo podman container exists boot2podman-kernel \
	|| sudo podman run -d --name=boot2podman-kernel $kernel_volumes boot2podman-docker-tinycore.bintray.io/tinycore-compiletc:9.0-x86_64 sleep 3600
$(sudo podman inspect --format '{{.State.Running}}' boot2podman-kernel) \
	|| sudo podman start boot2podman-kernel

podman_cp() {
	mnt=$(sudo podman mount $1)
	sudo cp -pR $2 ${mnt}/$3
	sudo podman umount $1
}

test -r linux-$kernel_version.tar.xz \
	|| wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$kernel_version.tar.xz
sudo podman exec boot2podman-kernel test -e /home/tc/linux-$kernel_version.tar.xz \
	|| podman_cp boot2podman-kernel linux-$kernel_version.tar.xz /home/tc/linux-$kernel_version.tar.xz

sudo podman exec boot2podman-kernel sh -x < compile_kernel