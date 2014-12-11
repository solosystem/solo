#!/bin/bash

echo 
echo 
echo "*** This is test-RTC - tests the operation, and sets the RTC"
echo
echo "Current system time is :"


echo "Looking for RTC... ( checking /dev/rtc0)"

if [ ! -c /dev/rtc0 ] ; then
    echo "No such file - /dev/rtc0"
    echo "exiting..."
    exit -1
fi

sysdate=`date`
rtcdate=`/sbin/hwclock --show`
netdate=`rdate -p time.nist.gov`

echo "sysdate: $sysdate"
echo "rtcdate: $rtcdate"
echo "netdate: $netdate"

echo "Run with net2sys or sys2rtc (or both) if desired"

if [ $1 == "net2sys" ] ; then
    echo "setting system time from net ..."
    rdate time.nist.gov
    echo "Done - time is now `date`"
    shift
fi

if [ $1 == "sys2rtc" ] ; then
    echo "setting rtc from system time ..."
    hwclock --systohc
    echo "Done."
    shift
fi

echo
echo "times just before we exit:"    
sysdate=`date`
rtcdate=`/sbin/hwclock --show`
netdate=`rdate -p time.nist.gov`

echo "sysdate: $sysdate"
echo "rtcdate: $rtcdate"
echo "netdate: $netdate"

echo "done"
echo

exit 0
