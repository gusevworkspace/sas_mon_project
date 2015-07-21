#!/bin/bash
#filename prechecker.sh
#Ver 1.1 2015-06-26_13:15

##################### ARGS #####################
ScriptPath=`dirname $0`
YELLOW='\033[1;33m' #Yellow colored text
NC='\033[0m' #Usual text
DEBUG_FLAG=0
EXIT_CODE=0
################### END ARGS ###################


##################### FUNCS ####################
#Завершение скрипта
error_exit()
{
	if [ $DEBUG_FLAG -eq 2 ] ; then  set +x ; fi
	#debug_mess INFO "EXIT CODE is $EXIT_CODE"
	#debug_mess INFO "EXITING."
	exit $EXIT_CODE
}

hostValidator() {
attempts=0

source $ScriptPath/hostname_parser.sh 
if [ $? -ne 0 ]; then echo HostameChecker Failed!; EXIT_CODE=11; error_exit; fi

hostname_checker
if [ "$need_key" = "FAIL" ] 
then 
	echo "hostname not known. Check hostname_parser.sh"
	EXIT_CODE=12 
	error_exit
fi

#Вывод предупреждения(цветного)
printf "${YELLOW}WARNING:${NC} Incautious using of this option may be harmfull for the system.
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
                if [ $attempts -eq 3 ]; then EXIT_CODE=10; error_exit; fi
        fi
done
}
################### END FUNCS ##################



##################### MAIN #####################
if [ $DEBUG_FLAG -eq 2 ] ; then  set -x ; fi

#Проверка аргумента
ARG_1=`echo $1 | awk 'BEGIN { FS="/" } ; {print $NF}'`
ARG_2=$2
#echo 1=$ARG_1 2=$ARG_2
case $ARG_1 in
    SASServer1.sh | SASServer2.sh | SASServer6.sh | SASServer11.sh | sas.servers)
        case $ARG_2 in
            start | stop | restart | test)
                hostValidator;;
        esac;;
esac
exit $EXIT_CODE