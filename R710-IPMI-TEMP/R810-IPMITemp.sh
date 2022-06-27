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
MAXTEMP=75
# If the temperature is above mid temp, fan will be set to mid speed value
LOWTEMP=40
MAXSPEEDPERC=100
MINSPEEDPERCENT=10

DELTAY=$((MAXSPEEDPERC-MINSPEEDPERCENT))
FANRAMP=$((MAXTEMP-LOWTEMP))
FANRAMP=$((DELTAY/FANRAMP))
FANOFFSET=$((MAXSPEEDPERC-FANRAMP*MAXTEMP))
echo "Fan ramp equation is $FANRAMP * x FANOFFSET"

#Get the two cores temperatures and do an average
TEMP0=$(sensors | grep 'Core 0' | grep -Po '\d{2}' | head -1)
declare -i TEMP0
TEMP8=$(sensors | grep 'Core 8' | grep -Po '\d{2}' | head -1)
declare -i TEMP8
TEMP=$((TEMP0+TEMP8))
TEMP=$((TEMP/2))
echo "Temp0 is $TEMP0 °C and Temp8 is $TEMP8°C. Average is $TEMP"

#Compute desired FANSPEED
FANSPEEDDEC=$((FANRAMP * TEMP + FANOFFSET))
echo "Desired fan speed is $FANSPEED %"

#convert FANSPEED to hexa
FANSPEED=$(printf '%x\n' $FANSPEEDDEC)
echo "Desired fan speed is 0x$FANSPEED"


# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
# Do not edit unless you know what you do.
#TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)

if [[ $TEMP > $MAXTEMP ]];
  then
    printf "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)" | systemd-cat -t R810-IPMI-TEMP
    echo "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)" | /usr/local/bin/slacktee.sh -t "R810-IPMI-TEMP [$(hostname)]"
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01
  else
    #set manual control
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
    printf "Temperature is Ok ($TEMP C). Fan speed set to $FANSPEEDDEC %" | systemd-cat -t R810-IPMI-TEMP
    echo "Temperature is Ok ($TEMP C). Fans speed set to $FANSPEEDDEC %" | /usr/local/bin/slacktee.sh -t "R810-IPMI-TEMP [$(hostname)]"
    #set fan speed to mid speed
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff $FANSPEED

fi
