#!/bin/bash -i
exec 2>/dev/null

ls -l /proc > file
cat file | awk {'print $9'} | sort -g > file2

cmdlength=$(expr $COLUMNS - 28)

printf "%5s %-5s %s %s %6s %s\n" "PID" "TTY" "  " "STAT" "TIME" "COMMAND"

while read pidproc
do 

case $pidproc in
    ''|*[!0-9]*) ;;
    *)
    if [[ -e /proc/$pidproc ]]
    then
    nptty=$(ls -l /proc/$pidproc/fd/0 | awk '{print $11}'); if [[ "$nptty" != *"tty"* && "$nptty" != *"pts"* ]]; then nptty="0"; fi
    
    
    pstat=$(cat /proc/$pidproc/status | awk '(NR==3)' | awk '{print $2}')
    
    utime=$(cat /proc/$pidproc/stat | awk {'print $14'})
    stime=$(cat /proc/$pidproc/stat | awk {'print $15'})
        
    proctime=$((($utime + $stime) / 100))
    proctime_minutes=$(($proctime / 60))
    proctime_seconds=$(($proctime % 60))
    if [[ $(($proctime_seconds/10)) == 0 ]]; then proctime_seconds=$(echo 0${proctime_seconds}); fi 
    proctime=$(echo ${proctime_minutes}:${proctime_seconds})

    proc_cmdline=$(cat /proc/$pidproc/cmdline)
    proc_cmdline=$(echo ${proc_cmdline::$cmdlength})
    if [[ $proc_cmdline == "" ]]; then proc_cmdline=$(head -n 1 /proc/$pidproc/status | awk '{print $2}'); proc_cmdline=$(echo [${proc_cmdline}]); fi 
    

    if [[ $nptty != "0" ]]; then printf "%5s %-5s %s %s %9s" $pidproc ${nptty#/*/} "  " $pstat $proctime; echo " "$proc_cmdline; else printf "%5s %-5s %s %s %9s" $pidproc "?" "  " $pstat $proctime; echo " "$proc_cmdline; fi
    
    fi
    ;;
esac
done < file2  
