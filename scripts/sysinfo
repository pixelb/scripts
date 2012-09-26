#/bin/sh

# simple script to give a summary of system information

# License: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Notes:
#    Unless you run as root, disk info can't be shown
# Changes:
#    V0.1, 16 Nov 2005, Initial release
#    V0.s, 22 Oct 2007, Tweak to ensure cdrom info shown.
#                       Comment out partition info as a bit noisy.


find_sbin_cmd() {
    for base in / /usr/ /usr/local; do
        if [ -e $base/sbin/$1 ]; then
            echo $base/sbin/$1
            exit
        fi
    done
}
FDISK=`which fdisk 2>/dev/null`
LSUSB=`which lsusb 2>/dev/null`
LSPCI=`which lspci 2>/dev/null`
[ -z "$FDISK" ] && FDISK=`find_sbin_cmd fdisk`
[ -z "$LSUSB" ] && LSUSB=`find_sbin_cmd lsusb`
[ -z "$LSPCI" ] && LSPCI=`find_sbin_cmd lspci`

echo "============= Drives ============="
(
sed -n 's/.* \([hs]d[a-f]$\)/\1/p' < /proc/partitions
[ -e /dev/cdrom ] && readlink -f /dev/cdrom | cut -d/ -f3
) |
sort | uniq |
while read disk; do
    echo -n "/dev/$disk: "
    if [ ! -r /dev/$disk ]; then
        echo "permission denied" #could parse /proc for all but
    else
        size=`$FDISK -l /dev/$disk | grep Disk | cut -d' ' -f3-4 | tr -d ,`
        rest=`/sbin/hdparm -i /dev/$disk 2>/dev/null | grep Model`
        rest=`echo $rest` #strip spaces
        echo -n "$rest"
        if [ ! -z "$size" ]; then
            echo ", Size=$size"
        else
            echo
        fi
    fi
done

#if [ `id -u` == "0" ]; then
#echo "========== Partitions =========="
#$FDISK -l 2>/dev/null
#fi

echo "============= CPUs ============="
grep "model name" /proc/cpuinfo #show CPU(s) info

echo "============= MEM ============="
KiB=`grep MemTotal /proc/meminfo | tr -s ' ' | cut -d' ' -f2`
MiB=`expr $KiB / 1024`
#note various mem not accounted for, so round to appropriate size
#on my 384MiB system over 8MiB was unaccounted for
#on my 1024MiB system over 20MiB was unaccounted for so round to next highest power of 2
round=32
echo "`expr \( \( $MiB / $round \) + 1 \) \* $round` MiB"

echo "============= PCI ============="
$LSPCI -tv

echo "============= USB ============="
$LSUSB
