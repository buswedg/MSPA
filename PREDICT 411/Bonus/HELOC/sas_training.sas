* Set variables / global macros;

%LET key = INDEX;
%LET response = TARGET_FLAG;
%LET varname = name;

%LET data = heloc;
%LET contents = &data._contents;



* Load the dataset;

libname mydata '/sscc/home/d/dgb2583/411/' access = readonly;

DATA &data.;
	SET mydata.heloc;
	*SET mydata.heloc_test;
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

DATA _null_;
	DO i = 1 to NUM;
		SET &contents._name NOBS = NUM;
			WHERE type = 2;
				CALL EXECUTE('%rename_cat('||name||')');
	END;
RUN; QUIT;

PROC MEANS DATA = &data._name MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;

PROC CONTENTS DATA = &data._name OUT = &contents._name;
RUN; QUIT;



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
				*&varname._P90OF = 1.0; *ELSE &varname._P90OF = 0.0;
			
			IF (&varname. < &&&varname._P5) OR (&varname. > &&&varname._P95) THEN
				&varname._OF = 1.0; ELSE &varname._OF = 0.0;
			
			*IF (&varname. < &&&varname._P1) OR (&varname. > &&&varname._P99) THEN
				*&varname._P99OF = 1.0; *ELSE &varname._P99OF = 0.0;
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
			&varname._IMU = &varname.;
			IF missing(&varname._IMU) THEN
				&varname._IMU = &&&varname._mean;
			
			*&varname._IMO = &varname.;
			*IF missing(&varname._IMO) THEN
				*&varname._IMO = &&&varname._mode;
			
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

* Create new dataset of flags for continuous variables;

DATA &data._flag;
	SET &data._name;
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

* Add trimmed series to original dataset;

DATA &data._trim;
	SET &data._name;
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
	MERGE &data._flag &data._trans;
	*DROP where TYPE _CHARACTER_;
RUN; QUIT;

PROC CONTENTS DATA = &data._merged OUT = &contents._merged;
RUN; QUIT;
	
PROC MEANS DATA = &data._merged MIN P5 P50 P90 P95 P99 MAX MEAN STDDEV NMISS N;
RUN; QUIT;



* AVS: Stepwise Selection;

PROC LOGISTIC DATA = &data._merged
plot(LABEL) = (roc(ID = prob) EFFECT influence(UNPACK)) plots(MAXPOINTS = none);
CLASS 	C_:
		/ PARAM = ref;
MODEL &response.(ref = "0") =
	C_:
	N_:
	/ SELECTION = stepwise SLENTRY = 0.02 SLSTAY = 0.02 RSQUARE LACKFIT ROCEPS = 0.10;
	OUTPUT OUT = ins_sw PREDICTED = yhat;
RUN; QUIT;

PROC LOGISTIC DATA = &data._merged
plot(LABEL) = (roc(ID = prob) EFFECT influence(UNPACK)) plots(MAXPOINTS = none);
CLASS 	
		/ PARAM = ref;
MODEL &response.(ref = "0") =
	N_CLNO_OF
	N_DEBTINC_MF
	N_DEBTINC_OF
	N_CLAGE_IME
	N_DEBTINC_IMU
	N_DELINQ_IME_LN
	N_DEROG_IME_LN
	
	/ RSQUARE LACKFIT ROCEPS = 0.10;
	OUTPUT OUT = ins_sw PREDICTED = P_TARGET_FLAG;
RUN; QUIT;


PROC NPAR1WAY DATA = ins_sw EDF;
	CLASS &response.;
	VAR P_TARGET_FLAG;
RUN; QUIT;

DATA ins_sw (KEEP = INDEX TARGET_FLAG P_TARGET_FLAG);
	SET ins_sw;
RUN; QUIT;