# Miui Screen Recorder Magisk Module

## DISCLAIMER
- Miui apps are owned by Xiaomi™.
- The MIT license specified here is for the Magisk Module only, not for Miui apps.

## Descriptions
- Screen Recorder app by Xiaomi Inc. ported and integrated as a Magisk Module for all supported and rooted devices with Magisk
- There is no icon launcher in app drawer/home screen on Minimum SDK 29 variant, launch from quick settings instead.

## Sources
- https://apkmirror.com com.miui.screenrecorder by Xiaomi Inc.
- libmagiskpolicy.so: Magisk (stable) 30.7 (30700)

## Changelog

v2.14
- Prepare /storage/emulated/"$UID"/Android/data/$PKG/files directories in minimum SDK 29 variant
- Support NoMount metamodule
- Update libmagiskpolicy.so from Magisk (stable) 30.7 (30700)
- Resets module folders/files permissions at post-fs-data
- Move _uninstall.log to /data/adb/logs/

v2.13
- Fix wrong target in latest KernelSU
- Fix permissive move

v2.12
- Remove miui.fix.renderer optional
- Improve /odm and /my_product support detection

v2.11
- Add Minimum SDK 29 variant with MiuiScreenRecorder.apk v2.14.2.3.1
- Add Action button to clear app caches
- "not enough space" detection at installation
- Fix architecture detection in some weird ROMs
- Add new optional miui.hevc for Minimum SDK 29 variant
- Improve media profiles*.xml maxFrameRate patch
- Fix bug in uninstall.sh
- Fix SystemUI visibility while changing between dark and light theme immediately

v2.10
- Fix status bar visibility
- Fix conflict with modules_update while installing via recovery if Magisk installed
- Move miui.code optional to Miui Core
- Fix MagiskHide & SUList

v2.9
- Fix view saved screen recording to Gallery
- Does not disable Patch to Android Lucky Patcher Module after boot

v2.8
- Redirect /sdcard to /data/media/"$UID"
- Change optional miui.opengl to miui.fix.renderer (disabled by default)
- Fix MagiskHide & SUList
- Patches plat_seapp_contexts to fix crash caused by seinfo default not found
- Kitsune Mask detection

v2.7
- Specify UID at script
- Add optional debug.log=1 for more detailed install log
- Move uninstall log to /data/media/.../..._uninstall.log

v2.6
- Turns debug.hwui.renderer to opengl and debug.renderengine.backend to openglthreaded
- Add new Optionals
- Using dex version 035 fix for Android Oreo and bellow
- KernelSU support
- Magisk v26.1 support
- Save install log at /sdcard/..._recovery.log while installing via Recovery
- Save uninstall log at /data/adb/modules/..._uninstall.log
- Fix optional permissive mode
- Set blacklist/whitelist

v2.5
- Fixed resources conflict in some ROMs
- Universal gallery app
- Does not change ro.product.name
- Using original Settings$System
- Cleaning protected storage
- Creates /sdcard/optionals.prop file if doesn't exist
- Using magiskpolicy --live --apply sepolicy.pfsd if sepolicy.sh=1
- Using sys.boot_completed=1 detection

## Screenshots
https://t.me/ryukimodsscreenshots/60

## Requirements
- NOT in Miui ROM
- Magisk or Kitsune Mask or KernelSU or Apatch installed
- Any AOSP Signatured ROM or disabled Android Signature Verification for non-AOSP Signatured ROM to allow android.uid.system. Tap here: https://t.me/ryukinotes/81
- Miui Core Magisk Module installed

## Installation Guide & Download Link
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings and install https://github.com/KernelSU-Modules-Repo/meta-overlayfs or https://github.com/KernelSU-Modules-Repo/magic_mount_rs or https://github.com/KernelSU-Modules-Repo/hybrid_mount or https://github.com/maxsteeel/nomount first depending on ROM compatibility
- Install Miui Core Magisk Module first: https://github.com/reiryuki/Miui-Core-Magisk-Module
- Download the right module according to your Android version:
  - Minimum SDK 29:
  - Minimum SDK 21:
- Install the module via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- If installation failed, READ Troubleshootings bellow!
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (and your home launcher app also) (enable show system apps) and reboot afterwards
- If you are using SUList, you need to allow list manually your home launcher app (enable show system apps) and reboot afterwards

## Optionals
- https://t.me/ryukinotes/42
- Global: https://t.me/ryukinotes/35

## Troubleshootings
- https://t.me/ryukinotes/19
- Global: https://t.me/ryukinotes/34

## Known Issue
No audio playback while recording with system sounds in Minimum SDK 21 variant

## Support & Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- https://t.me/androidryukimodsdiscussions
- https://t.me/androidappsportdevelopment

## Sponsors
https://t.me/ryukinotes/25


