# boot mode
if [ "$BOOTMODE" != true ]; then
  abort "- Please install via Magisk/KernelSU app only!"
fi

# space
ui_print " "

# var
UID=`id -u`

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# run
. $MODPATH/function.sh

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
  sed -i 's|#k||g' $MODPATH/post-fs-data.sh
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# sdk
NUM=21
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API."
  ui_print "  You have to upgrade your Android version"
  ui_print "  at least SDK $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# miuicore
if [ ! -d /data/adb/modules_update/MiuiCore ]\
&& [ ! -d /data/adb/modules/MiuiCore ]; then
  ui_print "! Miui Core Magisk Module is not installed."
  ui_print "  Please read github installation guide!"
  abort
else
  rm -f /data/adb/modules/MiuiCore/remove
  rm -f /data/adb/modules/MiuiCore/disable
fi

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# cleaning
ui_print "- Cleaning..."
PKGS=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKG in $PKGS; do
    RES=`pm uninstall $PKG 2>/dev/null`
  done
fi
remove_sepolicy_rule
ui_print " "

# function
test_signature() {
FILE=`find $MODPATH/system -type f -name $APP.apk`
ui_print "- Testing signature..."
RES=`pm install -g -i com.android.vending $FILE`
if [ "$RES" ]; then
  ui_print "  $RES"
fi
if [ "$RES" == Success ]; then
  RES=`pm uninstall -k $PKG 2>/dev/null`
  ui_print "  Signature test is passed"
elif [ -d /data/adb/modules_update/luckypatcher ]\
|| [ -d /data/adb/modules/luckypatcher ]; then
  ui_print "  Enabling Patches to Android Lucky Patcher Module..."
  rm -f /data/adb/modules/luckypatcher/remove
  rm -f /data/adb/modules/luckypatcher/disable
elif echo "$RES" | grep -q INSTALL_FAILED_SHARED_USER_INCOMPATIBLE; then
  ui_print "  Signature test is failed"
  ui_print "  But installation is allowed for this case"
  ui_print "  Make sure you have deactivated your Android Signature"
  ui_print "  Verification, otherwise the app cannot be installed correctly."
  ui_print "  If you don't know what is it, please READ Troubleshootings!"
elif echo "$RES" | grep -q INSTALL_FAILED_INSUFFICIENT_STORAGE; then
  ui_print "  Please free-up your internal storage first!"
  abort
else
  ui_print "  ! Signature test is failed"
  ui_print "    You need to disable Signature Verification of your"
  ui_print "    Android first to use this module. READ Troubleshootings!"
  ui_print "    Or maybe just insufficient storage."
  if [ "`grep_prop force.install $OPTIONALS`" != 1 ]; then
    abort
  fi
fi
ui_print " "
}

# test
APP=MiuiScreenRecorder
PKG=com.miui.screenrecorder
if [ "$BOOTMODE" == true ]; then
  if ! appops get $PKG > /dev/null 2>&1; then
    test_signature
  fi
fi

# code
FILE=$MODPATH/service.sh
NAME=ro.miui.ui.version.code
if [ "`grep_prop miui.code $OPTIONALS`" == 0 ]; then
  ui_print "- Removing $NAME..."
  sed -i "s|resetprop -n $NAME|#resetprop -n $NAME|g" $FILE
  ui_print "  The quick settings tile will not be working."
  ui_print " "
fi

# features
PROP=`grep_prop miui.features $OPTIONALS`
FILE=$MODPATH/service.sh
if [ "$PROP" == 0 ]; then
  ui_print "- Removing ro.screenrec.device changes..."
  sed -i 's|resetprop -n ro.screenrec.device cepheus||g' $FILE
  ui_print " "
elif [ "$PROP" ] && [ "$PROP" != 1 ]; then
  ui_print "- ro.screenrec.device will be changed to $PROP"
  sed -i "s|cepheus|$PROP|g" $FILE
  ui_print " "
fi

# fix renderer
FILE=$MODPATH/service.sh
if [ "`grep_prop miui.fix.renderer $OPTIONALS`" == 1 ]; then
  ui_print "- Removes debug.hw.renderer if it's using skia"
  sed -i 's|#r||g' $FILE
  ui_print " "
fi

# function
permissive_2() {
sed -i 's|#2||g' $MODPATH/post-fs-data.sh
}
permissive() {
FILE=/sys/fs/selinux/enforce
SELINUX=`cat $FILE`
if [ "$SELINUX" == 1 ]; then
  if ! setenforce 0; then
    echo 0 > $FILE
  fi
  SELINUX=`cat $FILE`
  if [ "$SELINUX" == 1 ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    if ! setenforce 1; then
      echo 1 > $FILE
    fi
    sed -i 's|#1||g' $MODPATH/post-fs-data.sh
  fi
else
  sed -i 's|#1||g' $MODPATH/post-fs-data.sh
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# function
extract_lib() {
for APP in $APPS; do
  FILE=`find $MODPATH/system -type f -name $APP.apk`
  if [ -f `dirname $FILE`/extract ]; then
    rm -f `dirname $FILE`/extract
    ui_print "- Extracting..."
    DIR=`dirname $FILE`/lib/"$ARCH"
    mkdir -p $DIR
    rm -rf $TMPDIR/*
    DES=lib/"$ABI"/*
    unzip -d $TMPDIR -o $FILE $DES
    cp -f $TMPDIR/$DES $DIR
    ui_print " "
  fi
done
}
hide_oat() {
for APP in $APPS; do
  REPLACE="$REPLACE
  `find $MODPATH/system -type d -name $APP | sed "s|$MODPATH||g"`/oat"
done
}

# extract
APPS="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
extract_lib
# hide
hide_oat









