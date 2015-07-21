#!/bin/bash
#filename hostname_parser.sh
#Ver 1.1 2015-06-26_13:15

#Script is depends of client. 
#Client - BOM

hostname_checker()
{
	case `hostname` in
		e8b-mag-sasmm) need_key="prod comp";;
		e8b-mag-sascomp) need_key="prod meta";;
		e8b-mag-sasmmdev) need_key="dev meta";;
		e8b-mag-sascompdev) need_key="dev comp";;
		e8b-zhuk-sasmmtst) need_key="test meta";;
		e8b-zhuk-sascomptst) need_key="test comp";;
		*) need_key="FAIL";;
	esac
}
