* Set variables / global macros;

%LET key = INDEX;
%LET response = TARGET;
%LET varname = name;

%LET data = wine;
%LET contents = &data._contents;



* Load the dataset;

libname mydata '/sscc/home/d/dgb2583/411/' access = readonly;

DATA &data.;
	*SET mydata.wine;
	SET mydata.wine_test;
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



* Testing;

DATA &data._scored (KEEP = INDEX P_:);
	SET &data._merged;

	p_target_reg = 1.41942 +
	(N_Alcohol_OF   *   0.09899)   +
	(N_STARS_1   *   1.66956)   +
	(N_STARS_GTE2   *   2.38672)   +
	(N_LabelAppeal_5   *   0.13799)   +
	(N_AcidIndex_IME   *   -0.12299)   +
	(N_AcidIndex_T99_IME   *   -0.58704)   +
	(N_Alcohol_IME   *   0.00733)   +
	(N_Alcohol_T90_IME   *   0.1616)   +
	(N_Chlorides_IME   *   -0.12143)   +
	(N_Density_T90_IME   *   -2.22961)   +
	(N_FreSulfDiox_T99_IME   *   0.00030222)   +
	(N_LabelAppeal_IME   *   0.45554)   +
	(N_STARS_IME   *   1.14507)   +
	(N_Sulphates_IME   *   -0.03011)   +
	(N_TotSulfDiox_IME   *   0.00021852)   +
	(N_VolAcid_IME   *   -0.09513)   +
	(N_pH_T90_IME   *   -0.13897)   +
	(N_AcidIndex_T99_IME_LN   *   4.60162)   +
	(N_Alcohol_T90_IME_LN   *   -1.51042)   +
	(N_CitricAcid_T90_IME_LN   *   0.11136)   +
	(N_STARS_IME_LN   *   -2.04254);
	
	p_target_reg = ROUND(p_target_reg, 1);
	

	p_target_poi = -0.2487 +
	(N_STARS_GTE2   *   1.0737)   +
	((N_AcidIndex_IME  in (4)) *   1.2052)   +
	((N_AcidIndex_IME  in (5)) *   1.0712)   +
	((N_AcidIndex_IME  in (6)) *   1.1071)   +
	((N_AcidIndex_IME  in (7)) *   1.0711)   +
	((N_AcidIndex_IME  in (8)) *   1.0392)   +
	((N_AcidIndex_IME  in (9)) *   0.9271)   +
	((N_AcidIndex_IME  in (10)) *   0.7725)   +
	((N_AcidIndex_IME  in (11)) *   0.4052)   +
	((N_AcidIndex_IME  in (12)) *   0.3936)   +
	((N_AcidIndex_IME  in (13)) *   0.5515)   +
	((N_AcidIndex_IME  in (14)) *   0.4552)   +
	((N_AcidIndex_IME  in (15)) *   0.8889)   +
	((N_AcidIndex_IME  in (16)) *   0.2454)   +
	((N_AcidIndex_IME  in (17)) *   0)   +
	(N_Alcohol_T90_IME   *   0.0108)   +
	(N_Chlorides_IME   *   -0.0383)   +
	((N_LabelAppeal_IME  in (-2)) *   -0.6994)   +
	((N_LabelAppeal_IME  in (-1)) *   -0.4574)   +
	((N_LabelAppeal_IME  in (0)) *   -0.2679)   +
	((N_LabelAppeal_IME  in (1)) *   -0.1348)   +
	((N_LabelAppeal_IME  in (2)) *   0)   +
	((N_STARS_IME  in (1)) *   0.5163)   +
	((N_STARS_IME  in (2)) *   -0.2394)   +
	((N_STARS_IME  in (3)) *   -0.1221)   +
	((N_STARS_IME  in (4)) *   0)   +
	(N_TotSulfDiox_IME   *   0.0001)   +
	(N_VolAcid_IME   *   -0.0291)   +
	(N_pH_T90_IME   *   -0.043)   +
	(N_CitricAcid_T90_IME   *   0.0261)   +
	(N_FreSulfDiox_IME_LN   *   0.0034);
	
	p_target_poi = EXP(p_target_poi);
	p_target_poi = ROUND(p_target_poi, 1);
	
	
	p_target_nb = -0.2487 +
	(N_STARS_GTE2   *   1.0737)   +
	((N_AcidIndex_IME  in (4)) *   1.2052)   +
	((N_AcidIndex_IME  in (5)) *   1.0712)   +
	((N_AcidIndex_IME  in (6)) *   1.1071)   +
	((N_AcidIndex_IME  in (7)) *   1.0711)   +
	((N_AcidIndex_IME  in (8)) *   1.0392)   +
	((N_AcidIndex_IME  in (9)) *   0.9271)   +
	((N_AcidIndex_IME  in (10)) *   0.7725)   +
	((N_AcidIndex_IME  in (11)) *   0.4052)   +
	((N_AcidIndex_IME  in (12)) *   0.3936)   +
	((N_AcidIndex_IME  in (13)) *   0.5515)   +
	((N_AcidIndex_IME  in (14)) *   0.4552)   +
	((N_AcidIndex_IME  in (15)) *   0.8889)   +
	((N_AcidIndex_IME  in (16)) *   0.2454)   +
	((N_AcidIndex_IME  in (17)) *   0)   +
	(N_Alcohol_T90_IME   *   0.0108)   +
	(N_Chlorides_IME   *   -0.0383)   +
	((N_LabelAppeal_IME  in (-2)) *   -0.6994)   +
	((N_LabelAppeal_IME  in (-1)) *   -0.4574)   +
	((N_LabelAppeal_IME  in (0)) *   -0.2679)   +
	((N_LabelAppeal_IME  in (1)) *   -0.1348)   +
	((N_LabelAppeal_IME  in (2)) *   0)   +
	((N_STARS_IME  in (1)) *   0.5163)   +
	((N_STARS_IME  in (2)) *   -0.2394)   +
	((N_STARS_IME  in (3)) *   -0.1221)   +
	((N_STARS_IME  in (4)) *   0)   +
	(N_TotSulfDiox_IME   *   0.0001)   +
	(N_VolAcid_IME   *   -0.0291)   +
	(N_pH_T90_IME   *   -0.043)   +
	(N_CitricAcid_T90_IME   *   0.0261)   +
	(N_FreSulfDiox_IME_LN   *   0.0034);
	
	p_target_nb = EXP(p_target_nb);
	p_target_nb = ROUND(p_target_nb, 1);
	
	
	p_target_zip_all = 1.4688 +
	(N_STARS_GTE2   *   0.4752)   +
	(N_AcidIndex_T95_IME   *   -0.0249)   +
	(N_Alcohol_IME   *   0.0041)   +
	(N_Alcohol_T90_IME   *   0.0095)   +
	((N_LabelAppeal_IME  in (-2)) *   -1.0236)   +
	((N_LabelAppeal_IME  in (-1)) *   -0.6331)   +
	((N_LabelAppeal_IME  in (0)) *   -0.3518)   +
	((N_LabelAppeal_IME  in (1)) *   -0.1637)   +
	((N_LabelAppeal_IME  in (2)) *   0)   +
	((N_STARS_IME  in (1)) *   0.1579)   +
	((N_STARS_IME  in (2)) *   -0.1822)   +
	((N_STARS_IME  in (3)) *   -0.099)   +
	((N_STARS_IME  in (4)) *   0)   +
	(N_VolAcid_IME   *   -0.018);

	p_target_zip_zero = -4.394 +
	((N_STARS_IME  in (1)) *   18.2319)   +
	((N_STARS_IME  in (2)) *   18.5193)   +
	((N_STARS_IME  in (3)) *   -7.4969)   +
	((N_STARS_IME  in (4)) *   0)   +
	((N_LabelAppeal_IME  in (-2)) *   -2.8423)   +
	((N_LabelAppeal_IME  in (-1)) *   -1.4548)   +
	((N_LabelAppeal_IME  in (0)) *   -0.8331)   +
	((N_LabelAppeal_IME  in (1)) *   -0.4174)   +
	((N_LabelAppeal_IME  in (2)) *   0)   +
	((N_AcidIndex_IME  in (4)) *   -13.7932)   +
	((N_AcidIndex_IME  in (5)) *   -15.3206)   +
	((N_AcidIndex_IME  in (6)) *   -15.0953)   +
	((N_AcidIndex_IME  in (7)) *   -15.032)   +
	((N_AcidIndex_IME  in (8)) *   -14.703)   +
	((N_AcidIndex_IME  in (9)) *   -14.0103)   +
	((N_AcidIndex_IME  in (10)) *   -13.331)   +
	((N_AcidIndex_IME  in (11)) *   -12.3995)   +
	((N_AcidIndex_IME  in (12)) *   -12.072)   +
	((N_AcidIndex_IME  in (13)) *   -12.4809)   +
	((N_AcidIndex_IME  in (14)) *   -12.1375)   +
	((N_AcidIndex_IME  in (15)) *   -13.3732)   +
	((N_AcidIndex_IME  in (16)) *   0.3679)   +
	((N_AcidIndex_IME  in (17)) *   0);
	
	p_target_zip_all = EXP(p_target_zip_all);
	p_target_zip_zero = EXP(p_target_zip_zero) / (1 + EXP(p_target_zip_zero));
	p_target_zip = p_target_zip_all * (1 - p_target_zip_zero);
	p_target_zip = ROUND(p_target_zip, 1);
	DROP p_target_zip_all p_target_zip_zero;


	p_target_zinb_all = 1.4629 +
	(N_STARS_GTE2   *   0.4813)   +
	(N_AcidIndex_T95_IME   *   -0.0249)   +
	(N_Alcohol_IME   *   0.0042)   +
	(N_Alcohol_T90_IME   *   0.0094)   +
	((N_LabelAppeal_IME  in (-2)) *   -1.0086)   +
	((N_LabelAppeal_IME  in (-1)) *   -0.6308)   +
	((N_LabelAppeal_IME  in (0)) *   -0.3507)   +
	((N_LabelAppeal_IME  in (1)) *   -0.1633)   +
	((N_LabelAppeal_IME  in (2)) *   0)   +
	((N_STARS_IME  in (1)) *   0.1625)   +
	((N_STARS_IME  in (2)) *   -0.1828)   +
	((N_STARS_IME  in (3)) *   -0.0994)   +
	((N_STARS_IME  in (4)) *   0)   +
	(N_VolAcid_IME   *   -0.0185);
	
	p_target_zinb_zero = -6.8329 +
	((N_STARS_IME  in (1)) *   3.2252)   +
	((N_STARS_IME  in (2)) *   3.521)   +
	((N_STARS_IME  in (3)) *   -0.8452)   +
	((N_STARS_IME  in (4)) *   0)   +
	((N_LabelAppeal_IME  in (-2)) *   -2.3416)   +
	((N_LabelAppeal_IME  in (-1)) *   -1.4016)   +
	((N_LabelAppeal_IME  in (0)) *   -0.7878)   +
	((N_LabelAppeal_IME  in (1)) *   -0.3817)   +
	((N_LabelAppeal_IME  in (2)) *   0)   +
	((N_AcidIndex_IME  in (4)) *   3.8158)   +
	((N_AcidIndex_IME  in (5)) *   2.2842)   +
	((N_AcidIndex_IME  in (6)) *   2.3033)   +
	((N_AcidIndex_IME  in (7)) *   2.3539)   +
	((N_AcidIndex_IME  in (8)) *   2.6837)   +
	((N_AcidIndex_IME  in (9)) *   3.3782)   +
	((N_AcidIndex_IME  in (10)) *   4.0638)   +
	((N_AcidIndex_IME  in (11)) *   4.989)   +
	((N_AcidIndex_IME  in (12)) *   5.2714)   +
	((N_AcidIndex_IME  in (13)) *   4.9162)   +
	((N_AcidIndex_IME  in (14)) *   5.2288)   +
	((N_AcidIndex_IME  in (15)) *   4.2238)   +
	((N_AcidIndex_IME  in (16)) *   4.3348)   +
	((N_AcidIndex_IME  in (17)) *   0);

	p_target_zinb_all = EXP(p_target_zinb_all);
	p_target_zinb_zero = EXP(p_target_zinb_zero) / (1 + EXP(p_target_zinb_zero));
	p_target_zinb = p_target_zinb_all * (1 - p_target_zinb_zero);
	p_target_zinb = ROUND(p_target_zinb, 1);
	DROP p_target_zinb_all p_target_zinb_zero;
	
RUN; QUIT;

PROC PRINT DATA = &data._scored (OBS = 20);
RUN; QUIT;

PROC EXPORT DATA = &data._scored
    OUTFILE = '/sscc/home/d/dgb2583/411/out.csv'
    DBMS = csv
    REPLACE;
RUN; QUIT;

DATA '/sscc/home/d/dgb2583/411/out';
	SET &data._scored;
RUN; QUIT;