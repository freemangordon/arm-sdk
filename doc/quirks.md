Notes and quirks for specific devices
=====================================

## Raspberry Pi 2
* This build script will create an image that works on the Raspberry Pi 3 as
  well. It also includes the required firmware for getting onboard Wifi/Bluetooth
  working.

## Acer Chromebook
* The Chromebook I tested this image on names the wireless interface `mlan0`, so
  please keep note of it when you try connecting to an access point.

## BeagleBone Black
* In `/root/` you will find the `xorg.conf` needed to run X properly. You will
  also find a shell script that allows you to use USB as an ethernet device

## OUYA Gaming console
* This image is intended to be booted from a USB stick and the kernel to be run
  from memory. dd the image on a USB flash drive.
* You will need android tools
* Run the bootloader

```
adb reboot-bootloader
```

* Load the kernel that's in `arm/extra/ouya` with:

```
fastboot boot zImage-3.1.10-tk*
```
## Nokia N900
* [http://pub.parazyd.cf/N900/merlijnsdocs.txt](http://pub.parazyd.cf/N900/merlijnsdocs.txt)
* [http://talk.maemo.org/showthread.php?t=81613](http://talk.maemo.org/showthread.php?t=81613)
* The `uImage` can be found in the `/root/` directory in the image.

