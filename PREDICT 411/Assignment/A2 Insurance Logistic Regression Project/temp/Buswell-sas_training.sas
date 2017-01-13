* Set variables / global macros;

%LET key = INDEX;
%LET response1 = TARGET_FLAG;
%LET response2 = TARGET_AMT;
%LET varname = name;

%LET data = logit_insurance;
%LET contents = &data._contents;



* Load the dataset;

libname mydata '/sscc/home/d/dgb2583/411/' access = readonly;

DATA &data.;
	SET mydata.logit_insurance;
	*SET mydata.logit_insurance_test;
RUN; QUIT;

PROC CONTENTS DATA = &data. OUT = &contents.;
RUN; QUIT;

*PROC PRINT DATA = &contents. (OBS=20);
*RUN; QUIT;

PROC MEANS DATA = &data. MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;



* Data rename;

%MACRO rename_num(varname);
	DATA &data_def.;
		SET &data_def. (RENAME = (&varname. = N_&varname.));
	RUN; QUIT;
%MEND;

%MACRO rename_cat(varname);
	DATA &data_def.;
		SET &data_def. (RENAME = (&varname. = C_&varname.));
	RUN; QUIT;
%MEND;

TITLE1 '';
TITLE2 '';

DATA &data._name;
	SET &data.;
RUN; QUIT;

PROC CONTENTS DATA = &data._name OUT = &contents._name;
RUN; QUIT;

DATA &contents._name;
	SET &contents._name;
		IF name = "&key." then DELETE;
		IF name = "&response1." then DELETE;
		IF name = "&response2." then DELETE;
RUN; QUIT;

%LET data_def = &data._name;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._name NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%rename_num('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._name NOBS = NUM;
			WHERE type = 2;
				CALL EXECUTE('%rename_cat('||name||')');
	END;
RUN; QUIT;

DATA &data._name;
	SET &data._name;
	IF C_EDUCATION = "<High School" 			then C_EDUCATION = "LT_HS";
	IF C_EDUCATION = "z_High School" 			then C_EDUCATION = "z_HS";
	IF C_JOB = "z_Blue Collar" 					then C_JOB = "z_BC";
	IF C_JOB = "Home Maker" 					then C_JOB = "Home_Maker";
	IF C_CAR_TYPE = "Panel Truck" 				then C_CAR_TYPE = "Panel_Truck";
	IF C_CAR_TYPE = "Sports Car" 				then C_CAR_TYPE = "Sports_Car";
	IF C_RED_CAR = "no" 						then C_RED_CAR = "No";
	IF C_RED_CAR = "yes" 						then C_RED_CAR = "Yes";
	IF C_URBANICITY = "Highly Urban/ Urban" 	then C_URBANICITY = "Urban";
	IF C_URBANICITY = "z_Highly Rural/ Rural" 	then C_URBANICITY = "z_Rural";
RUN; QUIT;

PROC MEANS DATA = &data._name MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;

PROC CONTENTS DATA = &data._name OUT = &contents._name;
RUN; QUIT;




* Data exploration;

%MACRO histogram(varname);
	PROC sgplot DATA = &data_def.;
		TITLE1 "Histogram Plot: &varname.";
		TITLE2 "with normal and kernel density estimates";
		HISTOGRAM &varname. / TRANSPARENCY = 0.5;
		DENSITY &varname. / TYPE = normal;
		DENSITY &varname. / TYPE = kernel;
	RUN; QUIT;
%MEND;

%MACRO box(varname);
	PROC sgplot DATA = &data_def.;
		TITLE1 "Box Plot: &varname.";
		TITLE2 "";
		vbox &varname.;
	RUN; QUIT;
%MEND;

%MACRO scatter(varname);
	ODS graphics ON / LOESSMAXOBS = 5000;
		
	PROC sgscatter DATA = &data_def.;
		TITLE1 "Scatter Plot: &response2. vs. &varname.";
		TITLE2 "with LOESS smoother";
		COMPARE y = &response2. x = &varname. / LOESS REG;
	RUN; QUIT;
		
	ODS graphics OFF;
%MEND;

%MACRO barplot(varname);
	ODS graphics ON;
	
	PROC sgplot DATA = &data_def.;
		TITLE1 "Bar Plot: &varname.";
		TITLE2 "";
		vbar &varname. / response = &response1.
		DATALABEL categoryorder = respasc;
	RUN; QUIT;
	
	ODS graphics OFF;
%MEND;

TITLE1 '';
TITLE2 '';

DATA &data._expl(DROP = &key.);
	SET &data._name;
RUN; QUIT;

PROC CONTENTS DATA = &data._expl OUT = &contents._expl;
RUN; QUIT;

DATA &contents._expl;
	SET &contents._expl;
		IF name = "&key." then DELETE;
RUN; QUIT;

%LET data_def = &data._expl;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._expl NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%histogram('||name||')');
				CALL EXECUTE('%box('||name||')');
				CALL EXECUTE('%scatter('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._expl NOBS = NUM;
			WHERE type = 2;
				CALL EXECUTE('%barplot('||name||')');
	END;
RUN; QUIT;

PROC FREQ DATA = &data._expl;
	TABLES _character_;
RUN; QUIT;

PROC MEANS DATA = &data._expl MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX;
RUN; QUIT;

PROC CONTENTS DATA = &data._expl OUT = &contents._expl;
RUN; QUIT;



* Data correlations;

%MACRO cleancorr(varname);
	DATA &data_def.;
		SET &data_def.;
		IF _name_ = "N&varname." then DELETE;
		IF _name_ = "P&varname." then DELETE;
	RUN; QUIT;
%MEND;

TITLE1 '';
TITLE2 '';

DATA &data._corr(DROP = &key.);
	SET &data._name;
RUN; QUIT;

PROC CONTENTS DATA = &data._corr OUT = &contents._corr;
RUN; QUIT;

ODS TRACE ON;

ODS OUTPUT PearsonCorr = &data._corr_wide;
PROC CORR DATA = &data._corr;
	VAR N_:;
	WITH &response2.;
RUN; QUIT;

ODS TRACE OFF;

* Note that wide_correlations is a 'wide' data set and we need a 'long' data set;
* We can use PROC TRANSPOSE to convert data from one format to the other;

PROC TRANSPOSE DATA = &data._corr_wide OUT = &data._corr_long;
RUN; QUIT;

%LET data_def = &data._corr_long;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._corr NOBS = NUM;
			CALL EXECUTE('%cleancorr('||name||')');
	END;
RUN; QUIT;

DATA &data._corr_long;
	SET &data._corr_long;
	RENAME _NAME_ = Variable;
	RENAME COL1 = correl;
RUN; QUIT;

PROC PRINT DATA = &data._corr_long;
RUN; QUIT;



* Data preparation;

%MACRO means(varname);
	PROC means DATA = &data_def. noprint;
	OUTPUT OUT = &varname. (DROP = _freq_ _type_)
		nmiss(&varname.)	= &varname._nmiss
		n(&varname.)		= &varname._n
		mean(&varname.)	 	= &varname._mean
		median(&varname.)	= &varname._median
		mode(&varname.) 	= &varname._mode
		std(&varname.)	 	= &varname._std
		skew(&varname.)	 	= &varname._skew
		P1(&varname.)	 	= &varname._P1
		P5(&varname.)		= &varname._P5
		P10(&varname.)	 	= &varname._P10
		P25(&varname.)	 	= &varname._P25
		P50(&varname.)	 	= &varname._P50
		P75(&varname.)	 	= &varname._P75
		P90(&varname.)	 	= &varname._P90
		P95(&varname.)	 	= &varname._P95
		P99(&varname.)		= &varname._P99
		min(&varname.)	 	= &varname._min
		max(&varname.)	 	= &varname._max
		qrange(&varname.)	= &varname._qrange
		;
	RUN; QUIT;
%MEND;

%MACRO transpose(varname);
	PROC transpose DATA = &varname. OUT = &varname._t;
		var _numeric_;
	RUN; QUIT;
%MEND;

%MACRO symputx_num(varname);
	DATA _null_;
		SET &varname._t;
			CALL symputx(_name_, strip(col1), 'g');
	RUN; QUIT;
%MEND;

%MACRO outlier(varname);
	DATA &data_def.;
		SET &data_def.;
			*IF (&varname. < &&&varname._P10) OR (&varname. > &&&varname._P90) THEN
			*	&varname._OF = 1.0; *ELSE &varname._OF = 0.0;
			
			*IF (&varname. < &&&varname._P5) OR (&varname. > &&&varname._P95) THEN
			*	&varname._OF = 1.0; *ELSE &varname._OF = 0.0;
			
			IF (&varname. < &&&varname._P1) OR (&varname. > &&&varname._P99) THEN
				&varname._OF = 1.0; ELSE &varname._OF = 0.0;
	RUN; QUIT;
%MEND;

%MACRO trim(varname);
	DATA &data_def.;
		SET &data_def.;
			&varname._T90 = &varname.;
			*&varname._T90 = max(min(&varname.,&&&varname._P90),&&&varname._P10);
			IF (&varname._T90 < &&&varname._P10) OR (&varname._T99 > &&&varname._P90) THEN
				&varname._T90 = '.';
			
			*&varname._T95 = &varname.;
			*&varname._T95 = max(min(&varname.,&&&varname._P95),&&&varname._P5);
			*IF (&varname._T95 < &&&varname._P5) OR (&varname._T95 > &&&varname._P95) THEN
			*	&varname._T95 = '.';
			
			&varname._T99 = &varname.;
			*&varname._T99 = max(min(&varname.,&&&varname._P99),&&&varname._P1);
			IF (&varname._T99 < &&&varname._P1) OR (&varname._T99 > &&&varname._P99) THEN
				&varname._T99 = '.';
	RUN; QUIT;
%MEND;

%MACRO missing(varname);
	DATA &data_def.;
		SET &data_def.;
			IF missing(&varname.) THEN
				&varname._MF = 1.0; ELSE &varname._MF = 0.0;
	RUN; QUIT;
%MEND;

%MACRO impute(varname);
	DATA &data_def.;
		SET &data_def.;
			*&varname._IMU = &varname.;
			*IF missing(&varname._IMU) THEN
			*	&varname._IMU = &&&varname._mean;
			
			*&varname._IMO = &varname.;
			*IF missing(&varname._IMO) THEN
			*	&varname._IMO = &&&varname._mode;
			
			&varname._IME = &varname.;
			IF missing(&varname._IME) THEN
				&varname._IME = &&&varname._median;
	RUN; QUIT;
%MEND;

%MACRO transform(varname);
	DATA &data_def.;
		SET &data_def.;
			&varname._LN = sign(&varname.) * log(abs(&varname.)+1);
			*&varname._SQ = (&varname.*&varname.);
			*&varname._RT = sqrt(&varname.);
	RUN; QUIT;
%MEND;

%MACRO drop(varname);
	DATA &data_def.;
		SET &data_def.;
			DROP &varname.;
	RUN; QUIT;
%MEND;

TITLE1 '';
TITLE2 '';

* Adhoc changes;

DATA &data._clean;
	SET &data._name;
RUN; QUIT;

DATA &data._clean;
	SET &data._clean;
	N_CAR_AGE = abs(N_CAR_AGE);
RUN; QUIT;

* Create new dataset of flags for continuous variables;

DATA &data._flag;
	SET &data._clean;
RUN; QUIT;

PROC CONTENTS DATA = &data._flag OUT = &contents._flag;
RUN; QUIT;

DATA &contents._flag;
	SET &contents._flag;
		IF name = "&key." then DELETE;
		IF name = "&response1." then DELETE;
		IF name = "&response2." then DELETE;
RUN; QUIT;

%LET data_def = &data._flag;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._flag NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%means('||name||')');
				CALL EXECUTE('%transpose('||name||')');
				CALL EXECUTE('%symputx_num('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._flag NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%missing('||name||')');
				CALL EXECUTE('%outlier('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._name NOBS = NUM;
			CALL EXECUTE('%drop('||name||')');
	END;
RUN; QUIT;

DATA &data._flag;
	MERGE &data._flag &data.(KEEP = &key.);
RUN; QUIT;

PROC MEANS DATA = &data._flag MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;

PROC CONTENTS DATA = &data._flag OUT = &contents._flag;
RUN; QUIT;

* Create dummy variables;

DATA &data._dum;
	SET &data._clean;
RUN; QUIT;

PROC CONTENTS DATA = &data._dum OUT = &contents._dum;
RUN; QUIT;

DATA &contents._dum;
	SET &contents._dum;
		IF name = "&key." then DELETE;
		IF name = "&response1." then DELETE;
		IF name = "&response2." then DELETE;
RUN; QUIT;

DATA &data._dum;
	SET &data._dum;	
		N_AGE_Risk_Yes	=	(N_AGE <= 30 | N_AGE >= 60);
		N_AGE_Risk_No	=	(N_AGE_Risk_Yes = 0);
		
		N_BLUEBOOK_Hi	=	(N_BLUEBOOK >= 27000);
		N_BLUEBOOK_Lo	=	(N_BLUEBOOK_Hi = 0);
		
		N_CLM_FREQ_No	=	(N_CLM_FREQ = 0);
		N_CLM_FREQ_Yes	=	(N_CLM_FREQ > 0);
		N_CLM_FREQ_Hi	=	(N_CLM_FREQ >= 2);
		N_CLM_FREQ_Lo	=	(N_CLM_FREQ_Hi = 0);

		N_HOMEKIDS_No	=	(N_HOMEKIDS = 0);
		N_HOMEKIDS_Yes	=	(N_HOMEKIDS > 0);
		
		N_INCOME_No 	= 	(N_INCOME = 0);
		N_INCOME_Yes 	= 	(N_INCOME > 0);
		N_INCOME_Hi		=	(N_INCOME >= 85000);
		N_INCOME_Lo		=	(N_INCOME_Hi = 0);
		
		N_KIDSDRIV_No	=	(N_KIDSDRIV = 0);
		N_KIDSDRIV_Yes	=	(N_KIDSDRIV > 0);
		
		N_MVR_PTS_No	=	(N_MVR_PTS = 0);
		N_MVR_PTS_Yes	=	(N_MVR_PTS > 0);
		N_MVR_PTS_Hi	=	(N_MVR_PTS >= 4);
		N_MVR_PTS_Lo	=	(N_MVR_PTS_Hi = 0);
		
		N_OLDCLAIM_No	=	(N_OLDCLAIM = 0);
		N_OLDCLAIM_Yes	=	(N_OLDCLAIM > 0);
		N_OLDCLAIM_Hi	=	(N_OLDCLAIM >= 9500);
		N_OLDCLAIM_Lo	=	(N_OLDCLAIM_Hi = 0);
		
		N_RENTER_Yes	=	(N_HOME_VAL <= 14400);
		N_RENTER_No		=	(N_RENTER_Yes = 0);
		
		N_TRAVTIME_Hi	=	(N_TRAVTIME >= 50);
		N_TRAVTIME_Lo	=	(N_TRAVTIME_Hi = 0);
RUN; QUIT;

%LET data_def = &data._dum;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._name NOBS = NUM;
			CALL EXECUTE('%drop('||name||')');
	END;
RUN; QUIT;

DATA &data._dum;
	MERGE &data._dum &data.(KEEP = &key.);
RUN; QUIT;

PROC MEANS DATA = &data._dum MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;

PROC CONTENTS DATA = &data._dum OUT = &contents._dum;
RUN; QUIT;

* Add trimmed series to original dataset;

DATA &data._trim;
	SET &data._clean;
RUN; QUIT;

PROC CONTENTS DATA = &data._trim OUT = &contents._trim;
RUN; QUIT;

DATA &contents._trim;
	SET &contents._trim;
		IF name = "&key." then DELETE;
		IF name = "&response1." then DELETE;
		IF name = "&response2." then DELETE;
RUN; QUIT;

%LET data_def = &data._trim;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._trim NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%means('||name||')');
				CALL EXECUTE('%transpose('||name||')');
				CALL EXECUTE('%symputx_num('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._trim NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%trim('||name||')');
	END;
RUN; QUIT;

* Impute all continuous series in original dataset;

DATA &data._imp;
	SET &data._trim;
RUN; QUIT;

PROC CONTENTS DATA = &data._imp OUT = &contents._imp;
RUN; QUIT;

DATA &contents._imp;
	SET &contents._imp;
		IF name = "&key." then DELETE;
		IF name = "&response1." then DELETE;
		IF name = "&response2." then DELETE;
RUN; QUIT;

%LET data_def = &data._imp;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._imp NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%means('||name||')');
				CALL EXECUTE('%transpose('||name||')');
				CALL EXECUTE('%symputx_num('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._imp NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%impute('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._imp NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%drop('||name||')');
	END;
RUN; QUIT;

* Transform all continuous series in original dataset;

DATA &data._trans;
	SET &data._imp;
RUN; QUIT;

PROC CONTENTS DATA = &data._trans OUT = &contents._trans;
RUN; QUIT;

DATA &contents._trans;
	SET &contents._trans;
		IF name = "&key." then DELETE;
		IF name = "&response1." then DELETE;
		IF name = "&response2." then DELETE;
RUN; QUIT;

%LET data_def = &data._trans;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._trans NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%transform('||name||')');
	END;
RUN; QUIT;

PROC MEANS DATA = &data._trans MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;

PROC CONTENTS DATA = &data._trans OUT = &contents._trans;
RUN; QUIT;

* Merge Datasets;

DATA &data._merged;
	MERGE &data._flag &data._dum &data._trans;
	*DROP where TYPE _CHARACTER_;
RUN; QUIT;

PROC CONTENTS DATA = &data._merged OUT = &contents._merged;
RUN; QUIT;
	
PROC MEANS DATA = &data._merged MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;



* Linear;

* AVS: Stepwise Selection;

PROC REG DATA = &data._merged;
	MODEL &response2. = 
	N_:
	/ SELECTION = stepwise SLENTRY = 0.10 SLSTAY = 0.10 VIF;
	OUTPUT OUT = sw_trans_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

PROC REG DATA = &data._merged;
	MODEL &response2. = 
	N_MVR_PTS_OF
	N_AGE_Risk_Yes
	N_CLM_FREQ_No
	N_HOMEKIDS_Yes
	N_INCOME_Lo
	N_KIDSDRIV_Yes
	N_RENTER_Yes
	N_BLUEBOOK_IME
	N_CAR_AGE_T90_IME
	N_MVR_PTS_IME
	N_TIF_IME_LN
	N_TRAVTIME_T99_IME_LN
	
	/ SELECTION = adjrsq START = 12 STOP = 12 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = reg_manual PREDICTED = P_TARGET_AMT RESIDUAL = res;
RUN; QUIT;

DATA reg_manual;
	SET reg_manual;
	res = (&response2. - P_TARGET_AMT);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = reg_manual MEAN NWAY NMISS;
	VAR abs_res square_res;
	OUTPUT out = reg_manual_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = reg_manual_em;
RUN; QUIT;


* Logistic;

* Manual;

PROC LOGISTIC DATA = &data._merged
plot(LABEL) = (roc(ID = prob) EFFECT influence(UNPACK)) plots(MAXPOINTS = none);
CLASS 	C_CAR_USE
		C_EDUCATION
		C_JOB
		C_MSTATUS
		C_REVOKED
		C_URBANICITY
		/ PARAM = REF;
		
MODEL &response1.(REF = "0") = 
	C_CAR_USE
	C_EDUCATION
	C_JOB
	C_MSTATUS
	C_REVOKED
	C_URBANICITY

	N_AGE_IME
	N_CLM_FREQ_IME
	N_INCOME_IME
	N_KIDSDRIV_IME
	N_MVR_PTS_IME
	N_OLDCLAIM_IME
	N_TIF_IME
	N_TRAVTIME_IME

	N_AGE_MF
	N_INCOME_MF

	N_INCOME_OF
	N_KIDSDRIV_OF
	N_MVR_PTS_OF
	
	/ RSQUARE LACKFIT ROCEPS = 0.10;
	OUTPUT OUT = ins_manual PREDICTED = P_TARGET_FLAG;
RUN; QUIT;

PROC NPAR1WAY DATA = ins_manual EDF;
	CLASS &response1.;
	VAR P_TARGET_FLAG;
RUN; QUIT;

DATA ins_manual (KEEP = INDEX TARGET_FLAG P_TARGET_FLAG);
	SET ins_manual;
RUN; QUIT;

* AVS: Forward Selection;

*PROC LOGISTIC DATA = &data._merged
*plot(LABEL) = (roc(ID = prob) EFFECT influence(UNPACK)) plots(MAXPOINTS = none);
*CLASS 	C_:
*		/ PARAM = ref;
*MODEL TARGET_FLAG(ref = "0") =
*	C_:
*	N_:
*	/ SELECTION = forward SLENTRY = 0.15 RSQUARE LACKFIT ROCEPS = 0.10;
*	OUTPUT OUT = ins_fw PREDICTED = yhat;
*RUN; QUIT;

PROC LOGISTIC DATA = &data._merged
plot(LABEL) = (roc(ID = prob) EFFECT influence(UNPACK)) plots(MAXPOINTS = none);
CLASS 	C_PARENT1
		C_MSTATUS
		C_EDUCATION
		C_JOB
		C_CAR_USE
		C_CAR_TYPE
		C_REVOKED
		C_URBANICITY
		/ PARAM = ref;
MODEL &response1.(ref = "0") =
	C_PARENT1
	C_MSTATUS
	C_EDUCATION
	C_JOB
	C_CAR_USE
	C_CAR_TYPE
	C_REVOKED
	C_URBANICITY
	
	N_AGE_MF
	N_CAR_AGE_MF
	N_AGE_Risk_Yes
	N_BLUEBOOK_Hi
	N_CLM_FREQ_Yes
	N_HOMEKIDS_No
	N_INCOME_Hi
	N_MVR_PTS_Hi
	N_BLUEBOOK_T90_IME
	N_HOMEKIDS_T99_IME
	N_HOME_VAL_T99_IME
	N_MVR_PTS_IME
	N_OLDCLAIM_IME
	N_TRAVTIME_T99_IME
	N_YOJ_T99_IME
	N_BLUEBOOK_T99_IME_LN
	N_HOME_VAL_T99_IME_LN
	N_INCOME_T99_IME_LN
	N_KIDSDRIV_IME_LN
	N_TIF_IME_LN
	
	/ RSQUARE LACKFIT ROCEPS = 0.10;
	OUTPUT OUT = ins_forward PREDICTED = P_TARGET_FLAG;
RUN; QUIT;

PROC NPAR1WAY DATA = ins_forward EDF;
	CLASS &response1.;
	VAR P_TARGET_FLAG;
RUN; QUIT;

DATA ins_forward (KEEP = INDEX TARGET_FLAG P_TARGET_FLAG);
	SET ins_forward;
RUN; QUIT;

* AVS: Stepwise Selection;

*PROC LOGISTIC DATA = &data._merged
*plot(LABEL) = (roc(ID = prob) EFFECT influence(UNPACK)) plots(MAXPOINTS = none);
*CLASS 	C_:
*		/ PARAM = ref;
*MODEL TARGET_FLAG(ref = "0") =
*	C_:
*	N_:
*	/ SELECTION = stepwise SLENTRY = 0.02 SLSTAY = 0.02 RSQUARE LACKFIT ROCEPS = 0.10;
*	OUTPUT OUT = ins_sw PREDICTED = yhat;
*RUN; QUIT;

PROC LOGISTIC DATA = &data._merged
plot(LABEL) = (roc(ID = prob) EFFECT influence(UNPACK)) plots(MAXPOINTS = none);
CLASS 	C_PARENT1
		C_MSTATUS
		C_EDUCATION
		C_JOB
		C_CAR_USE
		C_CAR_TYPE
		C_REVOKED
		C_URBANICITY
		/ PARAM = ref;
MODEL &response1.(ref = "0") =
	C_PARENT1
	C_MSTATUS
	C_EDUCATION
	C_JOB
	C_CAR_USE
	C_CAR_TYPE
	C_REVOKED
	C_URBANICITY
	
	N_AGE_Risk_Yes
	N_BLUEBOOK_Hi
	N_CLM_FREQ_Yes
	N_INCOME_Hi
	N_MVR_PTS_Hi
	N_BLUEBOOK_T90_IME
	N_HOME_VAL_T99_IME
	N_MVR_PTS_IME
	N_OLDCLAIM_IME
	N_TRAVTIME_T99_IME
	N_BLUEBOOK_T99_IME_LN
	N_INCOME_T99_IME_LN
	N_KIDSDRIV_IME_LN
	N_TIF_IME_LN
	
	/ RSQUARE LACKFIT ROCEPS = 0.10;
	OUTPUT OUT = ins_sw PREDICTED = P_TARGET_FLAG;
RUN; QUIT;


PROC NPAR1WAY DATA = ins_sw EDF;
	CLASS &response1.;
	VAR P_TARGET_FLAG;
RUN; QUIT;

DATA ins_sw (KEEP = INDEX TARGET_FLAG P_TARGET_FLAG);
	SET ins_sw;
RUN; QUIT;