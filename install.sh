#!/bin/bash

CHRONY_CONF=/etc/chrony/chrony.conf
CHRONY_CONF_URL=https://raw.githubusercontent.com/KonopnickiejCom/RasbperryPI-GPS-Chrony/main/config/etc/chrony/chrony.conf
BOOT_CONF=/boot/config.txt
BOOT_CMDLINE=/boot/cmdline.txt
GPSD_CONF=/etc/default/gpsd
GPSD_CONF_URL=https://raw.githubusercontent.com/KonopnickiejCom/RasbperryPI-GPS-Chrony/main/config/etc/default/gpsd

if [ "$UID" -eq 0 ]; then
    echo "This script is being run by the root user."
else
    echo "This script is not being run by the root user."
    echo "sudo ./install.sh"
    exit 0
fi

apt update 
apt upgrade -y
apt install chrony gpsd pps-tools -y

echo "RPi BOOT Config modification $BOOT_CONF"
echo "" >> $BOOT_CONF
echo "# (c) Outosurcing IT - Konopnickiej.Com - https://konopnickiej.com" >> $BOOT_CONF
echo "# (c) FlameIT - Immersion Cooling - https://flameit.io" >> $BOOT_CONF
echo "# Author: Paweł 'felixd' Wojciechowski" >> $BOOT_CONF
echo "# Based on Dragino GPS/Lora HAT https://wiki1.dragino.com/index.php/Getting_GPS_to_work_on_Raspberry_Pi_3_Model_B" >> $BOOT_CONF
echo "# GPS synchronized CLOCK -  PPS signals" >> $BOOT_CONF
echo "" >> $BOOT_CONFs
echo "core_freq=250" >> $BOOT_CONF
echo "enable_uart=1" >> $BOOT_CONF
echo "force_turbo=1" >> $BOOT_CONF
echo "dtoverlay=pps-gpio,gpiopin=26" >> $BOOT_CONF
echo "dtoverlay=pi3-disable-bt-overlay" >> $BOOT_CONF
echo "dtparam=spi=on" >> $BOOT_CONF
echo "" >> $BOOT_CONF

echo "Done updating $BOOT_CONF"

echo "Disabling Bluetooth HCI UART and Serial Console services"
systemctl disable hciuart
systemctl disable serial-getty@ttyS0.service

echo "Removing console from serial0 in $BOOT_CMDLINE"
sed -i 's/console=serial0,115200 //g' $BOOT_CMDLINE

echo "Updating Chrony configuration"
wget -O $CHRONY_CONF $CHRONY_CONF_URL
chmod 644 $CHRONY_CONF

echo "Updating GPSD configuration"
wget -O $GPSD_CONF $GPSD_CONF_URL
chmod 644 $GPSD_CONF

echo "Restarting GPSD service"
service gpsd restart

echo "Restarting Chrony service"
service chrony restart

echo "Reboot RaspberryPi"
