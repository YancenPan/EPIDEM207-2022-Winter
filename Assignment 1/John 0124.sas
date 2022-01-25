/*analyze dataset of John 2021*/

libname epi207 "D:\SAS documents\epi207 data";
option formdlim="_";
option fmtsearch=(epi207);


proc contents data=epi207.john;
run;

/*codebook-distribution for categorical variables; distribution for numerical variables*/
/*For categorical variables*/
proc freq data=epi207.john;
	table F2 F3 F4 F5 F9 F12 F13 F14 F15 F16 F18;
run;
/*For numerical variables*/
Proc univariate data=epi207.john;
	var F1 F10 F19;
run;

/****create a new dataset, assign variable names, drop useless variables, name new dataset as "newjohn"*/
data epi207.newjohn;
	set epi207.john;
	id=F19;
	age=F1;
	if F2="1. Nein 1" then life_abb=0;
	if F2="5. Ja 5" then life_abb=1;
	if F3="male" then sex=1;
	if F3="female" then sex=0;
	if F4="9 or less" then edu=1;
	if F4="10-11" then edu=2;
	if F4="12 or more" then edu=3;
	if F5="39: 17-39" then age_cat=1;
	if F5="40: 40-49" then age_cat=2;
	if F5="50: 50-64" then age_cat=3;
	live_stat=F9;
	follow_time=F10;
	if F12="fair poor" then self_health=1;
	if F12="good" then self_health=2;
	if F12="excell very good" then self_health=3;
	death_cause=F13;
	audit_score=F14;
	aud_absrisk=F15;
	audrisk_absrisk=F16;
	smoke_stat=F18;
	alab_risk=F17;
run;

/*add varialbe label*/
data epi207.newjohn;
	set epi207.newjohn (drop=F1-F19);
	label 	id = "Participant ID number"
			age = "Age"
			life_abb = "lifetime alcohol abstinence"
			sex = "Sex"
			edu = "Education level (years)"
			age_cat = "Age group"
			live_stat = "living status"
			follow_time = "follow up time"
			self_health = "Self-rated health"
			death_cause = "Cause of death"
			audit_score = "AUDIT-C sum score"
			aud_absrisk = "AUDIT-C sum score or Alcohol abstainers with risk factors"
			audrisk_absrisk = "AUDIT-C sum score with risk factors and Alcohol abstainers with risk factors"
			smoke_stat = "Tobacco smoking status"
			alab_risk = "alcohol consumption/abstinent risk factors, smoking status";
run;

/*new dataset:proc contents*/
proc contents data=epi207.newjohn position;
run;

/*format categorical variables*/

proc format library=epi207;
	value abs	0 = "No"
				1 = "Yes";
	value sex  	1 = "male"
				0 = "female";
	value edu	1 = "9 or less"
				2 = "10-11"
				3 = "12 or more";
	value age	1 = "17-39"
				2 = "40-49"
				3 = "50-64";
	value live	0 = "alive"
				1 = "deceased";
	value hlth	1 = "Fair/Poor"
				2 = "Good"
				3 = "Excellent/Very good";
run;

data epi207.newjohnfmt;
	set epi207.newjohn;
	format life_abb abs. sex sex. edu edu. age_cat age. live_stat live. self_health hlth.;
run;

/*codebook_distribution of new categorical variables and distribition of new numerical variables*/
proc freq data=epi207.newjohnfmt;
	table   life_abb sex edu age_cat live_stat self_health death_cause audit_score 
			aud_absrisk audrisk_absrisk smoke_stat alab_risk/missing;
run;

proc univariate data=epi207.newjohnfmt;
	var age follow_time;
	histogram;
run;

/*check whether the missing participants of cause of death are living, so lack of cause of death*/
proc freq data=epi207.newjohnfmt;
	table death_cause*live_stat/nopercent nocol norow nocum;
run;


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
	if death_cause="1. HK" then cvd=1;
	if death_cause="" then cvd=0;
	if death_cause="2. Krebs" then cancer=1;
	if death_cause="" then cancer=0;
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
	class audit_score (ref="1. 1-3");
	model follow_time * live_stat(0)=audit_score/ rl;
run;

/*adjust age and sex - Analysis-creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0)*/
proc phreg data=epi207.newjohnfmt;
	class audit_score (ref="1. 1-3");
	model follow_time * live_stat(0)=audit_score age sex / rl;
run;

/*Analysis for CVD - creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0) for CVD mortality*/
proc phreg data=epi207.cvdcancer;
	class audit_score (ref="1. 1-3");
	model follow_time * cvd(0)=audit_score/ rl;
run;
/*Alternative: logistic regression*/
proc logistic data=epi207.cvdcancer desc;
	class audit_score (ref="1. 1-3");
	model cvd = audit_score;
run;
/*the logistic regression outcome not match to the table 2 - so conclude that CVD and cancer of AUDIT-C=0 use Cox 
  proportional regression, because n for decease all > 5 */

/*adjust age and sex: Analysis for CVD - creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0) for CVD mortality*/
proc phreg data=epi207.cvdcancer;
	class audit_score (ref="1. 1-3");
	model follow_time * cvd(0)=audit_score age sex/ rl;
run;

/*Analysis for cancer - creat table 2-COX proportional regression-Alcohol abstainer (AUDIT-C=0) for cancer mortality*/
proc phreg data=epi207.cvdcancer;
	class audit_score (ref="1. 1-3");
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
	class aud_absrisk (ref="1. Auditc 1-3");
	model follow_time * live_stat(0)=aud_absrisk / rl;
run;

/*adjust age and sex - Analysis-creat table 2-COX proportional regression-Alcohol abstainer subgroups and alcohol consumers*/
proc phreg data=epi207.newjohnfmt;
	class aud_absrisk (ref="1. Auditc 1-3");
	model follow_time * live_stat(0)=aud_absrisk age sex / rl;
run;


/*Table 3*/
/*distribution: N and n in table 3*/
proc freq data=epi207.newjohnfmt;
	table audrisk_absrisk * live_stat;
run;

/*Analysis-creat table 3-COX proportional regression-Alcohol abstainer subgroups and alcohol consumers subgroup*/
proc phreg data=epi207.newjohnfmt;
	class audrisk_absrisk (ref="1. audc1-3 ns");
	model follow_time * live_stat(0)=audrisk_absrisk / rl;
run;

/*adjust age and sex - Analysis-creat table 3-COX proportional regression-Alcohol abstainer subgroups and alcohol consumers subgroup*/
proc phreg data=epi207.newjohnfmt;
	class audrisk_absrisk (ref="1. audc1-3 ns");
	model follow_time * live_stat(0)=audrisk_absrisk age sex / rl;
run;


/*Table 4 - generate variable group1, group7a and group5-8 variables*/
/*creat dummy variable for subgroups*/
data epi207.subgroup;
	set epi207.newjohnfmt;
	if alab_risk = "1. alm aud1 0 ard 0 acut 0 Ges gut ns" then group1=0;
	if alab_risk = "2. aab aud1 0 ard 0 acut 0 Ges gut ns" then group1=1;
	if alab_risk = "3. alm aud1 0 ard 0 acut 0 Ges wenig ns" then group8=0;
	if alab_risk = "4. aab aud1 0 ard 0 acut 0 Ges wenig ns" then group8=1;
	if alab_risk = "5. alm aud1 0 ard 0 acut 0 eltd" then group7a=0;
	if alab_risk = "6. aab aud1 0 ard 0 acut 0 eltd" then group7a=1;
	if alab_risk = "7. alm aud1 0 ard 0 acut 0 fs" then group7=0;
	if alab_risk = "8. aab aud1 0 ard 0 acut 0 fs" then group7=1;
	if alab_risk = "9. alm aud1 0 ard 0 acut 0 cs<20" then group6=0;
	if alab_risk = "10. aab aud1 0 ard 0 acut 0 cs<20" then group6=1;
	if alab_risk = "11. alm aud1 0 ard 0 acut 0 cs>19" then group5=0;
	if alab_risk = "12. aab aud1 0 ard 0 acut 0 cs>19" then group5=1;
	if alab_risk = "11. alm aud1 0 ard 0 acut 0 cs>19" then group5=0;
	if alab_risk = "12. aab aud1 0 ard 0 acut 0 cs>19" then group5=1;
	if alab_risk = "13. alm aud1 1" then group2=0;
	if alab_risk = "14. aab aud1 1" then group2=1;
	if alab_risk = "15. alm aud1 0 ard 1" then group3=0;
	if alab_risk = "16. aab aud1 0 ard 1" then group3=1;
	if alab_risk = "17. alm aud1 0 ard 0 acut 1" then group4=0;
	if alab_risk = "18. aab aud1 0 ard 0 acut 1" then group4=1;
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
	if aud_absrisk="1. Auditc 1-3" then fig1=0;
	if aud_absrisk="6. Abs Gesh gut" then fig1=1;
	if aud_absrisk="7. Abs AUD Dr" then fig1=2;
	if aud_absrisk="8. Abs ARD" then fig1=3;
	if aud_absrisk="9. Abs Alkprobl" then fig1=4;
	if aud_absrisk="10. Abs cs>19" then fig1=5;
	if aud_absrisk="11. Abs cs<20" then fig1=6;
	if aud_absrisk="12. Abs fs" then fig1=7;
	if aud_absrisk="13. Abs Ges weniger" then fig1=8;
	/*figure2*/
	if audrisk_absrisk="1. audc1-3 ns" then fig2=0;
	if audrisk_absrisk="14. aab Ges gut" then fig2=1;
	if audrisk_absrisk="15. aab AUD Dr" then fig2=2;
	if audrisk_absrisk="16. aab ARD" then fig2=3;
	if audrisk_absrisk="17. aab Alkprobl" then fig2=4;
	if audrisk_absrisk="18. aab cs>19" then fig2=5;
	if audrisk_absrisk="19. aab cs<20" then fig2=6;
	if audrisk_absrisk="20. aab fs" then fig2=7;
	if audrisk_absrisk="21. aab Ges weniger" then fig2=8;

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
