libname PROJECT 'C:\sas\myfolders\Project\' ;

filename in1 'C:\dataset.csv' ;

* Include zeroes in the dataset ;
data PROJECT.project_data;
infile in1 delimiter=',' firstobs=2 missover ;
input id age churn chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1;	
run ;



ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/Proc_Univariate_After_removing_outliers.pdf";
PROC UNIVARIATE DATA = PROJECT.project_data;
	TITLE "Finding outliers using PROC UNIVARIATE";
	VAR age churn chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1;
	HISTOGRAM age churn chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1/ NORMAL;
	INSET MEAN = 'Mean' (5.2)
	      STD = 'Standard Deviation' (6.3) / FONT = 'Arial'
		  									 POS = NW
											 HEIGHT = 3;
RUN;
QUIT;
ods pdf close;
ods trace off;

ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/Freq_of_Churn.pdf";
proc freq data = PROJECT.project_data;
	tables churn / NOCUM NOPERCENT;
run;
ods pdf close;
ods trace off;

ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/Mean_of_Churn.pdf";
proc means data = PROJECT.project_data;
	TITLE "Mean of the churn varaible";
	VAR churn;
run;
ods pdf close;
ods trace off;

ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/Correltaion_Matrix.pdf";
PROC CORR DATA = PROJECT.project_data;
	TITLE "Correlation Matrix";
	VAR age chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1;
RUN;
ods pdf close;
ods trace off;

ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/Proc_Freq_All_Variables.pdf";
PROC FREQ DATA = PROJECT.project_data;
	TABLES age churn chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1;
RUN;
ods pdf close;
ods trace off;
* Creating formats ;
PROC FORMAT;
	VALUE AGEFMT 0-10 = "0-10"
	10-20 = "10-20"
	20-30 = "20-30"
	30-40 = "30-40"
	40-50 = "40-50"
	50-60 = "50-60"
	60-70 = "60-70";
RUN;
ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/Age_vs_Churn_barplot.pdf";
* Age vs Churn ; 
PATTERN1 COLOR=LIY VALUE = S;
PATTERN2 COLOR=VIYPK VALUE = S;
axis1 label=(a=90 f="Arial/Bold" "Percentage of customers") minor=(n=5);
axis2 label= (f="Arial/Bold" "Age");  
PROC GCHART DATA = PROJECT.project_data;
	TITLE "AGE vs CHURN";
	VBAR AGE / SUBGROUP = CHURN type=PCT inside=FREQ outside=PCT DISCRETE 
	raxis=axis1
	maxis=axis2;
	FORMAT AGE AGEFMT.;
RUN;

* Age vs Churn (where churn = 1) ;
PATTERN1 COLOR=VIYPK VALUE = S;
axis1 label=(a=90 f="Arial/Bold" "Percentage of customers") minor=(n=5);
axis2 label= (f="Arial/Bold" "Age");  
PROC GCHART DATA = PROJECT.project_data;
	TITLE "AGE vs CHURN";
	VBAR AGE / SUBGROUP = CHURN type=PCT inside=FREQ outside=PCT DISCRETE
	raxis=axis1
	maxis=axis2;
	WHERE churn = 1;
	FORMAT AGE AGEFMT.;
RUN;
ods pdf close;
ods trace off;

ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/scatterplot.pdf";
* Scatter plots between independent variables with strong correlation (>0.5) ;
SYMBOL1 V = DOT COLOR = RED;
PROC GPLOT DATA = PROJECT.project_data;
	TITLE "support_cases_0_1 vs sp_0_1";
	PLOT support_cases_0_1*sp_0_1;
RUN;

SYMBOL1 V = DOT COLOR = BLUE;
PROC GPLOT DATA = PROJECT.project_data;
	TITLE "support_cases_0_1 vs sp_0";
	PLOT support_cases_0_1*sp_0;
RUN;

SYMBOL1 V = DOT COLOR = GREEN;
PROC GPLOT DATA = PROJECT.project_data;
	TITLE "sp_0 vs sp_0_1";
	PLOT sp_0*sp_0_1;
RUN;
ods pdf close;
ods trace off;


ods trace on/listing;
ods pdf file = "C:/SAS/myfolders/Lib/Proc_Logistic.pdf";
* PROC LOGISTIC ;
PROC LOGISTIC DATA = PROJECT.project_data DESCENDING;
	TITLE "Logistic Regression to estimate CHURN";
	MODEL CHURN =  age chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1 /
	SELECTION = STEPWISE
	CTABLE PPROB = (0 to 1 by 0.02)
	LACKFIT
	RISKLIMITS;
RUN;
QUIT;
ods pdf close;
ods trace off;

* Applying the regression coefficients back to the data ;
PROC LOGISTIC DATA = PROJECT.project_data DESCENDING outest = PROJECT.coeffs_logit outmodel = PROJECT.model_logit;
	TITLE "Logistic Regression to estimate CHURN";
	MODEL CHURN =  age chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1 / 
	SELECTION = FORWARD SLENTRY = 0.8;
	SCORE DATA = PROJECT.project_data OUT = PROJECT.project_data_estimated;
RUN;
QUIT;

PROC LOGISTIC INMODEL = PROJECT.model_logit;
	SCORE DATA = PROJECT.project_data OUT = PROJECT.output;
RUN;
QUIT;

PROC SCORE data = PROJECT.project_data score = PROJECT.Coeffs_logit type = parms predict out = PROJECT.output;
VAR age chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1;
ID churn;
RUN;

PROC SCORE data = PROJECT.project_data score = PROJECT.Coeffs_logit type = parms predict out = PROJECT.output;
VAR age chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1;
ID churn;
RUN;


PROC PRINT data = PROJECT.project_data_estimated;
	VAR P_1;
	ID CHURN;
	WHERE churn = 0;
RUN;







* Explained in class ;
PROC LOGISTIC DATA = PROJECT.project_data descending outest = PROJECT.coeffs_logit outmodel = PROJECT.model_logit;
	MODEL churn = age chi_0 chi_0_1 support_cases_0 support_cases_0_1 
		sp_0 sp_0_1 logins_0_1 blog_articles_0_1 views_0_1 days_since_last_login_0_1;
RUN;
QUIT;

PROC UNIVARIATE DATA = PROJECT.project_data_estimated;
	VAR p_1;
RUN;
