(

mount /data
mount -o rw,remount /data
MODPATH=${0%/*}

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  sh $FILE
fi

# dependency
#rm -f /data/adb/modules/MiuiCore/remove
#rm -f /data/adb/modules/MiuiCore/disable

# etc
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi
ETC=$MAGISKTMP/mirror/system/etc
VETC=$MAGISKTMP/mirror/system/vendor/etc
VOETC=$MAGISKTMP/mirror/system/vendor/odm/etc
MODETC=$MODPATH/system/etc
MODVETC=$MODPATH/system/vendor/etc
MODVOETC=$MODPATH/system/vendor/odm/etc

# media profiles
NAME=*media*profiles*.xml
rm -f `find $MODPATH/system -type f -name $NAME`
MP=`find $ETC -maxdepth 1 -type f -name $NAME`
VMP=`find $VETC -maxdepth 1 -type f -name $NAME`
VOMP=`find $VOETC -maxdepth 1 -type f -name $NAME`
if [ "$MP ]; then
  cp -f $MP $MODETC
fi
if [ "$VMP ]; then
  cp -f $VMP $MODVETC
fi
if [ "$VOMP ]; then
 cp -f $VOMP $MODVOETC
fi

# patch media profiles
MODMP=`find $MODPATH/system -type f -name $NAME`
if [ "$MODMP" ]; then
  sed -i 's/maxFrameRate="30"/maxFrameRate="90"/g' $MODMP
  sed -i 's/maxFrameRate="48"/maxFrameRate="90"/g' $MODMP
  sed -i 's/maxFrameRate="60"/maxFrameRate="90"/g' $MODMP
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  sh $FILE
  rm -f $FILE
fi

) 2>/dev/null







