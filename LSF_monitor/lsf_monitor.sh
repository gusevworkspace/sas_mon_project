#!/bin/bash
# скрипт проверки работоспособности LSF

##################### ARGS #####################
source /sas/sas/env/scripts/monitoring/mon_project/base/monitoring_cfg.conf
SEND_TO='dmitry.gusev@glowbyteconsulting.com'

# Время запуска скрипта
CUR_DATE=`date '+%Y-%m-%d_%H:%M:%S'`

#Флаг для включения функции логирования DEBUG_FLAG
# 0 - штатная работа. INFO информация не отображается
# 1 - отображение INFO сообщений в консоле
# 2 - set -x
DEBUG_FLAG=1

# Код завершения
EXIT_CODE=0
################### END ARGS ###################


##################### FUNCS ####################
##Логирование и обработка ошибок
debug_mess()
{
	LOG_LEVEL=$1
	MES=$2
	
	$MONPRJPATH/base/log_maker.sh 0 $LOG_LEVEL lsf_monitor.sh $CUR_DATE "$MES" 
	
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

################### END FUNCS ##################


##################### MAIN #####################
if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi

debug_mess INFO "starting lsf_check"

#В случае, если файл обновлялся не позже, чем 15 минут назад, то в переменную положится имя файла
IS_OK=`find /sas/temp/work/monitoring/lsf_monitor.txt -mmin -15`
debug_mess DEBUG  "IS_OK has $IS_OK"

#Если переменная пуста - отработает if
if [ -z $IS_OK ]
then
     debug_mess ERROR  "LSF ERROR. Sending message to $SEND_TO"
     bash $MONPRJPATH/base/mail_sender.sh "[DEV] BOM MA ADMIN SAS SCHEDULING IS DOWN" "Campaign was not executing." "$SEND_TO"
	 EXIT_CODE=1
	 error_exit
fi
#Завершение программы
error_exit
################### END MAIN ###################