# helper functions for solo-boot.sh

function header() {
    echo ""
    echo "============================================="
    echo "=== Started:  $1 [at $(date)]"
}

function footer() {
    echo "=== Finised:  $1 [at $(date)]"
    echo "============================================="
    echo ""
}

function logit() {
    echo "... $* [at $(date)]"
}

function minimize_power() {
    header "Minimizing power usage"
    echo "... disabling tvservice to save power [/opt/vc/bin/tvservice off]"
    /opt/vc/bin/tvservice -off
    footer "Minimizing power usage"
}

function add_user() {
    header "Adding users"
    echo "... adding user amon..."
    useradd -m amon
    echo "... setting password"
    echo "amon:amon" | chpasswd
    echo "... adding amon to groups"
    usermod -a -G adm,dialout,cdrom,kmem,sudo,audio,video,plugdev,games,users,netdev,input,gpio amon
    echo "... enabling password-less sudo"
    echo "amon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    footer "Adding users"
}


function _really_set_timezone() {
    echo "... setting /etc/timezone to new tz: $1... "
    echo $1 > /etc/timezone
    echo "... and updating system via dpdk-reconfigure tzdata..."
    dpkg-reconfigure -f noninteractive tzdata
    echo "... done."
}

function set_timezone() {
    header "Setting the timezone"
    SYS_TZ=$(cat /etc/timezone)
    echo "... current /etc/timezone is set to $SYS_TZ"
    if [ -n "$SOLO_TZ" ] ; then
	echo "... SOLO_TZ is set to $SOLO_TZ (in solo.conf)"
	if [ "$SOLO_TZ" != "SYS_TZ" ] ; then
	    _really_set_timezone $SOLO_TZ
	else
	    echo "... system timezone already matches SOLO_TZ, so doing nothing"
	fi
    else
	echo "... SOLO_TZ not set in solo.conf so setting timezone to Europe/London..."
	_really_set_timezone "Europe/London"
    fi
    footer "Setting the timezone"
}


function setup_leds() {
    header "Setting up the leds"
    if [ $RPINAME = "B+" -o $RPINAME = "A+" -o $RPINAME = "PI2B" ] ; then
	echo "... activating LEDs - led0[green] = heartbeat, led1[red] off"
	echo heartbeat > /sys/class/leds/led0/trigger # heartbeat on green LED
	echo none      > /sys/class/leds/led1/trigger # turn off the red LED
    else
	echo "... don't know how to set LEDs on this hardware: $RPINAME"
	ls -l /sys/class/leds/
	echo "... please update github.com/solosystem/solo/utils.sh"
    fi
    footer "Setting up the leds"
}

function setup_rtc() {
    header "Setting up the RTC clock"
    # we got rid of fake-hwclock, so now enable hwclock at boot time:
    echo "... enabling early boot support for RTC..."
    echo "... copying over our version of hwclock.sh (with call to setup_rtc.sh)"
    cp -v /opt/solo/hwclock.sh /etc/init.d/hwclock.sh
    echo "... now running update-rc.d to enable good old hwclock.sh"
    update-rc.d hwclock.sh enable
    footer "Setting up the RTC clock"
}

function enable_i2c() {
    header "Enabling i2c in kernel"
    echo "... adding dtparm=i2c_arm=on to /boot/config.txt"
    printf "dtparam=i2c_arm=on\n" >> /boot/config.txt
    footer "Enabling i2c in kernel"
}