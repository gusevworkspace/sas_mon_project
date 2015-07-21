/*Параметры почтового сервера*/
options mprint;
%let mvMailSubject = %sysget(smparam1);
%let mvMailText = %sysget(smparam2);
%let mvMailTo = %sysget(smparam3);
%let mvFilePath = %sysget(smparam4);
options emailhost="&EMAILHOST" 
	emailauthprotocol=&EMAILAUTHPROTOCOL
	EMAILFROM
	emailport=&EMAILPORT
	emailid="&EMAILID"
	emailpw="&EMAILPW";


%macro SendMail;
	%macro dummy;
	%mend dummy;
	/*	e-mail оповещение	*/
	filename mailbox email;
	data _NULL_;
	file mailbox to=%sysget(smparam3)
			subject="%sysget(smparam1)"
			encoding='utf-8'
			%if %length(&mvFilePath) ne 0 %then %do;
				attach = ("&mvFilePath" content_type="application/txt" )
			%end;
			;
	put "%sysget(smparam2)";
	run;
	
%mend SendMail;
%SendMail;