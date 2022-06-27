# INFO

You have two options :
-R810-IMPI-TEMP:
  - Contains 2 bash scripts: 
    - R810-IPMIStatic.sh => set manual fan mode, and nothing else
    - R810-IPMITemp.sh: will check cpu temperatures, and will setta manual fan speed accordingly, or will disable manual control if temperature too high => MEant to be used in a cronjob

-R810-Perl:
  - Contains a PerlScript and a service to adjust fan speed according to server temps (cpu + ambient), basically a fork of https://github.com/spacelama/R710-Fan-Control but withou hdd temperature monitoring as it was not working on my server.

They are provided "as is", and I take no responsibility if they break something on your end. 
