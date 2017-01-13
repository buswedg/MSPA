* Set variables / global macros;

%LET key = INDEX;
%LET response = TARGET;
%LET varname = name;

%LET data = wine;
%LET contents = &data._contents;



* Load the dataset;

libname mydata '/sscc/home/d/dgb2583/411/' access = readonly;

DATA &data.;
	SET mydata.wine;
	*SET mydata.wine_test;
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

TITLE1 '';
TITLE2 '';

DATA &data._name;
	SET &data.
		(RENAME = (TotalSulfurDioxide 	= TotSulfDiox
				   FreeSulfurDioxide 	= FreSulfDiox
				   ResidualSugar 		= ResSugar
				   VolatileAcidity 		= VolAcid));
RUN; QUIT;

PROC CONTENTS DATA = &data._name OUT = &contents._name;
RUN; QUIT;

DATA &contents._name;
	SET &contents._name;
		IF name = "&key." then DELETE;
		IF name = "&response." then DELETE;
RUN; QUIT;

%LET data_def = &data._name;

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._name NOBS = NUM;
			WHERE type = 1;
				CALL EXECUTE('%rename_num('||name||')');
	END;
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
		TITLE1 "Scatter Plot: &response. vs. &varname.";
		TITLE2 "with LOESS smoother";
		COMPARE y = &response. x = &varname. / LOESS REG;
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
			IF (&varname._T90 < &&&varname._P10) OR (&varname._T90 > &&&varname._P90) THEN
				&varname._T90 = '.';
			
			&varname._T95 = &varname.;
			*&varname._T95 = max(min(&varname.,&&&varname._P95),&&&varname._P5);
			IF (&varname._T95 < &&&varname._P5) OR (&varname._T95 > &&&varname._P95) THEN
				&varname._T95 = '.';
			
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

* Create new dataset of flags for continuous variables;

DATA &data._flag;
	SET &data._clean;
RUN; QUIT;

PROC CONTENTS DATA = &data._flag OUT = &contents._flag;
RUN; QUIT;

DATA &contents._flag;
	SET &contents._flag;
		IF name = "&key." then DELETE;
		IF name = "&response." then DELETE;
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
		IF name = "&response." then DELETE;
RUN; QUIT;

DATA &data._dum;
	SET &data._dum;	
		N_STARS_0		=	(0.0 <= N_STARS < 0.5);
		N_STARS_1		=	(0.5 <= N_STARS < 1.5);
		N_STARS_2		=	(1.5 <= N_STARS < 2.5);
		N_STARS_3		=	(2.5 <= N_STARS < 3.5);
		N_STARS_4		=	(3.5 <= N_STARS <= 4.0);
		N_STARS_GTE2	=	(1.5 <=	N_STARS <= 4.0);
		N_STARS_GTE3	=	(2.5 <= N_STARS <= 4.0);
		
		N_LabelAppeal_1		=	(-2.0 <= N_LabelAppeal < -1.5);
		N_LabelAppeal_2		=	(-1.5 <= N_LabelAppeal < -0.5);
		N_LabelAppeal_3		=	(-0.5 <= N_LabelAppeal < 0.5);
		N_LabelAppeal_4		=	(0.5 <= N_LabelAppeal < 1.5);
		N_LabelAppeal_5		=	(1.5 <= N_LabelAppeal <= 2.0);
		N_LabelAppeal_GTE3	=	(-0.5 <= N_LabelAppeal <= 2.0);
		N_LabelAppeal_GTE4	=	(0.5 <= N_LabelAppeal <= 2.0);
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
		IF name = "&response." then DELETE;
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
		IF name = "&response." then DELETE;
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
		IF name = "&response." then DELETE;
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
	&response._FLAG	= (&response. > 0);
	&response._AMT 	= (&response. - 1);
	IF &response._FLAG = 0 then &response._AMT = .;
RUN; QUIT;

PROC CONTENTS DATA = &data._merged OUT = &contents._merged;
RUN; QUIT;
	
PROC MEANS DATA = &data._merged MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;



* Linear;

* AVS: Stepwise Selection;

*PROC REG DATA = &data._merged;
*	MODEL &response. = 
	
	N_:
	
	/ SELECTION = stepwise SLENTRY = 0.10 SLSTAY = 0.10 VIF;
*	OUTPUT OUT = lin_sw PREDICTED = yhat_lin RESIDUAL = res_lin;
*RUN; QUIT;

*PROC REG DATA = &data._merged;
*	MODEL &response. = 

	N_Alcohol_OF
	N_STARS_1
	N_STARS_GTE2
	N_LabelAppeal_5
	N_AcidIndex_IME
	N_AcidIndex_T99_IME
	N_Alcohol_IME
	N_Alcohol_T90_IME
	N_Chlorides_IME
	N_Density_T90_IME
	N_FreSulfDiox_T99_IME
	N_LabelAppeal_IME
	N_STARS_IME
	N_Sulphates_IME
	N_TotSulfDiox_IME
	N_VolAcid_IME
	N_pH_T90_IME
	N_AcidIndex_T99_IME_LN
	N_Alcohol_T90_IME_LN
	N_CitricAcid_T90_IME_LN
	N_STARS_IME_LN
	
	/ SELECTION = adjrsq START = 21 STOP = 21 MSE ADJRSQ AIC BIC CP VIF;
*	OUTPUT OUT = lin_sw PREDICTED = yhat_lin RESIDUAL = res_lin;
*RUN; QUIT;

*DATA lin_sw_res;
*	SET lin_sw;
*	abs_res = abs(res_lin);
*	square_res = (res_lin**2);
*RUN; QUIT;

*PROC MEANS DATA = lin_sw_res;
*	VAR abs_res square_res;
*	OUTPUT out = lin_sw_em
*	mean(abs_res) = MAE
*	mean(square_res) = MSE;
*RUN; QUIT;

*PROC PRINT DATA = lin_sw_em;
*RUN; QUIT;


* Poisson;

* AVS: Stepwise;

*PROC HPGENSELECT DATA = &data._merged;
*CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME;
*MODEL &response. =

	N_:
	
	/ LINK = log DIST = poisson;
*	SELECTION METHOD = stepwise DETAILS = all;
*	ID _all_;
*	OUTPUT OUT = poisson_sw PREDICTED = yhat_poisson;
*RUN; QUIT;

PROC GENMOD DATA = &data._merged;
CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME;
MODEL &response. =
	
	N_STARS_GTE2
	N_AcidIndex_IME
	N_Alcohol_T90_IME
	N_Chlorides_IME
	N_LabelAppeal_IME
	N_STARS_IME
	N_TotSulfDiox_IME
	N_VolAcid_IME
	N_pH_T90_IME
	N_CitricAcid_T90_IME
	N_FreSulfDiox_IME_LN
	
	/ LINK = log DIST = poisson;
	OUTPUT OUT = poisson_sw PREDICTED = yhat_poisson;
RUN; QUIT;


* Negative Binomial;

* AVS: Stepwise;

*PROC HPGENSELECT DATA = &data._merged;
*CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME;
*MODEL &response. =

	N_:
	
	/ LINK = log DIST = nb;
*	SELECTION METHOD = stepwise DETAILS = all;
*	ID _all_;
*	OUTPUT OUT = nb_sw PREDICTED = yhat_nb;
*RUN; QUIT;

PROC GENMOD DATA = &data._merged;
CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME;
MODEL &response. =
	
	N_STARS_GTE2
	N_AcidIndex_IME
	N_Alcohol_T90_IME
	N_Chlorides_IME
	N_LabelAppeal_IME
	N_STARS_IME
	N_TotSulfDiox_IME
	N_VolAcid_IME
	N_pH_T90_IME
	N_CitricAcid_T90_IME
	N_FreSulfDiox_IME_LN
	
	/ LINK = log DIST = nb;
	OUTPUT OUT = nb_sw PREDICTED = yhat_nb;
RUN; QUIT;


* Zero Inflated Poisson;

* AVS: Stepwise;

*PROC HPGENSELECT DATA = &data._merged;
*CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME
		/ PARAM = REF;
*MODEL &response.(REF = "0") =

	N_:
	
	/ LINK = log DIST = zip;
	
*ZEROMODEL
	
	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME
	
	/ LINK = logit;
*	SELECTION METHOD = stepwise DETAILS = all;
*	ID _all_;
*	OUTPUT OUT = zip_sw PREDICTED = yhat_zip PZERO = yhat_zip_zero;
*RUN; QUIT;

PROC GENMOD DATA = &data._merged;
CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME;
MODEL &response. =

	N_STARS_GTE2
	N_AcidIndex_T95_IME
	N_Alcohol_IME
	N_Alcohol_T90_IME
	N_LabelAppeal_IME
	N_STARS_IME
	N_VolAcid_IME
	
	/ LINK = log DIST = zip;
	
ZEROMODEL

	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME

	/ LINK = logit;
	OUTPUT OUT = zip_sw PREDICTED = yhat_zip PZERO = yhat_zip_zero;
RUN; QUIT;


* Zero Inflated Negative Binomial;

* AVS: Stepwise;

*PROC HPGENSELECT DATA = &data._merged;
*CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME
		/ PARAM = REF;
*MODEL &response.(REF = "0") =

	N_:
	
	/ LINK = log DIST = zinb;

*ZEROMODEL

	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME
	
	/ LINK = logit;
	
*	SELECTION METHOD = stepwise DETAILS = all;
*	ID _all_;
*	OUTPUT OUT = zinb_sw PREDICTED = yhat_zinb PZERO = yhat_zinb_zero;
*RUN; QUIT;

PROC GENMOD DATA = &data._merged;
CLASS 	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME;
MODEL &response. =

	N_STARS_GTE2
	N_AcidIndex_T95_IME
	N_Alcohol_IME
	N_Alcohol_T90_IME
	N_LabelAppeal_IME
	N_STARS_IME
	N_VolAcid_IME
	
	/ LINK = log DIST = zinb;
	
ZEROMODEL

	N_STARS_IME N_LabelAppeal_IME N_AcidIndex_IME

	/ LINK = logit;
	OUTPUT OUT = zinb_sw PREDICTED = yhat_zinb PZERO = yhat_zinb_zero;
RUN; QUIT;