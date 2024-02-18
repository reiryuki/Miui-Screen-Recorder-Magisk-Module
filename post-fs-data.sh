mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`

# function
permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if ! setenforce 0; then
    echo 0 > /sys/fs/selinux/enforce
  fi
fi
}
magisk_permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
	magiskpolicy --live "permissive *"
  else
	$MODPATH/$ABI/libmagiskpolicy.so --live "permissive *"
  fi
fi
}
sepolicy_sh() {
if [ -f $FILE ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
    magiskpolicy --live --apply $FILE 2>/dev/null
  else
    $MODPATH/$ABI/libmagiskpolicy.so --live --apply $FILE 2>/dev/null
  fi
fi
}

# selinux
SELINUX=`getenforce`
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#1permissive
#2magisk_permissive
#kFILE=$MODPATH/sepolicy.rule
#ksepolicy_sh
FILE=$MODPATH/sepolicy.pfsd
sepolicy_sh

# list
PKGS=`cat $MODPATH/package.txt`
for PKG in $PKGS; do
  magisk --denylist rm $PKG 2>/dev/null
  magisk --sulist add $PKG 2>/dev/null
done
if magisk magiskhide sulist; then
  for PKG in $PKGS; do
    magisk magiskhide add $PKG
  done
else
  for PKG in $PKGS; do
    magisk magiskhide rm $PKG
  done
fi

# dependency
#rm -f /data/adb/modules/MiuiCore/remove
#rm -f /data/adb/modules/MiuiCore/disable

# patch plat_seapp_contexts
FILE=/system/etc/selinux/plat_seapp_contexts
rm -f $MODPATH$FILE
if ! grep 'user=system seinfo=default domain=system_app type=system_app_data_file' $FILE; then
  cp -af $FILE $MODPATH$FILE
  sed -i '1i\
user=system seinfo=default domain=system_app type=system_app_data_file' $MODPATH$FILE
fi

# function
copy_dir_file() {
  mkdir -p `dirname "$2"`
  cp -af "$1" "$2"
}

# patch media profiles
AUD=*media*profiles*.xml
rm -f `find $MODPATH -type f -name $AUD`
FILES=`find /system /odm /my_product -type f -name $AUD`
for FILE in $FILES; do
  MODFILE=$MODPATH/system`echo "$FILE" | sed 's|/system||g'`
  copy_dir_file $FILE $MODFILE
done
FILES=`find /vendor -type f -name $AUD`
for FILE in $FILES; do
  if [ -L $MODPATH/system/vendor ]\
  && [ -d $MODPATH/vendor ]; then
    MODFILE=$MODPATH$FILE
  else
    MODFILE=$MODPATH/system$FILE
  fi
  copy_dir_file $FILE $MODFILE
done
FILE=`find $MODPATH -type f -name $AUD`
if [ "$FILE" ]; then
  sed -i 's|maxFrameRate="30"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="48"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="60"|maxFrameRate="90"|g' $FILE
fi

# permission
if [ "$API" -ge 26 ]; then
  DIRS=`find $MODPATH/vendor\
             $MODPATH/system/vendor -type d`
  for DIR in $DIRS; do
    chown 0.2000 $DIR
  done
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/odm/etc
  if [ -L $MODPATH/system/vendor ]\
  && [ -d $MODPATH/vendor ]; then
    chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/etc
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/odm/etc
  else
    chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/odm/etc
  fi
fi

# function
mount_helper() {
if [ -d /odm ]\
&& [ "`realpath /odm/etc`" == /odm/etc ]; then
  DIR=$MODPATH/system/odm
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/odm`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
if [ -d /my_product ]; then
  DIR=$MODPATH/system/my_product
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/my_product`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
}

# mount
if ! grep -E 'delta|Delta|kitsune' /data/adb/magisk/util_functions.sh; then
  mount_helper
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE.txt
fi












