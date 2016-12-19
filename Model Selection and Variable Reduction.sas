
SAS Programs
/* Generated Code (IMPORT) */
/* Source File: MotorDeath.xls */
/* Source Path: /folders/myshortcuts/myfolder */
/* Code generated on: 11/21/16, 7:01 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/folders/myshortcuts/myfolder/MotorDeath.xls';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLS
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);
options nocenter nodate pageno=1 ls=76 ps=45 nolabel;
proc print data=work.import;
run;
data all;
set work.import;
run;

******************************************************
*Compute the descriptive statistics  and correlation *
******************************************************;
proc corr data =all NOSIMPLE;
var Deaths Drivers People Mileage Maxtemp Fuel;
run;
*************************************************
*Matrix Scatterplot of Deaths and five variables*
*************************************************;
proc sgscatter data = all;
Matrix Deaths Drivers People Mileage Maxtemp Fuel / diagonal=(histogram normal);
run;
**********************
*4.Fit the full model*
**********************;
***************************************
*Conduct multicollinearity diagnostics*
***************************************;
Proc reg data = all;
model Deaths = Drivers People Mileage Maxtemp Fuel / VIF COLLIN;
run;
****************************************
*Conduct Ridge Regression for the model*
****************************************;
ODS GRAPHICS ON;
Proc reg data = all outest=ridge ridge=0 to 0.2 by 0.01 outvif;
model Deaths = Drivers People Mileage Maxtemp Fuel / VIF COLLIN;
run;
proc print data=ridge;
    var _type_ _ridge_ _rmse_ intercept Drivers People Mileage Maxtemp Fuel;
    where _type_='RIDGE';
proc print data=ridge;
    var _ridge_ intercept Drivers People Mileage Maxtemp Fuel;
    where _type_='RIDGEVIF';
run;
ODS GRAPHICS OFF;
****************************************
*Conduct Principal Component Regression*
****************************************;
proc Princomp data=all out=prin outstat=stat;
var Drivers People Mileage Maxtemp Fuel;
run;
Proc reg data = all outest=prinest  outvif;
model Deaths = Drivers People Mileage Maxtemp Fuel / PCOMIT=1 to 4 VIF;
run;
proc print data=prinest;
    var _type_ _pcomit_ _rmse_ intercept Drivers People Mileage Maxtemp Fuel;
    where _type_='PARMS';
proc print data=prinest;
    var _type_ _pcomit_ _rmse_ intercept Drivers People Mileage Maxtemp Fuel;
    where _type_='IPC';
proc print data=prinest;
    var _type_ _pcomit_ _rmse_ Drivers People Mileage Maxtemp Fuel;
    where _type_ ='IPCVIF';
run;
proc print data=stat;
run;
proc reg data=prin outest=est;
model Deaths = prin1 prin2 prin3 / VIF collin;
proc print data=est;
run;
