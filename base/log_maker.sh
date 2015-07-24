#!/bin/bash
#Скрипт логирования
#
#должен писать как в файл лога, так и в журнал логов
#
## Список и порядок аргументов
# 1 - Флаг файла. (0 или 1) Определяет, идет ли в лог одна строчка или уже готовый текст
# 2 - Статус сообщения. DEBUG, INFO, ERROR, CRITICAL
# 3 - Имя скрипта мониторинга
# 4 - Время выполнения скрипта
# 5 - Текст сообщения. В зависимости от флага файла, это либо строчка, либо путь к готовому тексту
#
#


##################### ARGS #####################
#Подтягивание конфигов
source $(dirname $0)/log_maker.conf

FILE_FLAG=$1
MES_STATUS=$2
SCRIPT_NAME=$3
FILE_DATE=$4
LOG_TEXT=$5
FILE_NAME=${FILE_DATE}_$(basename $SCRIPT_NAME).log

#Инициализация переменных
FILE_PATH=''
STATUS='UNKNOWN'
EXIT_CODE=0
################### END ARGS ###################


##################### FUNCS ####################
#функция отображения DEBUG сообщений
debug_mess()
{
	if [ $DEBUG_FLAG -eq 1 ] ; then  echo "[DEBUG]: $1" ; fi
}

#Завершение скрипта
error_exit()
{
	if [ $DEBUG_FLAG -eq 2 ] ; then  set +x ; fi
	debug_mess "EXIT CODE is $EXIT_CODE"
	debug_mess "EXITING."
	exit $EXIT_CODE
}

#Определяет, создан ли уже файл лога
get_status()
{
	
    if [ -e $LOGS_PATH/$FILE_NAME ] ; then
        debug_mess "logfile exists"
        STATUS='MODYFIED'
    else
        touch  $LOGS_PATH/$FILE_NAME 
        
        if [ $? -eq 0 ] ; then #Проверка на то, что файлик создался
        	STATUS='CREATED'
        else
        	debug_mess "Failed to touch file"
        	EXIT_CODE=102
        	error_exit
        fi
        
        
    fi
    debug_mess "status is $STATUS"
}


# Добавляет запись в лог
add_string_to_log_file()
{
    STRING=$1
	debug_mess "STRING is $STRING"
    echo `date "+%Y-%m-%d %H:%M:%S"` [$MES_STATUS] "$STRING" >> "$LOGS_PATH/$FILE_NAME"
    debug_mess "added to logfile"
}

# Добавляет запись в журнал
add_to_journal()
{
    echo `date "+%Y-%m-%d %H:%M:%S"` [INFO] file $FILE_NAME was $STATUS >> $JOURNAL_FILE
    debug_mess "added to logjournal"
}

add_list_to_log_file()
{
    while read string
    do
         add_string_to_log_file "$string"
    done < $LOG_TEXT
}

################### END FUNCS ##################


##################### MAIN #####################

if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi

get_status

if [ $FILE_FLAG -eq 0 ] ; then
    add_string_to_log_file "$LOG_TEXT"
elif [ $FILE_FLAG -eq 1 ] && [ -e $FILE_FLAG ] ; then
    add_list_to_log_file
else
    debug_mess "UNKNOWN FLAG !"
    echo `date "+%Y-%m-%d %H:%M:%S"` [ERROR] WRONG FILE_FLAG FROM file $FILE_NAME which is $STATUS >> $JOURNAL_FILE
    EXIT_CODE=101
	error_exit
fi

add_to_journal

if [ $DEBUG_FLAG -eq 2 ] ; then  set +x ; fi
error_exit
################### END MAIN ###################
