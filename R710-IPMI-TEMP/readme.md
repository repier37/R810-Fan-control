# Safety BASH script
I made a BASH script to check the CPU temperatures. It adjust the fan speed to the CPU temperatures. And if it's higher than XX (75 degrees C in my case). it sends a raw command to restore automatic fan control. 
The fan speed and ramps can be adjusted in the script using the 

You can check acceptable CPU temp by running the following command in a shell:
$: sensors
Wich will give you an output like this
Core 0:       +53.0°C  (high = +83.0°C, crit = +91.0°C)
Core 1:       +53.0°C  (high = +83.0°C, crit = +91.0°C)
Core 2:       +53.0°C  (high = +83.0°C, crit = +91.0°C)
Core 3:       +54.0°C  (high = +83.0°C, crit = +91.0°C)
Core 8:       +54.0°C  (high = +83.0°C, crit = +91.0°C)
Core 9:       +53.0°C  (high = +83.0°C, crit = +91.0°C)
Core 10:      +51.0°C  (high = +83.0°C, crit = +91.0°C)
Core 11:      +50.0°C  (high = +83.0°C, crit = +91.0°C)

Before runing this script you might need to edit the following variables:
- MAXTEMP : Check your CPU acceptable temperatures and adjust accordingly, I set mine to the high value minus 8 degrees
- TEMP0 and TEMP8 : These variables get the core 0 and core 8 temperature check your CPU Cores numbers and replace their names in the script (TEMP0 and TEMP8 variables);
- Check your IDRAC credentials and IP

I'm running this on an Ubuntu (on the R810), but it should be able to run as long as you have ipmitools. It could be you need to modify the logging, to make it work with whatever your system use.

I run the script via CRON every minute from my Ubuntu Server

`*/1 * * * * /bin/bash /path/to/script/R810-IPMITemp.sh > /dev/null 2>&1`

I'm also currently testing out [slacktee.sh](https://github.com/course-hero/slacktee) to get notifications in my slack channel.

The Scripts [Reddit thread](https://www.reddit.com/r/homelab/comments/779cha/manual_fan_control_on_r610r710_including_script/)

*****

*ADDED 2019-12-20:*
If you want a more advanced Perl script with more functionality, check out [@spacelama's fork](https://github.com/spacelama/Scripts).

*****

# Howto: Setting the fan speed of the Dell R610/R710/R810

1. Enable IPMI in iDrac
2. Install ipmitool on linux, win or mac os
3. Run the following command to issue IPMI commands: 
`ipmitool -I lanplus -H <iDracip> -U root -P <rootpw> <command>`


**Enable manual/static fan speed:**

`raw 0x30 0x30 0x01 0x00`


**Set fan speed:**

(Use i.e http://www.hexadecimaldictionary.com/hexadecimal/0x14/ to calculate speed from decimal to hex)

*3000 RPM*: `raw 0x30 0x30 0x02 0xff 0x10`

*2160 RPM*: `raw 0x30 0x30 0x02 0xff 0x0a`

*1560 RPM*: `raw 0x30 0x30 0x02 0xff 0x09`

The last value correspond to the desired fans speed percent in hexa (100% = 0x64)

_Note: The RPM may differ from model to model_

**Disable / Return to automatic fan control:**

`raw 0x30 0x30 0x01 0x01`


**Other: List all output from IPMI**

`sdr elist all`


**Example of a command:**

`ipmitool -I lanplus -H 192.168.0.120 -U root -P calvin  raw 0x30 0x30 0x02 0xff 0x10`


*****

**Disclaimer**

I'm by no means good at IPMI, BASH scripting or regex, etc. but it seems to work fine for me. 

TLDR; I take _NO_ responsibility if you mess up anything.

*****

All of this was inspired by [this Reddit post](https://www.reddit.com/r/homelab/comments/72qust/r510_noise/dnkofsv/) by /u/whitekidney 
