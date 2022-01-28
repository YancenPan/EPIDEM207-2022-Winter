/*analyze dataset of John 2021*/

libname epi207 "D:\SAS documents\epi207 data";
option formdlim="_";
option fmtsearch=(epi207);


/*Table 2*/
/*To creat Alcohol abstainer (AUDIT-C=0)in table 2 for total mortality/specific cause of death (CVD and cancer),
first check the distribution of cause of death and AUDIT-C=0*/
proc freq data=epi207.newjohnfmt;
	table audit_score * death_cause/nopercent nocol norow nocum;
	table audit_score * live_stat/nopercent nocol norow nocum;
run;
/*total N for CVD mortality and cancer mortality is total number in specific AUDIC score (i.e.AUDIT-C=0) minus 
the number of deaths of other cause of death (i.e. those who die of cancer or others can not die of CVD)*/
/*generate dummy variable for CVD and cancer*/
data epi207.cvdcancer;
	set epi207.newjohnfmt;
	if death_cause=1 then cvd=1;
	if death_cause=. then cvd=0;
	if death_cause=2 then cancer=1;
	if death_cause=. then cancer=0;
run;
/*check the distribution for dummy variables*/
proc freq data=epi207.cvdcancer;
	table audit_score * cvd/nopercent nocol norow nocum;
	table audit_score * cancer/nopercent nocol norow nocum;
run;
/*the number of abstainers (AUDIT-C=0) matches to table 2*/

/*To creat Alcohol abstainer subgroups and alcohol consumers in table 2 for total mortality,
first check the distribution of cause of death and AUDIT-C=0*/
proc freq data=epi207.newjohnfmt;
	table aud_absrisk * live_stat;
run;


/*Table 2:AUDIT-C=0*/
/*Analysis-creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0)*/
proc phreg data=epi207.newjohnfmt;
	class audit_score (ref="1");
	model follow_time * live_stat(0)=audit_score/ rl;
run;

/*adjust age and sex - Analysis-creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0)*/
proc phreg data=epi207.newjohnfmt;
	class audit_score (ref="1");
	model follow_time * live_stat(0)=audit_score age sex / rl;
run;

/*Analysis for CVD - creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0) for CVD mortality*/
proc phreg data=epi207.cvdcancer;
	class audit_score (ref="1");
	model follow_time * cvd(0)=audit_score/ rl;
run;
/*Alternative: logistic regression*/
proc logistic data=epi207.cvdcancer desc;
	class audit_score (ref="1");
	model cvd = audit_score;
run;
/*the logistic regression outcome not match to the table 2 - so conclude that CVD and cancer of AUDIT-C=0 use Cox 
  proportional regression, because n for decease all > 5 */

/*adjust age and sex: Analysis for CVD - creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0) for CVD mortality*/
proc phreg data=epi207.cvdcancer;
	class audit_score (ref="1");
	model follow_time * cvd(0)=audit_score age sex/ rl;
run;

/*Analysis for cancer - creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0) for cancer mortality*/
proc phreg data=epi207.cvdcancer;
	class audit_score (ref="1");
	model follow_time * cancer(0)=audit_score/ rl;
run;
/*not match to what showed in table2*/

/*adjust age and sex: Analysis for cancer - creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0) for cancer mortality*/
proc phreg data=epi207.cvdcancer;
	class audit_score (ref="1. 1-3");
	model follow_time * cancer(0)=audit_score age sex/ rl;
run;

/*Table 2: For alcohol abstainer subgroups all and alcohol consumers*/
/*Analysis-creat table 2-COX proportional regression-Alcohol abstainer subgroups and alcohol consumers*/
proc phreg data=epi207.newjohnfmt;
	class aud_absrisk (ref="1");
	model follow_time * live_stat(0)=aud_absrisk / rl;
run;

/*adjust age and sex - Analysis-creat table 2-COX proportional regression-Alcohol abstainer subgroups and alcohol consumers*/
proc phreg data=epi207.newjohnfmt;
	class aud_absrisk (ref="1");
	model follow_time * live_stat(0)=aud_absrisk age sex / rl;
run;


/*Table 3*/
/*distribution: N and n in table 3*/
proc freq data=epi207.newjohnfmt;
	table audrisk_absrisk * live_stat;
run;

/*Analysis-creat table 3-COX proportional regression-Alcohol abstainer subgroups and alcohol consumers subgroup*/
proc phreg data=epi207.newjohnfmt;
	class audrisk_absrisk (ref="1");
	model follow_time * live_stat(0)=audrisk_absrisk / rl;
run;

/*adjust age and sex - Analysis-creat table 3-COX proportional regression-Alcohol abstainer subgroups and alcohol consumers subgroup*/
proc phreg data=epi207.newjohnfmt;
	class audrisk_absrisk (ref="1");
	model follow_time * live_stat(0)=audrisk_absrisk age sex / rl;
run;


/*Table 4 - generate variable group1, group7a and group5-8 variables*/
/*creat dummy variable for subgroups*/
data epi207.subgroup;
	set epi207.newjohnfmt;
	if alab_risk = 1 then group1=0;
	if alab_risk = 2 then group1=1;
	if alab_risk = 3 then group8=0;
	if alab_risk = 4 then group8=1;
	if alab_risk = 5 then group7a=0;
	if alab_risk = 6 then group7a=1;
	if alab_risk = 7 then group7=0;
	if alab_risk = 8 then group7=1;
	if alab_risk = 9 then group6=0;
	if alab_risk = 10 then group6=1;
	if alab_risk = 11 then group5=0;
	if alab_risk = 12 then group5=1;
	if alab_risk = 13 then group2=0;
	if alab_risk = 14 then group2=1;
	if alab_risk = 15 then group3=0;
	if alab_risk = 16 then group3=1;
	if alab_risk = 17 then group4=0;
	if alab_risk = 18 then group4=1;
run;

/*distribution of N and n in table 4*/
proc freq data=epi207.subgroup;
	table (group1-group8) * live_stat;
	table group7a * live_stat;
run;

/*get HR for each subgroup in table 4*/
/*group 2-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group2 / rl;
run;
/*group 2-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group2 age sex/ rl;
run;

/*group 3-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group3 / rl;
run;
/*group 3-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group3 age sex/ rl;
run;

/*group 4-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group4 / rl;
run;
/*group 4-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group4 age sex/ rl;
run;

/*group 5-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group5 / rl;
run;
/*group 5-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group5 age sex/ rl;
run;

/*group 6-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group6 / rl;
run;
/*group 6-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group6 age sex/ rl;
run;

/*group 7-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group7 / rl;
run;
/*group 7-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group7 age sex/ rl;
run;

/*group 7a-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group7a / rl;
run;
/*group 7a-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group7a age sex/ rl;
run;

/*group 8-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group8 / rl;
run;
/*group 8-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group8 age sex/ rl;
run;

/*group 1-unajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group1 / rl;
run;
/*group 1-ajusted*/
proc phreg data=epi207.subgroup;
	model follow_time * live_stat(0)= group1 age sex/ rl;
run;


/*Figure 1, 2*/
Data epi207.figure;
	set epi207.newjohnfmt;
	/*figure1*/
	if aud_absrisk=1 then fig1=0;
	if aud_absrisk=6 then fig1=1;
	if aud_absrisk=7 then fig1=2;
	if aud_absrisk=8 then fig1=3;
	if aud_absrisk=9 then fig1=4;
	if aud_absrisk=10 then fig1=5;
	if aud_absrisk=11 then fig1=6;
	if aud_absrisk=12 then fig1=7;
	if aud_absrisk=13 then fig1=8;
	/*figure2*/
	if audrisk_absrisk=1 then fig2=0;
	if audrisk_absrisk=14 then fig2=1;
	if audrisk_absrisk=15 then fig2=2;
	if audrisk_absrisk=16 then fig2=3;
	if audrisk_absrisk=17 then fig2=4;
	if audrisk_absrisk=18 then fig2=5;
	if audrisk_absrisk=19 then fig2=6;
	if audrisk_absrisk=20 then fig2=7;
	if audrisk_absrisk=21 then fig2=8;
run;

/*Figure 1: for abstainer subgroups*/
ods graphics on;
proc phreg data=epi207.figure plots(overlay) = survival;
	class fig1;
	model follow_time * live_stat(0)= fig1 age sex;
	baseline covariates=epi207.figure out=figure1/diradj group=fig1;
run;

/*Figure 2: for abstainer subgroups, reference is never smokers*/
ods graphics on;
proc phreg data=epi207.figure plots(overlay) = survival;
	class fig2;
	model follow_time * live_stat(0)= fig2 age sex;
	baseline covariates=epi207.figure out=figure2/diradj group=fig2;
run;

/*adjust scale to paper*/
ods output survivalplot=_surv1;
proc phreg data=epi207.figure plots(overlay) = survival;
	class fig1;
	model follow_time * live_stat(0)= fig1 age sex;
	baseline covariates=epi207.figure out=figure1/diradj group=fig1;
run;

proc sgplot data=_surv1;
	step x=time y=survival/ group=fig1;
run;

ods output survivalplot=_surv2;
proc phreg data=epi207.figure plots(overlay) = survival;
	class fig2;
	model follow_time * live_stat(0)= fig2 age sex;
	baseline covariates=epi207.figure out=figure2/diradj group=fig2;
run;

proc sgplot data=_surv2;
	step x=time y=survival/ group=fig2;
run;
