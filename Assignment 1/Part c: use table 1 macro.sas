* Sample to illustrate use of Table1 macro;
libname epi207 "D:\SAS documents\epi207 data";
option fmtsearch=(epi207);

options nodate nocenter ls = 147 ps = 47 orientation = landscape;

/** change this to location where you saved the .sas files**/
%let MacroDir=D:\SAS documents\epi207 data\table1\table1macro;

filename tab1  "&MacroDir./Table1.sas";
%include tab1;

/***********************/
/****UTILITY SASJOBS****/
/***********************/
filename tab1prt  "&MacroDir./Table1Print.sas";
%include tab1prt;

filename npar1way  "&MacroDir./Npar1way.sas";
%include npar1way;

filename CheckVar  "&MacroDir./CheckVar.sas";
%include CheckVar;

filename Uni  "&MacroDir./Univariate.sas";
%include Uni;

filename Varlist  "&MacroDir./Varlist.sas";
%include Varlist;

filename Words  "&MacroDir./Words.sas";
%include Words;

filename Append  "&MacroDir./Append.sas";
%include Append;

/** specify folder in which to store results***/

%let results=D:\SAS documents\epi207 data\table1;


/*** John table 1 by macro call ***/
%Table1(DSName=epi207.newjohnfmt,
        GroupVar=audit_score,
        FreqVars=sex age_cat edu smoke_stat self_health,
        Total=C,
        FreqCell=N(CP),
        Missing=Y,
        Print=N,
        Label=L,
        Out=table1outcome,
        Out1way=);

*options mprint  symbolgen mlogic;
run;

ods pdf file="&results.\Table1_output.pdf";
title 'baseline characteristics of the study participants by baseline levels of alcohol consumption';
%Table1Print(DSname=table1outcome,Space=Y)
ods pdf close;
run;


