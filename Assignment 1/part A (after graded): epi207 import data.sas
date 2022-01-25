PROC IMPORT OUT= WORK.epi207 
            DATAFILE= "D:\SAS documents\epi207 data\journal.pmed.1003819
.s002.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=NO;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
