#!/bin/bash
#
# остановка серверов jboss по номерам
#


# funcs

stop_jb_num()
{
	JBOSS_NUM=$1
	debug_mess INFO "Stopping SASServer$JBOSS_NUM"
	$JBOSS_PATH/bin/SASServer$JBOSS_NUM.sh stop
	if [ $? -ne 0 ]  
	then 
		debug_mess ERROR "Error stopping SASServer$JBOSS_NUM, exit_code = $?"
		error_exit 135
	fi
}

status_jb_num()
{
	JBOSS_NUM=$1
	DIRECTION=$2
	debug_mess DEBUG "Checking SASServer$JBOSS_NUM to $DIRECTION"
	case $DIRECTION in
	stop)
		ARG='\grep Shutdown\ complete';;
	start)
		AGR='\grep Started\ in';;
	*)
		debug_mess ERROR "Error with status_jb_num - bad argument"; 
		error_exit 141;;
	esac
	
	cat $JBOSS_PATH/server/SASServer$JBOSS_NUM/log/server.log | $AGR &> /dev/null
	RETURN_CODE=$?
	if [ $RETURN_CODE -eq 0 ]; then debug_mess INFO "SASServer$JBOSS_NUM succeed with $DIRECTION"; fi
	return $RETURN_CODE
}

prepare_status_mass()
{
	ID_COUNT=`echo $JBOSSERVERS | wc -w`
	for i in $(seq 1 1 $ID_COUNT)
	do
		STATUS_MASS[$i]=1
	done
}

prepare_id_mass()
{
	DIRECTION=$1			
	debug_mess INFO "initialising massive of services id's for $DIRECTION"
	case $DIRECTION in
	stop)
		ARG="r";;
	start)
		AGR='';;
	*)
		debug_mess ERROR "Error with status_jb_num - bad argument"; 
		error_exit 141;;
	esac
	SORT_ID="`echo $JBOSSERVERS | xargs -n1 | sort -g$ARG | xargs`"
	id_mas= ( $SORT_ID )

}

# logic
prepare_id_mass

for i in $SORT_ID
do
	stop_jb_num $i stop
done

sleep 60

check mass= ( 1 1 1)

if ch_11 = 1
	check_st 11
else if ch_6 = 1
	check_st 6
else if ch_1 = 1
	check_st 1
else 
	echo "all done"
