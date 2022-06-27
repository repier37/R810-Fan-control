#!/bin/bash

# ----------------------------------------------------------------------------------
# Script for checking the temperature reported by the ambient temperature sensor,
# and if deemed too high send the raw IPMI command to enable dynamic fan control.
#
# Requires:
# ipmitool – apt-get install ipmitool
# slacktee.sh – https://github.com/course-hero/slacktee
# ----------------------------------------------------------------------------------


# IPMI SETTINGS:
# Modify to suit your needs.
# DEFAULT IP: 192.168.0.120
IPMIHOST=192.168.0.121
IPMIUSER=root
IPMIPW=calvin
IPMIEK=0000000000000000000000000000000000000000

# TEMPERATURE
# Change this to the temperature in celcius you are comfortable with.
# If the temperature goes above the set degrees it will send raw IPMI command to enable dynamic fan control
MAXTEMP=35
# If the temperature is above mid temp, fan will be set to mid speed value
MIDTEMP=30
MidSpeed="0x30 0x30 0x02 0xff 0x0F"
# the fan speed below will be used if temperature is below MIDTEMP
LowSpeed="0x30 0x30 0x02 0xff 0x09"


# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
# Do not edit unless you know what you do.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type temperature |grep Ambient |grep >


if [[ $TEMP > $MAXTEMP ]];
  then
    printf "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)" | systemd-cat -t R810-IPMI->    echo "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)" | /usr/local/bin/slacktee.sh >    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01
  elif [[ $Temp > $MIDTEMP ]];
   then
    #set manual control
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
    printf "Temperature is above average ($TEMP C)" | systemd-cat -t R810-IPMI-TEMP
    echo "Temperature is above average ($TEMP C)" | /usr/local/bin/slacktee.sh -t "R810-IPMI-TEMP [$(hostname)]"
    #set fan speed to mid speed
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw $MidSpeed
   else
    #set manual control
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
    printf "Temperature is Ok ($TEMP C)" | systemd-cat -t R810-IPMI-TEMP
    echo "Temperature is Ok ($TEMP C)" | /usr/local/bin/slacktee.sh -t "R810-IPMI-TEMP [$(hostname)]"
    #set fan speed to low speed
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw $LowSpeed
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw $LowSpeed

fi










