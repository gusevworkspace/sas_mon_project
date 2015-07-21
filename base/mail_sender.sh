#!/bin/bash
#Скрипт отправки сервисных сообщений
#
## Список и порядок аргументов
# 1 - Заголовок письма
# 2 - Тело письма
# 3 - Список адресов для рассылки
# 4 - путь кприкрепленному файлу

##################### ARGS #####################
source ./mail_sender.conf || echo "CONFIG NOT FOUND !" || exit 1

MES_SUBJECT=$1
MES_TEXT=$2
MAIL_TO=''
ATTACHED_FILE=$4

#Код завершения скрипта
EXIT_CODE=0

################### END ARGS ###################


##################### FUNCS ####################
#функция отображения DEBUG сообщений
debug_mess()
{
	LOG_LEVEL=$1
	MES=$2
	
	$MONPRJPATH/base/log_maker.sh 0 $LOG_LEVEL mail_sender.sh $SEND_DATE "$MES" 
	
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

# формирование списка для рассылки, в зависимости от инструмента рассылки
maillist_compiler()
{
case $SEND_TYPE in 
	MX)
		debug_mess INFO "send type is MX"
		MAIL_TO=$1
		shift
		while [ $# -gt 0 ]
		do
			debug_mess DEBUG "sending to various mails"
			MAIL_TO="$MAIL_TO,$1"
			shift
		done
		;;
	
	SM)
		debug_mess INFO "send type is SM"
		if [ $# -eq 1 ]; 
		then 
			MAIL_TO="'$1'"
		else
			
			MAIL_TO="('$1'"
			shift
			while [ $# -gt 0 ]
			do
				MAIL_TO="$MAIL_TO '$1'"
				shift
			done
			MAIL_TO="$MAIL_TO)"
		fi
		;;
	*)
		;;
esac
}


# функция отправки писем средствами *nix
send_via_mailx()
{
	if [ $ATTACHED_FILE ]
	then
		debug_mess INFO "Sending mail with attachment"
		echo "$MES_TEXT" | /usr/bin/mutt -x -s "$MES_SUBJECT" -a $ATTACHED_FILE "$MAIL_TO"
	else
		debug_mess INFO "Sending mail without attachment"
		echo "$MES_TEXT" | /bin/mailx sas@$HOSTNAME -s "$MES_SUBJECT" "$MAIL_TO"
	fi
	
	if [ $? -eq 0]
	then
		debug_mess INFO "MAILED SUCCESSFUL"
		debug_mess INFO "mail with subject ($MES_SUBJECT) was sent to ($MAIL_TO)"
	else
		debug_mess ERROR "MAILED UNSUCCESSFUL"
		debug_mess ERROR "mail with subject ($MES_SUBJECT) was NOT sent to ($MAIL_TO). CHECK MAILX CONFIGURATION!"
		EXIT_CODE=110
		error_exit
		
	fi
}

# функция отправки писем средствами sas
send_via_sas()
{	
	debug_mess INFO "Sending mail via SAS"
	export smparam1="$MES_SUBJECT"
	export smparam2="$MES_TEXT"
	export smparam3="$MAIL_TO"
	if [ $ATTACHED_FILE ]; then export smparam4="$ATTACHED_FILE"; fi # добавить путь к файлу если имеется
	debug_mess INFO "Sending mail via SAS"
	$MONPRJPATH/base/sas_run.sh send_mail_sas
}

type_chooser()
{
	case $SEND_TYPE in
		"MX")
				debug_mess INFO "SEND_TYPE is MAILX"
				send_via_mailx;;
		"SM")
				debug_mess INFO "SEND_TYPE is SAS MANAGER"
				send_via_sas;;
		*)
				debug_mess INFO "SEND_TYPE is UNKNOWN"
				debug_mess ERROR "mail_sender run failed. CHECK SEND_TYPE CONFIGURATION!"
				EXIT_CODE=111
				error_exit;;
	esac
	
	
}
################### END FUNCS ##################


##################### MAIN #####################
if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi

maillist_compiler $3 #подготовка списка для рассылки

debug_mess DEBUG "MAIL_TO is $MAIL_TO"

type_chooser #посыл письма

debug_mess INFO "mail_sender will exit this status code: $EXIT_CODE"

error_exit
################### END MAIN ###################
