/******** Epi 207_Assignment 3_reveiw and reproduce study outcome from Kim et al.********/
/******** Generate by Yancen Pan, Date: 02/27/2022********/

/*import dataset: cleaneddata.xlsx*/
PROC IMPORT OUT= WORK.hw3 
            DATAFILE= "D:\SAS documents\epi207 data\assignment 3\cleaned
data.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="cleaneddata"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

libname hw3 "D:\SAS documents\epi207 data\assignment 3";
option fmtsearch=(hw3);

data hw3.clean;
	set hw3;
run;

/*check and reproduce the variables in codebook by dataset: cleaneddata.xlsx*/
proc contents data=hw3.clean position;
run;

proc freq data=hw3.clean;
	table sex mhx_HT_yn HT DM DysL_ shx_smoke_yn shx_alcohol_yn BMIgr / missing;
run;

proc univariate data=hw3.clean;
	var age bexam_wc bexam_BMI bexam_BP_systolic bexam_BP_diastolic ASM_Wt_ MAP;
	histogram;
run;
/*All the numbers in codebook and data distionary can be produced, except for variable ASM_10, which is a 
variable that not included in clean dataset*/

/*since the dataset "outdata_label.sas7bdat" can not be open directly (the format not exist, 
	better if the format is provided direct), run the format process code in "Epi207_Assignment2_PartC_FINAL.sas"*/
proc format library=hw3;
	value Sex 	1='Male'
				2='Female';
	value YN	0='No'
				1='Yes';
	value BMIgr low-<18.5 = '0'
				18.5-22.9 = '1'
				23-24.9	  = '2'
				25-high   = '3';
	value BMItx 0 = 'Under weight (BMI <18.5 kg/m^2)'
				1 = 'Normal (BMI 18.5-22.9 kg/m^2)'
				2 = 'Overweight (BMI 23-24.9 kg/m^2)'
				3 = 'Obesity (BMI >=25 kg/m^2)';
run;	

/*Table 1*/
/*check and reproduce the variables in codebook and table 1 by dataset: outdata_label.sas7bdat*/
proc contents data=hw3.outdata_label position;
run;

proc freq data=hw3.outdata_label;
	table sex mhx_HT_yn HT DM DysL_ shx_smoke_yn shx_alcohol_yn BMIgr / missing;
run;

proc univariate data=hw3.outdata_label;
	var age bexam_wc bexam_BMI bexam_BP_systolic bexam_BP_diastolic ASM_Wt_ MAP ASM_10;
	histogram;
run;
/*All the numbers in codebook and data distionary can be produced, include ASM_10*/
/*better to include a histogram for continuous variables, to indicate: e.g. variable bexam_BMI is skewed*/

/*for table 1:
All the variables in table 1 can be reproduced except for variabel ASM, since no data for weight, 
ASM can not be produced by definition of ASM%.
The decimal of age should be consistent to other continuous variables.
Since variable DM, DysL_, bexam_wc, bexam_BMI, bexam_BP_systolic, bexam_BP_diastolic,BMIgr are 
not used in following analysis, better to be consistent when exclude/include them in table 1.
Variable MAP, which is one of the outcomes in analysis, should be include in table 1*/

/*Table 2a*/
proc logistic data=hw3.outdata_label descending;
	title "table 2a crude model";
	model HT=ASM_Wt_;
run;

proc logistic data=hw3.outdata_label descending;
	title "table 2a model 1";
	class sex;
	model HT=ASM_Wt_ age sex;
run;

proc logistic data=hw3.outdata_label descending;
	title "table 2a model 2";
	class sex shx_alcohol_yn shx_smoke_yn;
	model HT=ASM_Wt_ age sex shx_alcohol_yn shx_smoke_yn;
run;

/*table 2a crude model and model 1 can be reproduced, even with "class" statement for categorical variable sex.
However, there is a slight difference in model 2 after class for categorical variables*/

/*Table 2b*/
proc reg data=hw3.outdata_label;
	title "table 2b crude model";
	model MAP=ASM_10/clb;
run;

proc reg data=hw3.outdata_label;
	title "table 2b model 1";
	model MAP=ASM_10 sex age/clb;
run;

proc reg data=hw3.outdata_label;
	title "table 2b model 2";
	model MAP=ASM_10 sex age shx_alcohol_yn shx_smoke_yn/clb;
run;

/*table 2b can be reproduced exactly*/

/*Table supplementary*/
proc reg data=hw3.outdata_label;
	title "table supplementary crude model";
	model MAP=ASM_10/clb;
	where mhx_HT_yn=0;
run;

proc reg data=hw3.outdata_label;
	title "table supplementary model 1";
	model MAP=ASM_10 sex age/clb;
	where mhx_HT_yn=0;
run;

proc reg data=hw3.outdata_label;
	title "table supplementary model 2";
	model MAP=ASM_10 sex age shx_alcohol_yn shx_smoke_yn/clb;
	where mhx_HT_yn=0;
run;

/*Supplementary table can be reproduced exactly. But the code did not corresponde to the condition "exclude 
	those have medicial "history*/

/*figure 2*/

proc sgplot data=hw3.outdata_label;
	title "figure 2: scatterplot ASM & MAP by sex";
	reg y=MAP x=ASM_Wt_ / group=sex;
run;
/*figure 2 can be reproduced*/
