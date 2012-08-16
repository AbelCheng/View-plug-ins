CREATE OR REPLACE PACKAGE VPI.EXTRACT_UTILITY IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://view.codeplex.com
--	Created Date:		2012-07-21
--	Purpose:			View-plug-ins Utilities

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


FUNCTION CREATE_BATCH
(
	inService_ID	VARCHAR2
)	RETURN			PLS_INTEGER;


FUNCTION CURRENT_BATCH_ID
RETURN PLS_INTEGER;


PROCEDURE SET_CURRENT_BATCH_ID
(
	inBatch_ID	PLS_INTEGER
);


PROCEDURE SET_PARAMS
(
	inBatch_ID		PLS_INTEGER	:= CURRENT_BATCH_ID,

	inVar$Date1		DATE		:= NULL,
	inVar$Num1		NUMBER		:= NULL,
	inVar$Str1		VARCHAR2	:= NULL,
	inVar$Str2		VARCHAR2	:= NULL,
	inVar$Str3		VARCHAR2	:= NULL,
	inVar$Str4		VARCHAR2	:= NULL,
	inVar$Str5		VARCHAR2	:= NULL,
	inVar$Str6		VARCHAR2	:= NULL,
	inVar$Str7		VARCHAR2	:= NULL,
	inVar$Str8		VARCHAR2	:= NULL,
	inVar$Str9		VARCHAR2	:= NULL
);


FUNCTION GEN_RULE_VIEW
(
	inInterface_Id	VARCHAR2
)	RETURN CLOB;


FUNCTION GEN_EXTRACT_VIEW
(
	inInterface_Id	VARCHAR2
)	RETURN CLOB;


PROCEDURE PROGRESS_START
(
	inTotal_Steps			PLS_INTEGER,
	inProgress_Step			PLS_INTEGER	:= 1,
	inProgress_Description	VARCHAR2	:= '',

	inBatch_ID				PLS_INTEGER	:= CURRENT_BATCH_ID
);


PROCEDURE PROGRESS_UPDATE
(
	inProgress_Step			PLS_INTEGER	:= NULL,	-- Move forward one step.
	inProgress_Description	VARCHAR2	:= '',

	inBatch_ID				PLS_INTEGER	:= CURRENT_BATCH_ID
);


-- This procedure will be called by UI to get current progress, it's outside the running session.
-- So the UI should keep the inBatch_ID locally.
PROCEDURE POLLING_PROGRESS
(
	inBatch_ID				PLS_INTEGER,

	outTotal_Steps			OUT NUMBER,
	outElapsed_Time			OUT NUMBER,
	outCurrent_Step			OUT NUMBER,
	outCurrent_Procedure	OUT VARCHAR2
);


END EXTRACT_UTILITY;
/
CREATE OR REPLACE PACKAGE BODY VPI.EXTRACT_UTILITY IS

gCurrent_Batch_ID	PLS_INTEGER	:= -1;


FUNCTION CREATE_BATCH
(
	inService_ID	VARCHAR2
)	RETURN			PLS_INTEGER
IS
tBatch_ID			PLS_INTEGER	:= VPI.SEQ_BATCH_ID.NEXTVAL;
BEGIN
	INSERT INTO VPI.EXTRACT_BATCH (BATCH_ID, SERVICE_ID)
	VALUES (tBatch_ID, inService_ID);

	INSERT INTO EXTRACT_BATCH_PROGRESS (BATCH_ID, CREATED_TIME)
	VALUES (tBatch_ID, SYSTIMESTAMP);

	gCurrent_Batch_ID	:= tBatch_ID;
	RETURN tBatch_ID;
END CREATE_BATCH;


FUNCTION CURRENT_BATCH_ID
RETURN		PLS_INTEGER
IS
BEGIN
	RETURN gCurrent_Batch_ID;
END CURRENT_BATCH_ID;

PROCEDURE SET_CURRENT_BATCH_ID
(
	inBatch_ID	PLS_INTEGER
) IS
BEGIN
	IF gCurrent_Batch_ID <> inBatch_ID THEN
		gCurrent_Batch_ID	:= inBatch_ID;
	END IF;
END SET_CURRENT_BATCH_ID;


PROCEDURE SET_PARAMS
(
	inBatch_ID		PLS_INTEGER	:= CURRENT_BATCH_ID,

	inVar$Date1		DATE		:= NULL,
	inVar$Num1		NUMBER		:= NULL,
	inVar$Str1		VARCHAR2	:= NULL,
	inVar$Str2		VARCHAR2	:= NULL,
	inVar$Str3		VARCHAR2	:= NULL,
	inVar$Str4		VARCHAR2	:= NULL,
	inVar$Str5		VARCHAR2	:= NULL,
	inVar$Str6		VARCHAR2	:= NULL,
	inVar$Str7		VARCHAR2	:= NULL,
	inVar$Str8		VARCHAR2	:= NULL,
	inVar$Str9		VARCHAR2	:= NULL
) IS
BEGIN
	SET_CURRENT_BATCH_ID(inBatch_ID);

	UPDATE VPI.EXTRACT_BATCH
	SET
		VAR$DATE1	= NVL(inVar$Date1,	VAR$DATE1),
		VAR$NUM1	= NVL(inVar$Num1,	VAR$NUM1),
		VAR$STR1	= NVL(inVar$Str1,	VAR$STR1),
		VAR$STR2	= NVL(inVar$Str2,	VAR$STR2),
		VAR$STR3	= NVL(inVar$Str3,	VAR$STR3),
		VAR$STR4	= NVL(inVar$Str4,	VAR$STR4),
		VAR$STR5	= NVL(inVar$Str5,	VAR$STR5),
		VAR$STR6	= NVL(inVar$Str6,	VAR$STR6),
		VAR$STR7	= NVL(inVar$Str7,	VAR$STR7),
		VAR$STR8	= NVL(inVar$Str8,	VAR$STR8),
		VAR$STR9	= NVL(inVar$Str9,	VAR$STR9)
	WHERE
		BATCH_ID	= inBatch_ID;

END SET_PARAMS;


FUNCTION GET_TAG_COLUMN_ALIAS
(
	inInterface_Id	VARCHAR2,
	inTag_Column	VARCHAR2
)	RETURN			VARCHAR2
IS
	tAlias			VARCHAR2(30);
BEGIN
	EXECUTE IMMEDIATE
			UTL_LMS.FORMAT_MESSAGE('SELECT %s FROM VPI.EXTRACT_RULE_TAG_ALIAS WHERE INTERFACE_ID = :1', inTag_Column)
	INTO	tAlias
	USING	inInterface_Id;

	RETURN UPPER(tAlias);
END GET_TAG_COLUMN_ALIAS;


FUNCTION GET_TAG_ALIAS_LIST
(
	inInterface_Id	VARCHAR2
)	RETURN			VARCHAR2
IS
	tAlias			VARCHAR2(30);
	tAsList			VARCHAR2(2000);
BEGIN
	FOR A IN (SELECT COLUMN_NAME FROM SYS.ALL_TAB_COLUMNS WHERE COLUMN_NAME LIKE 'TAG$%' AND TABLE_NAME = 'EXTRACT_RULE_TAG_ALIAS' AND OWNER = 'VPI' ORDER BY COLUMN_ID)
	LOOP
		tAlias	:= GET_TAG_COLUMN_ALIAS(inInterface_Id, A.COLUMN_NAME);
		IF tAlias IS NOT NULL THEN
			IF tAsList IS NOT NULL THEN
				tAsList	:= tAsList || ',
';
			END IF;
			tAsList	:= tAsList || UTL_LMS.FORMAT_MESSAGE('	%s		AS %s', A.COLUMN_NAME, tAlias);
		END IF;
	END LOOP;
	RETURN tAsList;
END GET_TAG_ALIAS_LIST;


FUNCTION GEN_RULE_VIEW
(
	inInterface_Id	VARCHAR2
)	RETURN			CLOB
IS
	tView_Name		VARCHAR2(61);
	tSelect_List	VARCHAR2(2000);
	tView_Code		CLOB	:= 'CREATE OR REPLACE VIEW ';
BEGIN
	SELECT MAX(RULE_VIEW) INTO tView_Name FROM VPI.EXTRACT_RULE_TAG_ALIAS WHERE INTERFACE_ID = inInterface_Id;
	IF tView_Name IS NULL THEN
		RETURN NULL;
	END IF;

	tSelect_List	:= GET_TAG_ALIAS_LIST(inInterface_Id);
	IF tSelect_List IS NULL THEN
		RETURN NULL;
	END IF;

	DBMS_LOB.APPEND(tView_Code, tView_Name || '
AS
SELECT
	RULE_ID,
	PLUGIN_ID,
');
	DBMS_LOB.APPEND(tView_Code, tSelect_List);
	DBMS_LOB.APPEND(tView_Code, UTL_LMS.FORMAT_MESSAGE('
FROM
	VPI.VIEW_EXTRACT_RULE
WHERE
	INTERFACE_ID	= ''%s''
', inInterface_Id));

	RETURN tView_Code;
END GEN_RULE_VIEW;


FUNCTION GEN_EXTRACT_VIEW
(
	inInterface_Id	VARCHAR2
)	RETURN			CLOB
IS
	tView_Name		VARCHAR2(61);
	tSelect_List	VARCHAR2(1024);
	tView_Code		CLOB	:= 'CREATE OR REPLACE VIEW ';
	tCount			PLS_INTEGER	:= 0;
BEGIN
	SELECT	UNION_VIEW, NVL(SELECT_LIST, '*')
	INTO	tView_Name, tSelect_List
	FROM	VPI.EXTRACT_INTERFACE
	WHERE	UNION_VIEW IS NOT NULL AND INTERFACE_ID = inInterface_Id;

	DBMS_LOB.APPEND(tView_Code, UPPER(tView_Name) || '
AS');

	FOR S IN
	(
		SELECT
			P.PLUGIN_VIEW
		FROM
			VPI.EXTRACT_PLUGIN	P
		WHERE
			P.INTERFACE_ID	= inInterface_Id
		ORDER BY
			P.PLUGIN_ORDER
	)
	LOOP
		IF tCount > 0 THEN
			DBMS_LOB.APPEND(tView_Code, '
UNION ALL');
		END IF;

		DBMS_LOB.APPEND(tView_Code, '
SELECT ' || tSelect_List || ' FROM ' || S.PLUGIN_VIEW);

		tCount	:= tCount + 1;
	END LOOP;

	DBMS_LOB.APPEND(tView_Code, '
WITH READ ONLY');
	RETURN tView_Code;
END GEN_EXTRACT_VIEW;


PROCEDURE PROGRESS_START
(
	inTotal_Steps			PLS_INTEGER,
	inProgress_Step			PLS_INTEGER	:= 1,
	inProgress_Description	VARCHAR2	:= '',

	inBatch_ID				PLS_INTEGER	:= CURRENT_BATCH_ID
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	UPDATE	VPI.EXTRACT_BATCH_PROGRESS
	SET
		TOTAL_STEPS		= inTotal_Steps,
		LAST_LOG_TIME	= SYSTIMESTAMP,
		PROGRESS_STEP	= inProgress_Step,
		PROGRESS_DESC	= inProgress_Description
	WHERE
		BATCH_ID		= inBatch_ID;

	INSERT INTO VPI.EXTRACT_BATCH_LOG (BATCH_ID, LOG_TIME, PROGRESS_STEP, PROGRESS_DESC)
	VALUES (inBatch_ID, SYSTIMESTAMP, inProgress_Step, inProgress_Description);

	COMMIT;
END PROGRESS_START;


PROCEDURE PROGRESS_UPDATE
(
	inProgress_Step			PLS_INTEGER	:= NULL,	-- Move forward one step.
	inProgress_Description	VARCHAR2	:= '',

	inBatch_ID				PLS_INTEGER	:= CURRENT_BATCH_ID
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
tProgress_Step	PLS_INTEGER;
BEGIN
	UPDATE	VPI.EXTRACT_BATCH_PROGRESS
	SET
		LAST_LOG_TIME	= SYSTIMESTAMP,
		PROGRESS_STEP	= NVL(inProgress_Step, PROGRESS_STEP + 1),
		PROGRESS_DESC	= inProgress_Description
	WHERE
		BATCH_ID		= inBatch_ID
	RETURNING PROGRESS_STEP INTO tProgress_Step;

	INSERT INTO VPI.EXTRACT_BATCH_LOG (BATCH_ID, LOG_TIME, PROGRESS_STEP, PROGRESS_DESC)
	VALUES (inBatch_ID, SYSTIMESTAMP, tProgress_Step, inProgress_Description);

	COMMIT;
END PROGRESS_UPDATE;


-- This procedure will be called by UI to get current progress, it's outside the running session.
-- So the UI should keep the inBatch_ID locally.
PROCEDURE POLLING_PROGRESS
(
	inBatch_ID				PLS_INTEGER,

	outTotal_Steps			OUT NUMBER,
	outElapsed_Time			OUT NUMBER,
	outCurrent_Step			OUT NUMBER,
	outCurrent_Procedure	OUT VARCHAR2
)
IS
BEGIN
	SELECT
		TOTAL_STEPS, (SYSDATE - CAST(CREATED_TIME AS DATE)) * 86400, PROGRESS_STEP, PROGRESS_DESC
	INTO
		outTotal_Steps, outElapsed_Time, outCurrent_Step, outCurrent_Procedure
	FROM
		VPI.EXTRACT_BATCH_PROGRESS
	WHERE
		BATCH_ID	= inBatch_ID;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		outTotal_Steps			:= 1;
		outElapsed_Time			:= 0;
		outCurrent_Step			:= 0;
		outCurrent_Procedure	:= '';
END POLLING_PROGRESS;


END EXTRACT_UTILITY;
/
