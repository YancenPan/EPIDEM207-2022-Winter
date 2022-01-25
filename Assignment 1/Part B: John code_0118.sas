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
			smoke_stat = "Tobacco smoking status";
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
	table life_abb sex edu age_cat live_stat self_health death_cause audit_score aud_absrisk audrisk_absrisk smoke_stat/missing;
run;

proc univariate data=epi207.newjohnfmt;
	var age follow_time;
	histogram;
run;

/*check whether the missing participants of cause of death are living, so lack of cause of death*/
proc freq data=epi207.newjohnfmt;
	table death_cause*live_stat/nopercent nocol norow nocum;
run;











