* Set variables / global macros;

%LET key = INDEX;
%LET response = TARGET_WINS;
%LET varname = name;

%LET data = moneyball_train;
%LET contents = &data._contents;



* Load the dataset;

libname mydata '/sscc/home/d/dgb2583/411/';

DATA &data.;
*	SET mydata.moneyball;
	SET mydata.moneyball_test;
RUN; QUIT;

PROC CONTENTS DATA = &data. OUT = &contents.;
RUN; QUIT;

*PROC PRINT DATA = &contents. (OBS=20);
*RUN; QUIT;



* Data exploration;



* Data correlations;



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



* Data correlations;



* Regression / PCA / Prediction;

* Prediction;

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
	MERGE &data._flag &data._trans &data._pca_out;
	RUN; QUIT;

PROC CONTENTS DATA = &data._merged OUT = &contents._merged;
RUN; QUIT;
	
PROC MEANS DATA = &data._merged MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;


ODS TRACE ON;

* Manual - Predict Response;

DATA &data._scored;
	SET &data._merged;
	P_TARGET_WINS =
	((80.64409) +
	((0.24426) * Prin1) +
	((1.74522) * Prin2) +
	((1.449) * Prin3) +
	((1.19577) * Prin4) +
	((0.01219) * Prin5) +
	((-2.26033) * Prin6) +
	((0.54104) * Prin7) +
	((-1.3535) * Prin8) +
	((2.1215) * Prin9) +
	((-0.27843) * Prin10) +
	((-0.10821) * Prin11) +
	((-1.41118) * Prin12) +
	((-1.17669) * Prin13) +
	((-1.6239) * Prin14) +
	((-0.9432) * Prin15));
RUN; QUIT;

DATA &data._scored_trunc;
	SET &data._scored (KEEP = &key. P_TARGET_WINS);
	P_TARGET_WINS = max(min(P_TARGET_WINS, 120), 30);
RUN; QUIT;

DATA &data._scored_trunc;
	SET &data._scored_trunc;
	P_TARGET_WINS = ROUND(P_TARGET_WINS, 1);
RUN; QUIT;

PROC MEANS DATA = &data._scored_trunc NOLABELS
    NMISS N MEAN MODE STD SKEW
    P1 P5 P10 P25 P50 P75 P90 P95 P99 MIN MAX QRANGE;
RUN; QUIT;

PROC PRINT DATA = &data._scored_trunc;
RUN; QUIT;

PROC EXPORT DATA = &data._scored_trunc
    OUTFILE = '/sscc/home/d/dgb2583/411/out.csv'
    DBMS = csv
    REPLACE;
RUN; QUIT;

DATA '/sscc/home/d/dgb2583/411/out';
	SET &data._scored_trunc;
RUN; QUIT;

ODS TRACE OFF;