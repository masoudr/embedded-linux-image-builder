FROM ubuntu:18.04

ARG kernel_version
ARG kernel_filename
ARG kernel_defconfig
ARG uboot_filename
ARG uboot_defconfig
ARG rootfs_filename
ARG linaro_filename

ENV PATH "/lfs/linaro/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    xz-utils bc bison flex libssl-dev make libc6-dev libncurses5-dev lzop kmod \
    util-linux kpartx dosfstools e2fsprogs gddrescue qemu-utils

# create directories
RUN mkdir -p /lfs/output /lfs/kernel /lfs/u-boot /lfs/rootfs/boot /lfs/rootfs/rootfs /lfs/linaro /lfs/rootfs/rootfs/boot

# copying necessary files from host to container
COPY ${kernel_filename} /lfs/kernel.tar.gz
COPY ${uboot_filename} /lfs/u-boot.tar.gz
COPY ${rootfs_filename} /lfs/rootfs.tar
COPY ${linaro_filename} /lfs/linaro.tar

# extract copied files
RUN tar xpf /lfs/kernel.tar.gz -C /lfs/kernel --strip-components=1
RUN tar xpf /lfs/u-boot.tar.gz -C /lfs/u-boot --strip-components=1
RUN tar xpf /lfs/linaro.tar -C /lfs/linaro --strip-components=1
RUN tar xpf /lfs/rootfs.tar -C /lfs/rootfs/rootfs

# compile Kernel
WORKDIR /lfs/kernel
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- ${kernel_defconfig}
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc) zImage dtbs modules

# install kernel modules and headers
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc) modules_install INSTALL_MOD_PATH=/lfs/rootfs/rootfs
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc) headers_install INSTALL_HDR_PATH=/lfs/rootfs/rootfs/usr

# compile u-boot
WORKDIR /lfs/u-boot
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- ${uboot_defconfig}
RUN make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc)

# install u-boot files
RUN sh -c "echo 'uname_r=${kernel_version}\nconsole=ttyO0,115200n8' >> /lfs/rootfs/boot/uEnv.txt"
RUN cp /lfs/u-boot/MLO /lfs/rootfs/boot
RUN cp /lfs/u-boot/u-boot.img /lfs/rootfs/boot
RUN cp /lfs/u-boot/MLO /lfs/rootfs/rootfs/boot/uboot
RUN cp /lfs/u-boot/u-boot.img /lfs/rootfs/rootfs/boot/uboot

# install kernel binary and device tree
RUN cp /lfs/kernel/arch/arm/boot/zImage /lfs/rootfs/rootfs/boot
RUN cp /lfs/kernel/arch/arm/boot/dts/am335x-boneblack.dtb /lfs/rootfs/rootfs/boot

# change to the output directory
WORKDIR /lfs/output

# copy image generator script and set permissions
COPY ./image_generator.sh /lfs/image_generator.sh
RUN ["chmod", "+x", "/lfs/image_generator.sh"]

ENTRYPOINT [ "/lfs/image_generator.sh" ]
