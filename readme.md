ДЗ по теме "Управление процесами"

Создаем скрипт, реализующий вывод ps ax, используя анализ /proc
Результирующий скрипт - scriptps.sh

Описание скрипта

#!/bin/bash -i

# Отключаем вывод STDERR

exec 2>/dev/null

# Выводим содержимое каталога /proc в файл file

ls -l /proc > file

# Выводим наименование папок каталога /proc с сортировкой по имени в файл file2

cat file | awk {'print $9'} | sort -g > file2

# Определяем переменную $cmdlength, чтобы последний выводимый столбец скрипта был однострочным (как в ps ax столбец command)

cmdlength=$(expr $COLUMNS - 28)

# Выводим заголовок

printf "%5s %-5s %s %s %6s %s\n" "PID" "TTY" "  " "STAT" "TIME" "COMMAND"


# Читаем построчно файл file2 и ведем егоо обработку

while read pidproc
do 

# Если значение строки в file2 число, то обрабатываем ее

case $pidproc in
    ''|*[!0-9]*) ;;
    *)
# Проверяем сушествование процесса, если папка с его идентификатором есть, продолжаем работу
    if [[ -e /proc/$pidproc ]]
    then

# Вычисляем переменную для вывода tty, используемой процессом, если файловый дескриптор не тпопадает под условия, выводим "?"    
    nptty=$(ls -l /proc/$pidproc/fd/0 | awk '{print $11}'); if [[ "$nptty" != *"tty"* && "$nptty" != *"pts"* ]]; then nptty="0"; fi
    
# Выводим статус процесса

    pstat=$(cat /proc/$pidproc/status | awk '(NR==3)' | awk '{print $2}')
    
# Вычисляем процессорное время
    utime=$(cat /proc/$pidproc/stat | awk {'print $14'})
    stime=$(cat /proc/$pidproc/stat | awk {'print $15'})
 
    proctime=$((($utime + $stime) / 100))

# Вычисляем переменные для вывода процессорного времени в минутах и секундах    
    proctime_minutes=$(($proctime / 60))
    proctime_seconds=$(($proctime % 60))
    if [[ $(($proctime_seconds/10)) == 0 ]]; then proctime_seconds=$(echo 0${proctime_seconds}); fi 
    proctime=$(echo ${proctime_minutes}:${proctime_seconds})
    
# Выводим командную строку процесса    

    proc_cmdline=$(cat /proc/$pidproc/cmdline)
    proc_cmdline=$(echo ${proc_cmdline::$cmdlength})
    if [[ $proc_cmdline == "" ]]; then proc_cmdline=$(head -n 1 /proc/$pidproc/status | awk '{print $2}'); proc_cmdline=$(echo [${proc_cmdline}]); fi 
    


# Выводим все переменные для прооцесса

    if [[ $nptty != "0" ]]; then printf "%5s %-5s %s %s %9s" $pidproc ${nptty#/*/} "  " $pstat $proctime; echo " "$proc_cmdline; else printf "%5s %-5s %s %s %9s" $pidproc "?" "  " $pstat $proctime; echo " "$proc_cmdline; fi
    
    fi
    ;;
esac
done < file2  
