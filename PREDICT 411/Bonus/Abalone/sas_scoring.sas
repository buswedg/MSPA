* Set variables / global macros;

%LET key = INDEX;
%LET response = TARGET_RINGS;
%LET varname = name;

%LET data = abalone;
%LET contents = &data._contents;



* Load the dataset;

libname mydata '/sscc/home/d/dgb2583/411/' access = readonly;

DATA &data.;
	SET mydata.zip_abalone;
	*SET mydata.zip_abalone_test;
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
	SET &data.
		(RENAME = (ShellWeight 	= ShellW
				   ShuckedWeight = ShuckW
				   VisceraWeight = ViscW
				   WholeWeight = WeigW));
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



* Testing;

DATA &data._scored (KEEP = INDEX P_TARGET_RINGS);
	SET &data._merged;

	P_TARGET_RINGS = -0.226167 +
	(N_Diameter_OF   *   0.090406)   +
	(N_Height_OF   *   -0.896664)   +
	(N_Diameter_T99_IME   *   -35.584744)   +
	(N_Height_IMU   *   -26.022619)   +
	(N_Height_T90_IMU   *   -3.062586)   +
	(N_Height_T95_IMU   *   -232.854184)   +
	(N_Length_IMU   *   30.5971)   +
	(N_ShuckW_IMU   *   7.936933)   +
	(N_ViscW_IMU   *   -10.400258)   +
	(N_WeigW_IMU   *   -2.538335)   +
	(N_Diameter_T99_IME_LN   *   53.337939)   +
	(N_Height_IME_LN   *   42.449862)   +
	(N_Height_T95_IME_LN   *   260.35197)   +
	(N_Length_IME_LN   *   -48.349253)   +
	(N_Length_T90_IME_LN   *   24.797249)   +
	(N_Length_T90_IMU_LN   *   -22.700775)   +
	(N_Length_T95_IME_LN   *   0.756645)   +
	(N_Length_T99_IME_LN   *   -59.401646)   +
	(N_Length_T99_IMU_LN   *   54.669974)   +
	(N_ShellW_IME_LN   *   1.733432)   +
	(N_ShellW_T90_IME_LN   *   -2555.610024)   +
	(N_ShellW_T90_IMU_LN   *   2553.520303)   +
	(N_ShellW_T95_IMU_LN   *   0.597088)   +
	(N_ShuckW_IME_LN   *   -17.00034)   +
	(N_ShuckW_T99_IME_LN   *   -42.160038)   +
	(N_ShuckW_T99_IMU_LN   *   43.961975)   +
	(N_ViscW_IME_LN   *   15.177721)   +
	(N_ViscW_T90_IME_LN   *   187.878576)   +
	(N_ViscW_T90_IMU_LN   *   -191.629655)   +
	(N_WeigW_IME_LN   *   8.027461);

	P_TARGET_RINGS = EXP(P_TARGET_RINGS);
	P_TARGET_RINGS = ROUND(P_TARGET_RINGS, 1);

RUN; QUIT;

PROC PRINT DATA = &data._scored;
RUN; QUIT;

PROC EXPORT DATA = &data._scored
    OUTFILE = '/sscc/home/d/dgb2583/411/out.csv'
    DBMS = csv
    REPLACE;
RUN; QUIT;

DATA '/sscc/home/d/dgb2583/411/out';
	SET &data._scored;
RUN; QUIT;