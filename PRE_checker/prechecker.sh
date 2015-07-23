#!/bin/bash
#filename prechecker.sh
#

##################### ARGS #####################
source $(dirname $0)/prechecker.conf 
EXIT_CODE=0
################### END ARGS ###################


##################### FUNCS ####################
#функция отображения DEBUG сообщений
debug_mess()
{
	LOG_LEVEL=$1
	MES=$2

	# Если логирование подкулючено, то будет писаться лог
	test $MONPRJPATH && $MONPRJPATH/base/log_maker.sh 0 $LOG_LEVEL mail_sender.sh $SEND_DATE "$MES"

	if [ $DEBUG_FLAG -eq 1 ] ; then
		echo "`date '+%Y-%m-%d_%H:%M:%S'` [$LOG_LEVEL]: $2"
	fi
}
#Завершение скрипта
error_exit()
{
	if [ $DEBUG_FLAG -eq 2 ] ; then  set +x ; fi
	if [ -n "$GLOBAL_CONFIG_LOADED" ] ; then
		debug_mess INFO "EXIT CODE is $EXIT_CODE"
		debug_mess INFO "EXITING."
	exit $EXIT_CODE
}

hostValidator() {
	attempts=0

	$SCRIPT_PATH/hostname_parser.sh 
	if [ $? -ne 0 ]; then debug_mess ERROR "hostname_parser FAILED"; EXIT_CODE=11 ; error_exit; fi

	hostname_checker
	if [ "$need_key" = "FAIL" ] 
	then 
		debug_mess ERROR "hostname not known. Check hostname_parser.sh"
		EXIT_CODE=12 
		error_exit
	fi

	#Вывод предупреждения(цветного)
	printf "${COLORED}WARNING:${NC} Incautious using of this option may be harmfull for the system.
	To proceed the job you should type hostname (`echo $need_key |  tr '[a-z]' '[A-Z]'| tr ' ' '-'`) without dashes, using spaces instead\n\n"
	while :
	do
		echo -n "put a hostname: "
		read ans;
		ans=`echo $ans | tr '[A-Z]' '[a-z]'`;
		if [ "$ans" = "$need_key" ]
		then
		        echo key is matching; break
		else
		        echo key invalid; let attempts++;
		        if [ $attempts -eq 3 ]; then 
		        	debug_mess ERROR "No attempts left"
		        	EXIT_CODE=10; error_exit 
		        fi
		fi
	done
}
################### END FUNCS ##################



##################### MAIN #####################
if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi

#Проверка аргумента
ARG_1=`basename $1`
ARG_2=$2

case $ARG_1 in
    SASServer1.sh | SASServer2.sh | SASServer6.sh | SASServer11.sh | sas.servers)
        case $ARG_2 in
            start | stop | restart | test)
            	debug_mess "Trying to execute $ARG_1 $ARG_2"
                hostValidator;;
        esac;;
esac
exit $EXIT_CODE
