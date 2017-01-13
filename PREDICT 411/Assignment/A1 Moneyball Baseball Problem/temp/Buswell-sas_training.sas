* Set variables / global macros;

%LET key = INDEX;
%LET response = TARGET_WINS;
%LET varname = name;

%LET data = moneyball_train;
%LET contents = &data._contents;



* Load the dataset;

libname mydata '/sscc/home/d/dgb2583/411/' access = readonly;

DATA &data.;
	SET mydata.moneyball;
*	SET mydata.moneyball_test;
RUN; QUIT;

PROC CONTENTS DATA = &data. OUT = &contents.;
RUN; QUIT;

*PROC PRINT DATA = &contents. (OBS=20);
*RUN; QUIT;



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
	ODS graphics ON;
		
	PROC sgscatter DATA = &data_def.;
		TITLE1 "Scatter Plot: &response. vs. &varname.";
		TITLE2 "with LOESS smoother";
		COMPARE y = &response. x = &varname. / LOESS REG;
	RUN; QUIT;
		
	ODS graphics OFF;
%MEND;


DATA &data._expl(DROP = &key.);
	SET &data.;
*	MERGE &data._trans &data.(KEEP = &response.);
RUN; QUIT;

PROC CONTENTS DATA = &data._expl OUT = &contents._expl;
RUN; QUIT;

PROC MEANS DATA = &data._expl MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX;
RUN; QUIT;

%LET data_def = &data._expl;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._expl NOBS = NUM;
			WHERE TYPE = 1;
				CALL EXECUTE('%histogram('||name||')');
				CALL EXECUTE('%box('||name||')');
				CALL EXECUTE('%scatter('||name||')');
	END;
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
	SET &data.;
*	MERGE &data._trans &data.(KEEP = &response.);
RUN; QUIT;

PROC CONTENTS DATA = &data._corr OUT = &contents._corr;
RUN; QUIT;

ODS TRACE ON;

ODS OUTPUT PearsonCorr = &data._corr_wide;
PROC CORR DATA = &data._corr;
	VAR _all_;
	WITH &response.;
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

%MACRO symputx(varname);
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
			*&varname._T90 = &varname.;
			*&varname._T90 = max(min(&varname.,&&&varname._P90),&&&varname._P10);
			*IF (&varname._T90 < &&&varname._P10) OR (&varname._T99 > &&&varname._P90) THEN
			*	&varname._T90 = '.';
			
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

* Create new dataset of flags;

DATA &data._flag;
	SET &data.;
RUN; QUIT;

PROC CONTENTS DATA = &data._flag OUT = &contents._flag;
RUN; QUIT;

DATA &contents._flag;
	SET &contents._flag;
		IF name = "&key." then DELETE;
		IF name = "&response." then DELETE;
		IF name = "TEAM_BATTING_HBP" then DELETE;
RUN; QUIT;

%LET data_def = &data._flag;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._flag NOBS = NUM;
			CALL EXECUTE('%means('||name||')');
			CALL EXECUTE('%transpose('||name||')');
			CALL EXECUTE('%symputx('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._flag NOBS = NUM;
			CALL EXECUTE('%missing('||name||')');
			CALL EXECUTE('%outlier('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents. NOBS = NUM;
			CALL EXECUTE('%drop('||name||')');
	END;
RUN; QUIT;

DATA &data._flag;
	MERGE &data._flag &data.(KEEP = &key.);
RUN; QUIT;

PROC MEANS DATA = &data._flag MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;

* Add trimmed series to original dataset;

DATA &data._trim;
	SET &data.;
RUN; QUIT;

PROC CONTENTS DATA = &data._trim OUT = &contents._trim;
RUN; QUIT;

DATA &contents._trim;
	SET &contents._trim;
		IF name = "&key." then DELETE;
		IF name = "&response." then DELETE;
		IF name = "TEAM_BATTING_HBP" then DELETE;
RUN; QUIT;

%LET data_def = &data._trim;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._trim NOBS = NUM;
			CALL EXECUTE('%means('||name||')');
			CALL EXECUTE('%transpose('||name||')');
			CALL EXECUTE('%symputx('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._trim NOBS = NUM;
			CALL EXECUTE('%trim('||name||')');
	END;
RUN; QUIT;

* Impute all series in original dataset;

DATA &data._imp;
	SET &data._trim;
RUN; QUIT;

PROC CONTENTS DATA = &data._imp OUT = &contents._imp;
RUN; QUIT;

DATA &contents._imp;
	SET &contents._imp;
		IF name = "&key." then DELETE;
		IF name = "&response." then DELETE;
		IF name = "TEAM_BATTING_HBP" then DELETE;
RUN; QUIT;

%LET data_def = &data._imp;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._imp NOBS = NUM;
			CALL EXECUTE('%means('||name||')');
			CALL EXECUTE('%transpose('||name||')');
			CALL EXECUTE('%symputx('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._imp NOBS = NUM;
			CALL EXECUTE('%impute('||name||')');
	END;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._imp NOBS = NUM;
			CALL EXECUTE('%drop('||name||')');
	END;
RUN; QUIT;

* Transform all series in original dataset;

DATA &data._trans;
	SET &data._imp;
RUN; QUIT;

PROC CONTENTS DATA = &data._trans OUT = &contents._trans;
RUN; QUIT;

DATA &contents._trans;
	SET &contents._trans;
		IF name = "&key." then DELETE;
		IF name = "&response." then DELETE;
		IF name = "TEAM_BATTING_HBP" then DELETE;
RUN; QUIT;

%LET data_def = &data._trans;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._trans NOBS = NUM;
			CALL EXECUTE('%transform('||name||')');
	END;
RUN; QUIT;

DATA &contents._drop;
	SET &contents.;
		IF name ne "&key." AND
		name ne "&response." AND
		name ne "TEAM_BATTING_HBP" then DELETE;
RUN; QUIT;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._drop NOBS = NUM;
			CALL EXECUTE('%drop('||name||')');
	END;
RUN; QUIT;

DATA &data._trans;
	MERGE &data._trans &data.(KEEP = &key.);
RUN; QUIT;

PROC MEANS DATA = &data._trans MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
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
	ODS graphics ON;
		
	PROC sgscatter DATA = &data_def.;
		TITLE1 "Scatter Plot: &response. vs. &varname.";
		TITLE2 "with LOESS smoother";
		COMPARE y = &response. x = &varname. / LOESS REG;
	RUN; QUIT;
		
	ODS graphics OFF;
%MEND;


DATA &data._expl(DROP = &key.);
*	SET &data.;
	MERGE &data._trans &data.(KEEP = &response.);
RUN; QUIT;

PROC CONTENTS DATA = &data._expl OUT = &contents._expl;
RUN; QUIT;

PROC MEANS DATA = &data._expl MIN P1 P5 P10 P25 P50 P75 P90 P95 P99 MAX;
RUN; QUIT;

%LET data_def = &data._expl;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._expl NOBS = NUM;
			WHERE TYPE = 1;
				CALL EXECUTE('%histogram('||name||')');
				CALL EXECUTE('%box('||name||')');
				CALL EXECUTE('%scatter('||name||')');
	END;
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
*	SET &data.;
	MERGE &data._trans &data.(KEEP = &response.);
RUN; QUIT;

PROC CONTENTS DATA = &data._corr OUT = &contents._corr;
RUN; QUIT;

ODS TRACE ON;

ODS OUTPUT PearsonCorr = &data._corr_wide;
PROC CORR DATA = &data._corr;
	VAR _all_;
	WITH &response.;
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



* Regression / Regression wPCA / Prediction;

* Regression;

* Merge Datasets;

DATA &data._merged(DROP = &key.);
	MERGE &data._flag &data._trans &data.(KEEP = &response.);
	&response._LN = sign(&response.) * log(abs(&response.)+1);
	RUN; QUIT;

PROC CONTENTS DATA = &data._merged OUT = &contents._merged;
RUN; QUIT;
	
PROC MEANS DATA = &data._merged MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;
	

* Split for Cross-Validation;

TITLE1 '';
TITLE2 '';

DATA &data._cv;
	SET &data._merged;
	IF cmiss(of _all_) then DELETE;
	U = uniform(123);
	IF (U < 0.70) then TRAIN = 1;
		ELSE TRAIN = 0;
	IF (U > 0.70) then TEST = 1;
		ELSE TEST = 0;
	IF (TRAIN = 1) then TRAIN_&response. = &response.;
		ELSE TRAIN_&response. = .;
	IF (TEST = 1) then TEST_&response. = &response.;
		ELSE TEST_&response. = .;
	IF (TRAIN = 1) then TRAIN_&response._LN = &response._LN;
		ELSE TRAIN_&response._LN = .;
	IF (TEST = 1) then TEST_&response._LN = &response._LN;
		ELSE TEST_&response._LN = .;
	DROP U;
RUN; QUIT;

PROC CONTENTS DATA = &data._cv OUT = &contents._cv;
RUN; QUIT;

PROC FREQ DATA = &data._cv;
	TABLES train test;
RUN; QUIT;

PROC FORMAT;
	VALUE Prediction_Grade (DEFAULT = 7)
	. = 'Missing'
	0.0 - 0.05 = 'Grade 0'
	0.05 <- 0.10 = 'Grade 1'
	0.10 <- 0.15 = 'Grade 2'
	0.15 <- high = 'Grade 3'
	;
RUN;


* AVS;

TITLE1 '';
TITLE2 '';

*PROC REG DATA = &data._cv;
*	MODEL TRAIN_&response. = 
*	TEAM_:
*	/ SELECTION = adjrsq BEST = 5 VIF;
*	OUTPUT OUT = adjr_orig_train PREDICTED = yhat RESIDUAL = res;
*RUN; QUIT;

*PROC REG DATA = &data._cv;
*	MODEL TRAIN_&response._LN = 
*	TEAM_:
*	/ SELECTION = adjrsq BEST = 5 VIF;
*	OUTPUT OUT = adjr_trans_train PREDICTED = yhat RESIDUAL = res;
*RUN; QUIT;

*PROC REG DATA = &data._cv;
*	MODEL TRAIN_&response. = 
*	TEAM_:
*	/ SELECTION = stepwise SLENTRY = 0.02 SLSTAY = 0.02 VIF;
*	OUTPUT OUT = sw_orig_train PREDICTED = yhat RESIDUAL = res;
*RUN; QUIT;

*PROC REG DATA = &data._cv;
*	MODEL TRAIN_&response._LN = 
*	TEAM_:
*	/ SELECTION = stepwise SLENTRY = 0.02 SLSTAY = 0.02 VIF;
*	OUTPUT OUT = sw_trans_train PREDICTED = yhat RESIDUAL = res;
*RUN; QUIT;


ODS TRACE ON;

* Manual - Original Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response. = 
	TEAM_BATTING_H_IME
	TEAM_BATTING_2B_IME
	TEAM_BATTING_3B_IME
	TEAM_BATTING_HR_IME
	TEAM_BATTING_BB_IME
	TEAM_BATTING_SO_IME
	TEAM_BASERUN_SB_IME
	TEAM_PITCHING_H_IME
	TEAM_FIELDING_E_IME

	TEAM_BATTING_SO_MF
	TEAM_BASERUN_SB_MF

	TEAM_BATTING_3B_OF
	TEAM_PITCHING_H_OF
	TEAM_FIELDING_E_OF
	/ SELECTION = adjrsq START = 14 STOP = 14 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = manual_orig_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA manual_orig_train_res;
	SET manual_orig_train;
	res = (TRAIN_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = manual_orig_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = manual_orig_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = manual_orig_train_em;
RUN; QUIT;

DATA manual_orig_train_ov;
	SET manual_orig_train;
	OV = abs(((yhat-TRAIN_&response.)/TRAIN_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = manual_orig_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response. = 
	TEAM_BATTING_H_IME
	TEAM_BATTING_2B_IME
	TEAM_BATTING_3B_IME
	TEAM_BATTING_HR_IME
	TEAM_BATTING_BB_IME
	TEAM_BATTING_SO_IME
	TEAM_BASERUN_SB_IME
	TEAM_PITCHING_H_IME
	TEAM_FIELDING_E_IME

	TEAM_BATTING_SO_MF
	TEAM_BASERUN_SB_MF

	TEAM_BATTING_3B_OF
	TEAM_PITCHING_H_OF
	TEAM_FIELDING_E_OF
	/ SELECTION = adjrsq START = 14 STOP = 14 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = manual_orig_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA manual_orig_test_res;
	SET manual_orig_test;
	res = (TEST_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = manual_orig_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = manual_orig_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = manual_orig_test_em;
RUN; QUIT;

DATA manual_orig_test_ov;
	SET manual_orig_test;
	OV = abs(((yhat-TEST_&response.)/TEST_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = manual_orig_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;


* Manual - Transformed Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response._LN = 
	TEAM_BATTING_H_IME_LN
	TEAM_BATTING_2B_IME_LN
	TEAM_BATTING_3B_IME_LN
	TEAM_BATTING_HR_IME_LN
	TEAM_BATTING_BB_IME_LN
	TEAM_BASERUN_SB_IME_LN
	TEAM_PITCHING_H_IME_LN
	TEAM_FIELDING_E_IME_LN

	TEAM_BATTING_SO_MF
	TEAM_BASERUN_SB_MF

	TEAM_BATTING_3B_OF
	TEAM_BASERUN_SB_OF
	TEAM_PITCHING_H_OF
	TEAM_FIELDING_E_OF
	/ SELECTION = adjrsq START = 14 STOP = 14 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = manual_trans_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA manual_trans_train_res;
	SET manual_trans_train;
	res = (TRAIN_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = manual_trans_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = manual_trans_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = manual_trans_train_em;
RUN; QUIT;

DATA manual_trans_train_ov;
	SET manual_trans_train;
	OV = abs(((yhat-TRAIN_&response._LN)/TRAIN_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = manual_trans_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response._LN = 
	TEAM_BATTING_H_IME_LN
	TEAM_BATTING_2B_IME_LN
	TEAM_BATTING_3B_IME_LN
	TEAM_BATTING_HR_IME_LN
	TEAM_BATTING_BB_IME_LN
	TEAM_BASERUN_SB_IME_LN
	TEAM_PITCHING_H_IME_LN
	TEAM_FIELDING_E_IME_LN

	TEAM_BATTING_SO_MF
	TEAM_BASERUN_SB_MF

	TEAM_BATTING_3B_OF
	TEAM_BASERUN_SB_OF
	TEAM_PITCHING_H_OF
	TEAM_FIELDING_E_OF
	/ SELECTION = adjrsq START = 14 STOP = 14 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = manual_trans_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA manual_trans_test_res;
	SET manual_trans_test;
	res = (TEST_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = manual_trans_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = manual_trans_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = manual_trans_test_em;
RUN; QUIT;

DATA manual_trans_test_ov;
	SET manual_trans_test;
	OV = abs(((yhat-TEST_&response._LN)/TEST_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = manual_trans_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;


* AVS: Adjrsq - Original Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response. = 
	TEAM_BASERUN_CS_OF
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_SO_MF
	TEAM_FIELDING_DP_MF
	TEAM_BASERUN_SB_IME
	TEAM_BATTING_2B_T99_IME
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_BB_IME
	TEAM_BATTING_H_IME
	TEAM_PITCHING_HR_IME
	TEAM_PITCHING_SO_T99_IME
	TEAM_BATTING_2B_T99_IME_LN
	TEAM_BATTING_H_T99_IME_LN
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_E_IME_LN
	TEAM_PITCHING_SO_T99_IME_LN
	/ SELECTION = adjrsq START = 16 STOP = 16 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = adjrsq_orig_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA adjrsq_orig_train_res;
	SET adjrsq_orig_train;
	res = (TRAIN_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = adjrsq_orig_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = adjrsq_orig_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = adjrsq_orig_train_em;
RUN; QUIT;

DATA adjrsq_orig_train_ov;
	SET adjrsq_orig_train;
	OV = abs(((yhat-TRAIN_&response.)/TRAIN_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = adjrsq_orig_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response. = 
	TEAM_BASERUN_CS_OF
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_SO_MF
	TEAM_FIELDING_DP_MF
	TEAM_BASERUN_SB_IME
	TEAM_BATTING_2B_T99_IME
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_BB_IME
	TEAM_BATTING_H_IME
	TEAM_PITCHING_HR_IME
	TEAM_PITCHING_SO_T99_IME
	TEAM_BATTING_2B_T99_IME_LN
	TEAM_BATTING_H_T99_IME_LN
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_E_IME_LN
	TEAM_PITCHING_SO_T99_IME_LN
	/ SELECTION = adjrsq START = 16 STOP = 16 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = adjrsq_orig_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA adjrsq_orig_test_res;
	SET adjrsq_orig_test;
	res = (TEST_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = adjrsq_orig_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = adjrsq_orig_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = adjrsq_orig_test_em;
RUN; QUIT;

DATA adjrsq_orig_test_ov;
	SET adjrsq_orig_test;
	OV = abs(((yhat-TEST_&response.)/TEST_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = adjrsq_orig_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;


* AVS: Adjrsq - Transformed Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response._LN = 
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_SO_MF
	TEAM_BASERUN_SB_IME
	TEAM_BATTING_2B_T99_IME
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_SO_IME
	TEAM_PITCHING_BB_IME
	TEAM_PITCHING_HR_T99_IME
	TEAM_BATTING_2B_T99_IME_LN
	TEAM_BATTING_BB_IME_LN
	TEAM_BATTING_H_IME_LN
	TEAM_BATTING_H_T99_IME_LN
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_E_IME_LN
	TEAM_PITCHING_BB_IME_LN
	TEAM_PITCHING_H_IME_LN
	/ SELECTION = adjrsq START = 16 STOP = 16 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = adjrsq_trans_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA adjrsq_trans_train_res;
	SET adjrsq_trans_train;
	res = (TRAIN_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = adjrsq_trans_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = adjrsq_trans_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = adjrsq_trans_train_em;
RUN; QUIT;

DATA adjrsq_trans_train_ov;
	SET adjrsq_trans_train;
	OV = abs(((yhat-TRAIN_&response._LN)/TRAIN_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = adjrsq_trans_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response._LN = 
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_SO_MF
	TEAM_BASERUN_SB_IME
	TEAM_BATTING_2B_T99_IME
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_SO_IME
	TEAM_PITCHING_BB_IME
	TEAM_PITCHING_HR_T99_IME
	TEAM_BATTING_2B_T99_IME_LN
	TEAM_BATTING_BB_IME_LN
	TEAM_BATTING_H_IME_LN
	TEAM_BATTING_H_T99_IME_LN
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_E_IME_LN
	TEAM_PITCHING_BB_IME_LN
	TEAM_PITCHING_H_IME_LN
	/ SELECTION = adjrsq START = 16 STOP = 16 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = adjrsq_trans_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA adjrsq_trans_test_res;
	SET adjrsq_trans_test;
	res = (TEST_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = adjrsq_trans_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = adjrsq_trans_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = adjrsq_trans_test_em;
RUN; QUIT;

DATA adjrsq_trans_test_ov;
	SET adjrsq_trans_test;
	OV = abs(((yhat-TEST_&response._LN)/TEST_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = adjrsq_trans_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;


* AVS: Stepwise - Original Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response. = 
	TEAM_BASERUN_CS_OF
	TEAM_BASERUN_SB_IME
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_BB_IME
	TEAM_BATTING_H_IME
	TEAM_BATTING_H_T99_IME
	TEAM_BATTING_SO_IME
	TEAM_BATTING_SO_MF
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_DP_OF
	TEAM_FIELDING_E_IME_LN
	TEAM_PITCHING_BB_T99_IME_LN
	TEAM_PITCHING_HR_T99_IME
	/ SELECTION = adjrsq START = 14 STOP = 14 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = sw_orig_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA sw_orig_train_res;
	SET sw_orig_train;
	res = (TRAIN_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = sw_orig_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = sw_orig_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = sw_orig_train_em;
RUN; QUIT;

DATA sw_orig_train_ov;
	SET sw_orig_train;
	OV = abs(((yhat-TRAIN_&response.)/TRAIN_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = sw_orig_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response. = 
	TEAM_BASERUN_CS_OF
	TEAM_BASERUN_SB_IME
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_BB_IME
	TEAM_BATTING_H_IME
	TEAM_BATTING_H_T99_IME
	TEAM_BATTING_SO_IME
	TEAM_BATTING_SO_MF
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_DP_OF
	TEAM_FIELDING_E_IME_LN
	TEAM_PITCHING_BB_T99_IME_LN
	TEAM_PITCHING_HR_T99_IME
	/ SELECTION = adjrsq START = 14 STOP = 14 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = sw_orig_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA sw_orig_test_res;
	SET sw_orig_test;
	res = (TEST_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = sw_orig_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = sw_orig_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = sw_orig_test_em;
RUN; QUIT;

DATA sw_orig_test_ov;
	SET sw_orig_test;
	OV = abs(((yhat-TEST_&response.)/TEST_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = sw_orig_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;


* AVS: Stepwise - Transformed Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response._LN = 
	TEAM_BASERUN_CS_OF
	TEAM_BASERUN_SB_IME
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_BB_OF
	TEAM_BATTING_H_IME_LN
	TEAM_BATTING_H_T99_IME_LN
	TEAM_BATTING_SO_MF
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_DP_MF
	TEAM_FIELDING_E_T99_IME_LN
	TEAM_PITCHING_H_OF
	TEAM_PITCHING_HR_T99_IME
	/ SELECTION = adjrsq START = 13 STOP = 13 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = sw_trans_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA sw_trans_train_res;
	SET sw_trans_train;
	res = (TRAIN_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = sw_trans_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = sw_trans_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = sw_trans_train_em;
RUN; QUIT;

DATA sw_trans_train_ov;
	SET sw_trans_train;
	OV = abs(((yhat-TRAIN_&response._LN)/TRAIN_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = sw_trans_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response._LN = 
	TEAM_BASERUN_CS_OF
	TEAM_BASERUN_SB_IME
	TEAM_BASERUN_SB_MF
	TEAM_BATTING_3B_T99_IME
	TEAM_BATTING_BB_OF
	TEAM_BATTING_H_IME_LN
	TEAM_BATTING_H_T99_IME_LN
	TEAM_BATTING_SO_MF
	TEAM_FIELDING_DP_IME_LN
	TEAM_FIELDING_DP_MF
	TEAM_FIELDING_E_T99_IME_LN
	TEAM_PITCHING_H_OF
	TEAM_PITCHING_HR_T99_IME
	/ SELECTION = adjrsq START = 13 STOP = 13 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = sw_trans_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA sw_trans_test_res;
	SET sw_trans_test;
	res = (TEST_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = sw_trans_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = sw_trans_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = sw_trans_test_em;
RUN; QUIT;

DATA sw_trans_test_ov;
	SET sw_trans_test;
	OV = abs(((yhat-TEST_&response._LN)/TEST_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = sw_trans_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

ODS TRACE OFF;

* Regression wPCA;

* Principle Component Analysis;

TITLE1 '';
TITLE2 '';

DATA &data._pca(DROP = &key.);
	SET &data._trans;
RUN; QUIT;

PROC CONTENTS DATA = &data._pca OUT = &contents._pca;
RUN; QUIT;

ODS graphics ON;

PROC PRINCOMP DATA = &data._pca OUT = &data._pca_out
	PLOTS = scree(unpackpanel) N = 30;
	ODS OUTPUT eigenvectors = pca_ev;
RUN; QUIT;

ODS graphics OFF;

PROC TRANSPOSE DATA = pca_ev OUT = pca_ev_trans;
	ID variable;
RUN; QUIT;

DATA pca_ev_score;
	SET pca_ev_trans;
	_TYPE_ = "SCORE";
RUN; QUIT;

DATA &data._pca_out;
	MERGE &data._pca_out &data.(KEEP = &key.);
RUN; QUIT;

PROC CONTENTS DATA = &data._pca_out OUT = &contents._pca_out;
RUN; QUIT;

PROC MEANS DATA = &data._pca_out MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;


* Merge Datasets;

DATA &data._merged;
	MERGE &data._flag &data._trans &data._pca_out &data.(KEEP = &response.);
	&response._LN = sign(&response.) * log(abs(&response.)+1);
	RUN; QUIT;

PROC CONTENTS DATA = &data._merged OUT = &contents._merged;
RUN; QUIT;
	
PROC MEANS DATA = &data._merged MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;


* Split for Cross-Validation;

TITLE1 '';
TITLE2 '';

DATA &data._cv;
	SET &data._merged;
	IF cmiss(of _all_) then DELETE;
	U = uniform(123);
	IF (U < 0.70) then TRAIN = 1;
		ELSE TRAIN = 0;
	IF (U > 0.70) then TEST = 1;
		ELSE TEST = 0;
	IF (TRAIN = 1) then TRAIN_&response. = &response.;
		ELSE TRAIN_&response. = .;
	IF (TEST = 1) then TEST_&response. = &response.;
		ELSE TEST_&response. = .;
	IF (TRAIN = 1) then TRAIN_&response._LN = &response._LN;
		ELSE TRAIN_&response._LN = .;
	IF (TEST = 1) then TEST_&response._LN = &response._LN;
		ELSE TEST_&response._LN = .;
	DROP U;
RUN; QUIT;

PROC CONTENTS DATA = &data._cv OUT = &contents._cv;
RUN; QUIT;

PROC FREQ DATA = &data._cv;
	TABLES train test;
RUN; QUIT;

PROC FORMAT;
	VALUE Prediction_Grade (DEFAULT = 7)
	. = 'Missing'
	0.0 - 0.05 = 'Grade 0'
	0.05 <- 0.10 = 'Grade 1'
	0.10 <- 0.15 = 'Grade 2'
	0.15 <- high = 'Grade 3'
	;
RUN;


ODS TRACE ON;

* PCA - Original Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response. = 
	Prin1-Prin15
	/ SELECTION = adjrsq START = 15 STOP = 15 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = pca_orig_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA pca_orig_train_res;
	SET pca_orig_train;
	res = (TRAIN_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = pca_orig_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = pca_orig_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = pca_orig_train_em;
RUN; QUIT;

DATA pca_orig_train_ov;
	SET pca_orig_train;
	OV = abs(((yhat-TRAIN_&response.)/TRAIN_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = pca_orig_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response. = 
	Prin1-Prin15
	/ SELECTION = adjrsq START = 15 STOP = 15 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = pca_orig_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA pca_orig_test_res;
	SET pca_orig_test;
	res = (TEST_&response. - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = pca_orig_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = pca_orig_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = pca_orig_test_em;
RUN; QUIT;

DATA pca_orig_test_ov;
	SET pca_orig_test;
	OV = abs(((yhat-TEST_&response.)/TEST_&response.));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = pca_orig_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;


* PCA - Transformed Response;

PROC REG DATA = &data._cv;
	MODEL TRAIN_&response._LN = 
	Prin1-Prin15
	/ SELECTION = adjrsq START = 15 STOP = 15 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = pca_trans_train PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA pca_trans_train_res;
	SET pca_trans_train;
	res = (TRAIN_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = pca_trans_train_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = pca_trans_train_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = pca_trans_train_em;
RUN; QUIT;

DATA pca_trans_train_ov;
	SET pca_trans_train;
	OV = abs(((yhat-TRAIN_&response._LN)/TRAIN_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = pca_trans_train_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

PROC REG DATA = &data._cv;
	MODEL TEST_&response._LN = 
	Prin1-Prin15
	/ SELECTION = adjrsq START = 15 STOP = 15 MSE ADJRSQ AIC BIC CP VIF;
	OUTPUT OUT = pca_trans_test PREDICTED = yhat RESIDUAL = res;
RUN; QUIT;

DATA pca_trans_test_res;
	SET pca_trans_test;
	res = (TEST_&response._LN - yhat);
	WHERE res IS NOT missing;
	abs_res = abs(res);
	square_res = (res**2);
RUN; QUIT;

PROC MEANS DATA = pca_trans_test_res mean nway nmiss;
	VAR abs_res square_res;
	OUTPUT out = pca_trans_test_em
	mean(abs_res) = MAE
	mean(square_res) = MSE;
RUN; QUIT;

PROC PRINT DATA = pca_trans_test_em;
RUN; QUIT;

DATA pca_trans_test_ov;
	SET pca_trans_test;
	OV = abs(((yhat-TEST_&response._LN)/TEST_&response._LN));
	Prediction_Grade = put(OV, Prediction_Grade.);
	IF Prediction_Grade = 'Missing' then DELETE;
RUN; QUIT;

PROC FREQ DATA = pca_trans_test_ov;
	TABLES Prediction_Grade;
	TITLE1 'Operational Validation of &response.';
RUN; QUIT;

ODS TRACE OFF;