# Embedded Linux Image Builder

![embedded-linux-image-builder](./images/embedded.png)

This project creates a fully customized embedded Linux image from the source (like Linux From Scratch). You can use this project to fully customize your embedded Linux image, like changing kernel configuration, creating new Linux distros, customizing images for other board variants, etc. For using the project, there is no need to meet or set up any special environment as it uses Docker.
I've used BeagleBone Black as the target system with Ubuntu 18.04 and Ti's Linux Kernel 4.19.94.

## Features

* Based on Docker so can be run on any machine without any requirements.
* Build Kernel, DTS, modules, and headers from the source.
* Build Bootloader (u-boot) from the source.
* Can be combined with any Linux distribution.
* Create image file (.img) as output file for easy writing to SD card.
* High-speed build with the help of using Linaro toolchain and Docker engine.
* Can be used with any Embedded Linux system with little configuration change.

## Requirements

* [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/)
* If you are using Windows, make sure to use the latest [WSL 2](https://docs.docker.com/docker-for-windows/wsl/) backend as the device-mapper kernel driver is missing in older WSL versions. Otherwise, you need to build the SD Card manually.
* Download resource files and put them in the `resources` directory:
  * Linaro cross-compile toolchain.
    * You can get the binaries from [here](https://www.linaro.org/downloads/).
  * Linux Kernel source for your board.
    * For BeagleBone Black, you can use the official [kernel](https://github.com/beagleboard/linux)
  * u-boot [source code](https://github.com/u-boot/u-boot).
  * A base rootfs Linux distro.
    * You can grab Ubuntu or Debian distro from [here](https://rcn-ee.com/rootfs/eewiki/minfs/).
    * [Ubuntu 18.04.3](https://rcn-ee.com/rootfs/eewiki/minfs/ubuntu-18.04.3-minimal-armhf-2020-02-10.tar.xz) used in this project.
  * As the compile process may take longer, you need to increase the Docker engine resources:
    * [Windows](https://docs.docker.com/docker-for-windows/#advanced#resources)
    * [Mac](https://docs.docker.com/docker-for-mac/#memory#resources)

## How to use

1. Make sure that you meet the requirements and put the necessary files into the `resources` directory:
    * For example:

      ```bash
      project
      └───resources
      │   │   armhf-rootfs-ubuntu-bionic.tar
      │   │   gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar
      │   │   linux-4.19.94-ti-rt-r41.tar.gz
      │   │   u-boot-2020.04-rc3.tar.gz

      ```

2. Make sure to decompress the Linux rootfs to get the right compressed file. The files contain all the Linux rootfs inside its root directory (e.g., `armhf-rootfs-ubuntu-bionic.tar`).
3. Set the Dockerfile parameters in `docker-compose.yml`:
   * `kernel_version`: kernel version in X.Y.Z format
   * `kernel_filename`: kernel source file path
   * `kernel_defconfig`: kernel configuration file
   * `uboot_filename`: u-boot source file path
   * `uboot_defconfig`: u-boot configuration file
   * `rootfs_filename`: Linux Root file system path
   * `linaro_filename`: Linaro toolchain file path

4. Bring up the console and navigate to the project root directory, and execute

   ```bash
   docker-compose up --build
   ```

5. If the process is complete successfully, you should get the image file `sd_image.img` and `rootfs.tar.gz` in the `output` directory.

6. You can write `sd_image.sd` directly to the SD Card or manually partition your SD and copy the contents of `rootfs.tar.gz` into the SD partitions.

## Credits

* Masoud Rahimi: [masoudrahimi.com](http://masoudrahimi.com)
