#!/bin/bash
# Скрипт для грамотного поднятия/опускания сервисов SAS
#
# Версия 0.1
# 2015-04-15_17:15:52

CURRENT_PATH=`dirname $0`
source $CURRENT_PATH/../base/monitoring_cfg.conf
DEBUG_FLAG=2
SEND_DATE=`date '+%Y-%m-%d_%H:%M:%S'`
##################### FUNCS ####################

#функция отображения DEBUG сообщений 
debug_mess()
{
	LOG_LEVEL=$1
	MES=$2
	
	$MONPRJPATH/base/log_maker.sh 0 $LOG_LEVEL sas_serveses_manager $SEND_DATE "$MES" 
	
    if [ $DEBUG_FLAG -eq 1 ]
    then
        echo "`date '+%Y-%m-%d_%H:%M:%S'` [$LOG_LEVEL]: $2"
    fi
}

#Завершение скрипта 
error_exit()
{
	EXIT_CODE=$1
	if [ $DEBUG_FLAG -eq 2 ] ; then  set +x ; fi
	debug_mess INFO "EXIT CODE is $EXIT_CODE"
	debug_mess INFO "EXITING."
	exit $EXIT_CODE
}

## Чеки
#Check ssh connection() 
check_ssh_connection()
{
	ssh -l sas $HOSTNAME_META echo
	case $? in
		0) 
			debug_mess INFO "Test connection successful"
			;;
		*)
			debug_mess ERROR "Fail to test ssh connection, exit_code = $?"
			error_exit 101
			;;
	esac
}

#Check Config File
check_conf_file()
{
	debug_mess INFO "Checking config file..."
	#Check SASCONF
	if [ -d $SASCONF ] && [ -z "$SASCONF" ]
	then 
		debug_mess ERROR "Fail to locate SASCONF dir - $SASCONF"
		error_exit 102
	fi

	#Check SASHOME
	if [ -d $SASHOME ] && [ -z "$SASHOME" ] 
	then 
		debug_mess ERROR "Fail to locate SASHOME dir - $SASHOME"
		error_exit 103
	fi
	
	#Check HOSTNAME
	if [ -z "$HOSTNAME_COMP" ]
	then 
		debug_mess ERROR "Missed HOSTNAME_COMP"
		error_exit 104
	fi
	
	#Check HOSTNAME_META
	if [ -z "$HOSTNAME_META" ]
	then 
		debug_mess ERROR "Missed HOSTNAME_META"
		error_exit 104
	fi
	
	#Check SCRIPT_DATE
	if [ -z "$SCRIPT_DATE" ]
	then 
		SCRIPT_DATE=`date '+%Y-%m-%d %H:%M:%S'`
	fi
	
	#Выбор скрипта для остановки меты. Зависит от версии SAS
	case $SASVERSION in
		9.3) SAS_SERVERS_CMD=sas.servers;;
		9.4) SAS_SERVERS_CMD=sas.servers.mid;;
		*) 
			debug_mess ERROR "Unknown version of SAS version. Check config file"
			error_exit 105;;
	esac
}

#Ping metaServer
check_ping_meta()
{
	ping -с 1 $HOSTNAME_META &> /dev/null
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Ping to meta-server failed"
		error_exit 101
	fi
}


## Хелпы и Юсаджи 
usage()
{
	echo "script arguments:
	First:
		full
		meta
		comp
		metadata_server
	Second:
		start
		stop
		restart
		status 
	"
	error_exit 1
}


##Check args
#проверка на количество 
check_args_input()
{
	if [ $# -ne 2 ]
	then
		echo "2 arguments needed"
		usage
	fi
}


####Старты
#Полный старт  
start_full() 
{
	debug_mess INFO "Starting SAS..."
	start_metadata_server
	sleep 2
	start_comp
	sleep 2
	start_meta
	debug_mess INFO "SAS started"
	if [ $SASVERSION = '9.3' ]; then start_sasservers; fi
	
}

#Старт мета-сервера 
start_meta() 
{
	debug_mess INFO "Starting meta..."
	ssh_execute $SASCONF/Lev1/${SAS_SERVERS_CMD} start
	
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Fail to start meta, exit_code = $?"
		error_exit 122
	fi
	
	debug_mess INFO "Meta started"
}

#Старт компа 
start_comp() 
{
	debug_mess INFO "Starting comp..."
	$SASCONF/Lev1/sas.servers start
	
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Fail to start comp, exit_code = $?"
		error_exit 121
	fi
	
	debug_mess INFO "Comp started"
}

#Старт метадаты 
start_metadata_server() 
{
	debug_mess INFO "Starting metadata server..."
	ssh_execute $SASCONF/Lev1/SASMeta/MetadataServer/MetadataServer.sh start
	debug_mess INFO "MetadataServer started"
}

#Старт JBOSS SASServerX
start_sasservers()
{
	if [ $SASVERSION != '9.3' ]
	then 
		debug_mess ERROR "Wrong SAS version"
		error_exit 12
	fi
	debug_mess INFO "Starting SASServerX..."
	JbossServices_manager start "$JBOSSERVERS"
}

#### Стопы
#Полный Стоп 
stop_full() 
{
	debug_mess INFO "Stopping SAS..."
	case $SASVERSION in
		9.3)
			stop_sasservers
			sleep 2
			stop_meta
			sleep 2
			stop_comp;;
		9.4)
			stop_meta
			sleep 2
			stop_comp
			sleep 2
			stop_metadata_server;;
		*)
			debug_mess ERROR "Unknown version. Check cjonfig"
			error_exit 1;;
	esac

	debug_mess INFO "SAS stopped"
}

#Стоп мета-сервера 
stop_meta() 
{
	debug_mess INFO "Stopping meta..."
	ssh_execute $SASCONF/Lev1/${SAS_SERVERS_CMD} stop
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Fail to stop meta, exit_code = $?"
		error_exit 132
	fi
	
	debug_mess INFO "Meta stopped"
}

#Стоп компа 
stop_comp() 
{
	debug_mess INFO "Stopping comp..."
	$SASCONF/Lev1/sas.servers stop
	
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Fail to stop comp, exit_code = $?"
		error_exit 131
	fi
	
	debug_mess INFO "Comp stopped"
}

#Стоп метадаты
stop_metadata_server() 
{
	debug_mess INFO "Stopping metadata server..."
	ssh_execute $SASCONF/Lev1/SASMeta/MetadataServer/MetadataServer.sh stop
	debug_mess INFO "MetadataServer stopped"
}

#Стоп JBOSS SASServerX
stop_sasservers()
{
	if [ $SASVERSION != '9.3' ]
	then 
		debug_mess ERROR "Wrong SAS version"
		error_exit 12
	fi
	debug_mess INFO "Stopping SASServerX..."
	JbossServices_manager stop "$(echo $JBOSSERVERS| rev)"
}

#### Рестарты
#Полный рестарт 
restart_full() 
{
	debug_mess INFO "Restarting SAS..."
	stop_full
	start_full
}

#Рестарт мета-сервера 
restart_meta() 
{
	debug_mess INFO "Restarting meta..."
	stop_meta
	start_meta
}

#Рестарт компа 
restart_comp() 
{
	debug_mess INFO "Restarting comp..."
	stop_comp
	start_comp
}

#Рестарт JBOSS SASServerX
restart_sasservers() 
{
	debug_mess INFO "Restarting sasservers..."
	stop_sasservers
	start_sasservers
}


#Рестарт метадаты 
restart_metadata_server() 
{
	debug_mess INFO "Restarting metadata server..."
	stop_metadata_server
	start_metadata_server
}

##Статусы
#Полный статус 
status_full()
{
	status_comp
	status_meta
}

#Статус Компа
status_comp()
{
	debug_mess INFO "Checking comp:"
	$SASCONF/Lev1/sas.servers status
	
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Fail to check meta, exit_code = $?"
		error_exit 141
	fi
}

#Статус мета-сервера
status_meta()
{
	debug_mess INFO "Checking meta:"
	ssh_execute $SASCONF/Lev1/sas.servers status
	
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Fail to check meta, exit_code = $?"
		error_exit 142
	fi
}

#Статус метадаты
status_metadata_server()
{
	debug_mess INFO "Checking metadata server:"
	ssh_execute $SASCONF/Lev1/SASMeta/MetadataServer/MetadataServer.sh status
		
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Fail to check metadata server, exit_code = $?"
		error_exit 143
	fi
}

#Статус JBOSS SASServerX
status_sasservers() 
{
	debug_mess INFO "NOT RESOLVED YET..."
}

####SSH
#Execute remote code 
ssh_execute() 
{
	ssh -l sas $HOSTNAME_META "$@" 2> $MONPRJPATH/SAS_start_stop/last_ssh_error.log
	SSH_EXIT=$?
	if [ $SSH_EXIT -ne 0 ]  
	then 
		debug_mess ERROR "Error executing ssh, exit_code = $SSH_EXIT"
		error_exit 102
	fi
}





################### END FUNCS ##################




##################### MAIN #####################

if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi

#Считываем файл конфигов
source $MONPRJPATH/SAS_start_stop/sas_sm.conf
if [ $? -ne 0 ]  
then 
	debug_mess ERROR "failed to read the source"
	error_exit 1
fi

source $MONPRJPATH/SAS_start_stop/jboss_start_stop.sh


#Проверяем валидность конфиг-файла
check_conf_file


#Cчитываем аргументы
case $1 in
	full|comp|meta|metadata_server|sasservers)
		OBJ=$1;;
	*)
		usage;;
esac

case $2 in 
	start|stop|restart|status)
		DO=$2;;
	status)
		echo "Status function not resolved yet"
		error_exit 2;;
	*)
		usage;;
esac

#Проверяем ssh соединение
#echo $OBJ | grep meta && check_ssh_connection
#Выполняем команду
${DO}_${OBJ}

error_exit 0
################### END MAIN ###################
