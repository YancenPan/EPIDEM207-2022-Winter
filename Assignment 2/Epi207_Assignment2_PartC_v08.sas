/*************************************************************
Name: 		Yancen Pan & Melissa Soohoo
Email:		yancenpan@g.ucla.edu & msoohoo1@ucla.edu 

Class: 		EPIM 207 
Due Date:	20220218
Purpose:	Assignment 2 --- Part C 
**************************************************************/ 

libname hw "C:\Users\MS\Documents\WINTER2022\EPI207\HW\HW1";
libname hw2 "C:\Users\MS\Documents\WINTER2022\EPI207\HW\HW2\C";
*libname hw2 "D:\SAS documents\epi207 data\assignment 2\MS"; 

options fmtsearch= (hw);

/*Note: 
The file HW2.john_clean2.sas7bdat was derived in prior codes and shared with YP for analyses. 
MS performed Table 1 & 3 
YP performed Table 2 & Figure 2/3 
SAS codes were combined into a single file. 
*/; 


**************************************************************
*               Update the Final dataset 					 *
**************************************************************
;
/*Note, the present study does not use any of the extra alcohol subgroups as the original John paper
They have been deleted from this present file.
This present data does use the same set of formats*/; 

/*data hw2.john_clean2;*/
/*set hw.john_clean; */
/*drop alc_abs_cons--alc_cons_vs_abs;*/
/*run; */
/*NOTE: The data set HW2.JOHN_CLEAN2 has 4028 observations and 15 variables.*/

**************************************************************
*               Get information for 				 	 	 *
*				data dictionary & codebook					 *
*				Summarized by hand in Excel					 *
**************************************************************
;
proc contents data =hw2.JOHN_CLEAN2  varnum; 
run; 
Proc means data=hw2.JOHN_CLEAN2  n nmiss mean stddev min p25 p50 p75 max maxdec=2;; 
var 
study_id age futime;
run; 
Proc univariate data = hw2.JOHN_CLEAN2 ; histogram; var study_id age futime; run; 

/*With missing*/;
Proc freq data=hw2.JOHN_CLEAN2   order= internal; 
table 
lifetime_aab--mort 
health -- smoke/missing  ;
format lifetime_aab--mort health -- smoke ; 
run; 
/*Without missing*/; 
Proc freq data=hw2.JOHN_CLEAN2   order= internal; 
table 
cod cvd_mort ca_mort  ;
format cod cvd_mort ca_mort   ; 
run; 

Proc format library=hw  MAXLABLEN=1000
CNTLOUT = forms; 
run; 

data forms2;
set forms (keep =FMTNAME start LABEL); 
header = cats (Start, "  = ", Label);
run; 
Proc print data =forms2;
var FMTNAME header ;
run; 


**************************************************************
*               Make Table 1	 							 *
**************************************************************
;

Proc freq data =hw2.john_clean2; 
table (female age_grp edu  health alc_cons) ;
table  (female age_grp edu  health alc_cons)*smoke/ norow nopercent;
format smoke; 
title " Table 1"; 
run; 
Proc means data =hw2.john_clean2 mean stddev maxdec=2; 
var age; run; 
Proc means data =hw2.john_clean2 mean stddev maxdec=2; 
var age; class smoke; run; 

/*Copy and transfer to Excel for post-processing*/; 

**************************************************************
*              Looking at the KM	 						 *
**************************************************************
;

Proc lifetest data =hw2.john_clean2 notable  plots=(s);
time futime*mort(0);
strata smoke;
format smoke; 
run; 
/*KM looks ok, mild crossing in the beginning. 
Crossing with smoke = 3 at the end  
*/; 

**************************************************************
*               Make Table 2	 							 *
*				Total Mortality,  CVD & CA Mort 			 *
**************************************************************
;

%macro mo(out); 
ods select nobs  CensoredSummary ParameterEstimates;
ods output ParameterEstimates=table2a;
proc phreg data =hw2.john_clean2  ;
	class smoke (ref= "0")  ;
	model futime*&out (0) = smoke/ rl ties=efron; 
	format smoke;
title "Table 2a: smoke  &out"; 
run;  

ods select nobs  CensoredSummary ParameterEstimates;
ods output ParameterEstimates=table2b;
proc phreg data =hw2.john_clean2  ;
	class smoke (ref= "0") female ;
	model futime*&out (0) = smoke age female/ rl ties=efron; 
	format smoke; 
title "Table 2b: smoke &out adj age and sex"; 
run;  

ods select nobs  CensoredSummary ParameterEstimates;
ods output ParameterEstimates=table2c;
proc phreg data =hw2.john_clean2  ;
	class smoke (ref= "0") female health edu alc_cons;
	model futime*&out (0) = smoke age female health edu alc_cons/ rl ties=efron; 
	format smoke;
title "Table 2c smoke &out adj age, sex, health, edu, and alcohol consumption "; 
run;  

/*print out with 2 decimals*/
proc print data=table2a;
	title "table 2a print";
	format hazardratio 8.2 HRLowerCL 8.2 HRUpperCL 8.2;
run;

proc print data=table2b;
	title "table 2b print";
	format hazardratio 8.2 HRLowerCL 8.2 HRUpperCL 8.2;
run;

proc print data=table2c;
		title "table 2c print";
	format hazardratio 8.2 HRLowerCL 8.2 HRUpperCL 8.2;
run;

Proc freq data =hw2.john_clean2; 
table  smoke*&out/ nocol nopercent outpct ;
format smoke; 
where &out ~=.; 
run; 
%mend mo;
%mo (mort);
%mo (cvd_mort);
%mo (ca_mort);


**************************************************************
*               Make Table 3 								 *
*				Total Mortality								 *
*				Stratified by Gender 						 *
*				CVD and Cancer Mortality are for Supplement	 *
**************************************************************
;

%macro fem(st);
%macro mo(out); 
ods select nobs  CensoredSummary ParameterEstimates;
ods output ParameterEstimates = parm_m1_&out._f&st (keep = parameter classval0 hazardratio hr: ) ; 
proc phreg data =hw2.john_clean2  ;
	where female=&st;
	class smoke (ref= "0")  ;
	model futime*&out (0) = smoke/ rl ties=efron; 
	format smoke female;
title "Table 3: smoke &out Model 1 where female =&st "; 
run;  

ods select nobs  CensoredSummary ParameterEstimates;
ods output ParameterEstimates = parm_m2_&out._f&st (keep = parameter classval0 hazardratio hr: ) ; 
proc phreg data =hw2.john_clean2  ;
	where female=&st;
	class smoke (ref= "0")  ;
	model futime*&out (0) = smoke age / rl ties=efron; 
	format smoke ;
title "Table 3: smoke &out Model 2 where female =&st"; 
run;  

ods select nobs  CensoredSummary ParameterEstimates;
ods output ParameterEstimates = parm_m3_&out._f&st (keep = parameter classval0 hazardratio hr: ) ; 
proc phreg data =hw2.john_clean2  ;
	where female=&st;
	class smoke (ref= "0") health edu alc_cons  ;
	model futime*&out (0) = smoke age health edu alc_cons / rl ties=efron; 
	format smoke ;
title "Table 3: smoke &out Model 3 where female =&st"; 
run;  

data parm_m1_&out._f&st.2;
set parm_m1_&out._f&st ; 
where parameter ="Smoke";
	smoke = input (classval0, 2.);
	hazardratio_m1 = hazardratio; 
	HRLowerCL_m1 = HRLowerCL ; 
	HRUpperCL_m1 = HRUpperCL ; 
keep  smoke--HRUpperCL_m1; 
run; 

data parm_m2_&out._f&st.2;
set parm_m2_&out._f&st ; 
where parameter ="Smoke";
	smoke = input (classval0, 2.);
	hazardratio_m2 = hazardratio; 
	HRLowerCL_m2 = HRLowerCL ; 
	HRUpperCL_m2 = HRUpperCL ; 
keep  smoke--HRUpperCL_m2; 
run; 

data parm_m3_&out._f&st.2;
set parm_m3_&out._f&st ; 
where parameter ="Smoke";
	smoke = input (classval0, 2.);
	hazardratio_m3 = hazardratio; 
	HRLowerCL_m3 = HRLowerCL ; 
	HRUpperCL_m3 = HRUpperCL ; 
keep  smoke--HRUpperCL_m3; 
run; 

Proc freq data =hw2.john_clean2; 
table  smoke*&out/ nocol nopercent outpct out=freq_&out._f&st (where =(&out=1) keep = smoke &out COUNT PCT_ROW); ;
table smoke / out=freqtot_&out._f&st (rename=(count = total_count) drop=percent);
format smoke; 
where &out ~=. and female=&st; 
run; 

data bo_&out._f&st; 
merge 
freqtot_&out._f&st
freq_&out._f&st (in=a drop=&out rename=(count=&out._count) )
parm_m1_&out._f&st.2
parm_m2_&out._f&st.2
parm_m3_&out._f&st.2
;
by  smoke ;
if a; 

/* Concatenate the Event N(%); and HR[CI] */; 
&out._pct_text = cat (&out._count," (", put(pct_row,5.2),")");

hr_m1 = cat (put(hazardratio_m1,4.2)," (", put(HRLowerCL_m1,4.2), "-", put(HRUpperCL_m1,5.2),")");
hr_m2 = cat (put(hazardratio_m2,4.2)," (", put(HRLowerCL_m2,4.2), "-", put(HRUpperCL_m2,5.2),")");
hr_m3 = cat (put(hazardratio_m3,4.2)," (", put(HRLowerCL_m3,4.2), "-", put(HRUpperCL_m3,5.2),")");

/*Group 1 as reference */; 
if  smoke = 0 then do; 
hr_m1 = "1.00 (Reference)";
hr_m2 = "1.00 (Reference)";
hr_m3 = "1.00 (Reference)";
end; 

keep smoke total_count &out._pct_text hr_:;
run; 
%mend mo;
%mo (mort);
%mo (cvd_mort);
%mo (ca_mort);

%mend fem; 
%fem (1);
%fem (0);

ods html;
%macro mo (out);
proc print data=bo_&out._f1 label noobs;
format smoke  smkf.;
title " Table 3: &out for only females";
run; 
proc print data=bo_&out._f0 label noobs;
format smoke  smkf.;
title " Table 3: &out for only males";
run; 
%mend mo ; 
%mo (mort); 
%mo (cvd_mort);
%mo (ca_mort);


**************************************************************
*               Make Figure 2 and Figure 3					 *
*				Total Mortality								 *
**************************************************************


/*Figure 2 was the age/sex adjusted survival function.
Calculated the reference values based on the whole cohort. 
*/;
ods graphics on; 
ods output survivalplot=_surv2; 
proc phreg data = hw2.john_clean2 plots(overlay)=survival ;
	class   smoke (ref='Never smoker') female ;
	model futime*mort (0)= smoke age female  /rl ties=efron ;
	baseline covariates= hw2.john_clean2 out=base/diradj group=smoke;
run; 

proc sgplot data =_surv2; 
step x=time y=survival/group = smoke; 
styleattrs 	datacontrastcolors= ( navy green red darkorange brown ) 
			datalinepatterns=(solid dash dashdotdot  shortdashdot dot longdash );
keylegend/title= " ";
run; 


/*Figure 3 was the age/sex/education/health status/alcohol consumption adjusted survival function.
Calculated the reference values based on the whole cohort. 
*/;
ods graphics on; 
ods output survivalplot=_surv3; 
proc phreg data = hw2.john_clean2 plots(overlay)=survival ;
	class   smoke (ref='Never smoker') female health edu alc_cons;
	model futime*mort (0)= smoke age female health edu alc_cons /rl ties=efron ;
	baseline covariates= hw2.john_clean2 out=base2/diradj group=smoke;
run; 

proc sgplot data =_surv3; 
step x=time y=survival/group = smoke; 
styleattrs 	datacontrastcolors= ( navy green red darkorange brown ) 
			datalinepatterns=(solid dash dashdotdot  shortdashdot dot longdash );
keylegend/title= " ";
run; 
