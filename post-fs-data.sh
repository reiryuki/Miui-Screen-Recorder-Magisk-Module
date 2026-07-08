mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# function
set_perm() {
  chown $2:$3 $1 || return 1
  chmod $4 $1 || return 1
  local CON=$5
  [ -z $CON ] && CON=u:object_r:system_file:s0
  chcon $CON $1 || return 1
}
set_perm_recursive() {
  find $1 -type d 2>/dev/null | while read dir; do
    set_perm $dir $2 $3 $4 $6
  done
  find $1 -type f -o -type l 2>/dev/null | while read file; do
    set_perm $file $2 $3 $5 $6
  done
}

# permission
set_perm_recursive $MODPATH 0 0 0755 0644

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
MOD=/data/adb/modules/nomount
NM=$MOD/bin/nm
NOMOUNT=false
[ ! -f $MOD/disable ] && [ -x $NM ] && $NM v >/dev/null 2>&1 && NOMOUNT=true

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
MED=`cat $MODPATH/media.txt`
rm -f `find $MODPATH -type f -name $MED`
FILES=`find /system /odm /my_product -type f -name $MED`
for FILE in $FILES; do
  MODFILE=$MODPATH/system`echo "$FILE" | sed 's|/system||g'`
  copy_dir_file $FILE $MODFILE
done
FILES=`find /vendor -type f -name $MED`
for FILE in $FILES; do
  MODFILE=$MODPATH$MODSYSTEM$FILE
  copy_dir_file $FILE $MODFILE
done
FILES=`find $MODPATH -type f -name $MED`
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
FILES=`find $DIR -type f -name $MED`
for FILE in $FILES; do
  DES=/odm`echo $FILE | sed "s|$DIR||g"`
  RDES=`realpath $DES`
  if [ -f $RDES ]; then
    if $NOMOUNT; then
      $NM del $RDES 2>/dev/null || true
      $NM add $RDES $FILE
    else
      umount $RDES
      mount -o bind $FILE $RDES
    fi
  fi
done
}
mount_my_product() {
DIR=$MODPATH/system/my_product
FILES=`find $DIR -type f -name $MED`
for FILE in $FILES; do
  DES=/my_product`echo $FILE | sed "s|$DIR||g"`
  RDES=`realpath $DES`
  if [ -f $RDES ]; then
    if $NOMOUNT; then
      $NM del $RDES 2>/dev/null || true
      $NM add $RDES $FILE
    else
      umount $RDES
      mount -o bind $FILE $RDES
    fi
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












