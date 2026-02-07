mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`
if [ -L $MODPATH/system/vendor ]; then
  mkdir -p $MODPATH/vendor
fi
if [ ! -d $MODPATH/vendor ]\
|| [ -L $MODPATH/vendor ]; then
  MODSYSTEM=/system
fi

# function
permissive() {
if [ "`toybox cat $FILE`" = 1 ]; then
  chmod 640 $FILE
  chmod 440 $FILE2
  echo 0 > $FILE
fi
}
magisk_permissive() {
if [ "`toybox cat $FILE`" = 1 ]; then
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
FILE=/sys/fs/selinux/enforce
FILE2=/sys/fs/selinux/policy
#1permissive
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#2magisk_permissive
FILE=$MODPATH/sepolicy.rule
#ksepolicy_sh
FILE=$MODPATH/sepolicy.pfsd
sepolicy_sh

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
  MODFILE=$MODPATH$MODSYSTEM$FILE
  copy_dir_file $FILE $MODFILE
done
FILES=`find $MODPATH -type f -name $AUD`
for FILE in $FILES; do
  sed -i 's|maxFrameRate="15"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="20"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="24"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="25"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="27"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="30"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="31"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="40"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="48"|maxFrameRate="90"|g' $FILE
  sed -i 's|maxFrameRate="60"|maxFrameRate="90"|g' $FILE
done

# permission
if [ "$API" -ge 26 ]; then
  DIRS=`find $MODPATH/vendor\
             $MODPATH/system/vendor -type d`
  for DIR in $DIRS; do
    chown 0.2000 $DIR
  done
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/odm/etc
  chcon -R u:object_r:vendor_file:s0 $MODPATH$MODSYSTEM/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH$MODSYSTEM/vendor/etc
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH$MODSYSTEM/vendor/odm/etc
fi

# function
mount_odm() {
DIR=$MODPATH/system/odm
FILES=`find $DIR -type f -name $AUD`
for FILE in $FILES; do
  DES=/odm`echo $FILE | sed "s|$DIR||g"`
  if [ -f $DES ]; then
    umount $DES
    mount -o bind $FILE $DES
  fi
done
}
mount_my_product() {
DIR=$MODPATH/system/my_product
FILES=`find $DIR -type f -name $AUD`
for FILE in $FILES; do
  DES=/my_product`echo $FILE | sed "s|$DIR||g"`
  if [ -f $DES ]; then
    umount $DES
    mount -o bind $FILE $DES
  fi
done
}

# mount
if [ -d /odm ] && [ "`realpath /odm/etc`" == /odm/etc ]\
&& ! grep /odm /data/adb/magisk/magisk\
&& ! grep /odm /data/adb/magisk/magisk64\
&& ! grep /odm /data/adb/magisk/magisk32; then
  mount_odm
fi
if [ -d /my_product ]\
&& ! grep /my_product /data/adb/magisk/magisk\
&& ! grep /my_product /data/adb/magisk/magisk64\
&& ! grep /my_product /data/adb/magisk/magisk32; then
  mount_my_product
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE.txt
fi












