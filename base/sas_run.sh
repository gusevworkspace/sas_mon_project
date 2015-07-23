#!/bin/bash
#Скрипт запуска файлов SAS
#
## Список и порядок аргументов
# 1 - Имя SAS файла 
# 2 - 
# 3 - 
# 

##################### ARGS #####################
SCRIPT=$1

#Подгрузка конфига
source $(dirname $0)/log_maker.conf

EXIT_CODE=0
################### END ARGS ###################


##################### FUNCS ####################
##Логирование и обработка ошибок
debug_mess()
{
	LOG_LEVEL=$1
	MES=$2
	
	$MONPRJPATH/base/log_maker.sh 0 $LOG_LEVEL sas_run.sh $RUN_DATE "$MES" 
	
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

run_SAS()
{
	$SASBINPATH/sas -noterminal -nosyntaxcheck -autoexec $AUTOEXECPATH/ma_autoexec.sas -sysin $SCRIPT -nolog -noprint -altlog $LOG_FILE
	SAS_EXIT_CODE=$?
	case $SAS_EXIT_CODE in
		0)
			debug_mess INFO "SAS finished successfuly. See log below"
			$MONPRJPATH/base/log_maker.sh 1 INFO sas_run.sh $RUN_DATE $LOG_FILE
			;;
		*)
			debug_mess ERROR "SAS finished unsuccessfuly (code $SAS_EXIT_CODE). See log below"
			$MONPRJPATH/base/log_maker.sh 1 ERROR sas_run.sh $RUN_DATE $LOG_FILE
			EXIT_CODE=201
			error_exit
			;;
	esac
}
################### END FUNCS ##################


##################### MAIN #####################
if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi
debug_mess DEBUG "LOG_FILE is $LOG_FILE"
run_SAS
debug_mess INFO "sas_run will exit this status code: $EXIT_CODE"

error_exit
################### END MAIN ###################