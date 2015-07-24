#!/bin/bash
#Скрипт парсера, который ходит в логи макора и отбирает избранный материал. Раз в период
#
## Список и порядок аргументов
# 1 - 
# 2 - 
# 3 - 
# 4 - 
# 5 - 
# периодичность хождения
# рассылка кому
# логирование
# файл фильтров
#

##################### ARGS #####################
source $(dirname $0)/SASCIC_parser.conf

STR_COUNT_OLD=0
SRT_COUNT_NEW=$STR_COUNT_OLD
MODULE=0
CUR_DATE=`date '+%Y-%m-%d_%H:%M:%S'`

EXIT_CODE=0
################### END ARGS ###################


##################### FUNCS ####################
##Логирование и обработка ошибок
debug_mess()
{
	LOG_LEVEL=$1
	MES=$2
	
	$MONPRJPATH/base/log_maker.sh 0 $LOG_LEVEL SASCIC_parser.sh $CUR_DATE "$MES"
	
    if [ $DEBUG_FLAG -eq 1 ]
    then
        echo "`date '+%Y-%m-%d_%H:%M:%S'` [$LOG_LEVEL]: $2"
    fi
}

#Завершение скрипта
error_exit()
{
	if [ $DEBUG_FLAG -eq 2 ] ; then  set +x ; fi
	debug_mess INFO "EXIT CODE is $EXIT_CODE"
	debug_mess INFO "EXITING."
	exit $EXIT_CODE
}
#1 - узнать старое количество строк
define_old_count()
{
	debug_mess INFO "Defining old count"
	STR_COUNT_OLD=`cat $PATH_TO_COUNT`
}

#2 - Лочим файл. Для этого копируем его локально
lock_log_file()
{
	debug_mess INFO "Locking log file localy"
	ssh sas@$METASERVER "cp $PATH_TO_LOG /tmp/$TEMP_FILE_NAME"
	if [ $? -ne 0 ] ; then EXIT_CODE=110; debug_mess ERROR "Error executing SSH. ERROR $EXIT_CODE"; error_exit; fi
}

#3 - узнать количество строк в логе (str_count_new)
define_new_count()
{
	debug_mess INFO "Defining new count"
	SRT_COUNT_NEW=`ssh sas@$METASERVER "wc -l /tmp/$TEMP_FILE_NAME" | awk '{print $1}'`
	if [ $? -ne 0 ] ; then EXIT_CODE=110; debug_mess ERROR "Error executing SSH. ERROR $EXIT_CODE"; error_exit; fi
	
	debug_mess DEBUG "SRT_COUNT_NEW = $SRT_COUNT_NEW"
	
	if [ $STR_COUNT_OLD -gt $SRT_COUNT_NEW ]
	then 
		debug_mess INFO "It is seems like log file is smaller then previously. Resetting counters."
		STR_COUNT_OLD=0
	fi
}

#4 - вытащить новые строки (tail -n +old_count file)
get_new_strings()
{
	debug_mess INFO "Getting new strings"
	ssh sas@$METASERVER "tail -n +$STR_COUNT_OLD  /tmp/$TEMP_FILE_NAME" | grep ERROR > $PATH_TO_TEMP
}


#5 - обновить str_count_new (str_count_old=str_count_new)
update_count()
{
	debug_mess INFO "Updating counts"
	echo $SRT_COUNT_NEW > $PATH_TO_COUNT
}

#6 - протащить через фильтры
parser()
{
	debug_mess INFO "Parsing"
	#sed -i "/Pattern1/d" $PATH_TO_TEMP 
	#sed -i "/Pattern2/d" $PATH_TO_TEMP
}

#7.0 - Отправить письмо по адресату
send_mail()
{
	U_MAIL=$1
	U_FILTER=$2
	debug_mess INFO "using filter: $U_FILTER"
	grep $U_FILTER $PATH_TO_TEMP > $PATH_TO_TEMP.$U_MAIL.mail.txt
	case $? in
		0)
			debug_mess INFO "Sending mail to $U_MAIL"
			$MONPRJPATH/base/mail_sender.sh "Parsed sasserv6 error log" "Here is parsed log from SASCustIntelCore" "$U_MAIL" $PATH_TO_TEMP.$U_MAIL.mail.txt;;
		1)
			debug_mess INFO "There is no new errors in log"
			;;
		*)
			EXIT_CODE=107; debug_mess ERROR "Can't send mail to $U_MAIL. ERROR $EXIT_CODE"; error_exit;;
	esac
}

#7 - фильтровать MAIL_LIST
filter_to_mail_list()
{
	debug_mess INFO "filtering log for mail list"
	cat $MAIL_LIST 2> /dev/null | while read line
	do
		send_mail $line
	done
	#$MONPRJPATH/mail_sender.sh "Parsed sasserv6 error log" "Here is parsed log from SASCustIntelCore" "$MAIL_LIST" "$PATH_TO_TEMP"
}

#optional_1 удаление временных файлов
remove_temp()
{
	debug_mess INFO "Deleting /tmp/$TEMP_FILE_NAME"
	ssh sas@$METASERVER 'rm -f /tmp/$TEMP_FILE_NAME'
	
	debug_mess INFO "Deleting $PATH_TO_TEMP"
	rm -f $PATH_TO_TEMP
}


################### END FUNCS ##################


##################### MAIN #####################
if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi

debug_mess INFO "Begin parser script"

#1 - узнать старое количество строк
define_old_count
if [ $? -ne 0 ] ; then 	EXIT_CODE=101 ; debug_mess ERROR "Can't define old count. ERROR $EXIT_CODE"; error_exit; 
	else debug_mess INFO "STR_COUNT_OLD = $STR_COUNT_OLD"; fi

#2 - Лочим файл. Для этого копируем его локально
lock_log_file
if [ $? -ne 0 ] ; then EXIT_CODE=102; debug_mess ERROR "Can't lock file. ERROR $EXIT_CODE"; error_exit; fi


#3 - узнать количество строк в логе (str_count_new)
define_new_count
if [ $? -ne 0 ] ; then EXIT_CODE=104; debug_mess ERROR "Can't define new count. ERROR $EXIT_CODE"; error_exit; 
	else debug_mess INFO "SRT_COUNT_NEW = $SRT_COUNT_NEW"; fi
	
#4 - вытащить новые строки (tail -n +old_count file)
get_new_strings
case $? in
	0)
		;;
	1)
		debug_mess INFO "There is no new errors in log"
		error_exit;;
	*)
		EXIT_CODE=103; debug_mess ERROR "Can't define module. ERROR $EXIT_CODE"; error_exit;;
esac

#5 - обновить str_count_new (str_count_old=str_count_new)
update_count
if [ $? -ne 0 ] ; then EXIT_CODE=105; debug_mess ERROR "Can't update count. ERROR $EXIT_CODE"; error_exit; fi

#6 - протащить через фильтры
parser
if [ $? -ne 0 ] ; then EXIT_CODE=106; debug_mess ERROR "Can't parse the log. ERROR $EXIT_CODE"; error_exit; fi

#7 - фильтровать MAIL_LIST
filter_to_mail_list
if [ $? -ne 0 ] ; then EXIT_CODE=107; debug_mess ERROR "Can't send mail. ERROR $EXIT_CODE"; error_exit; fi

if [ $DEBUG_FLAG -eq 2 ] ; then  set +x ; fi

error_exit
################### END MAIN ###################