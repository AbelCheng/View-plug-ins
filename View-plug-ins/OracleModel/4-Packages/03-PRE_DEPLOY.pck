CREATE OR REPLACE PACKAGE VPI.PRE_DEPLOY
AUTHID CURRENT_USER IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://view.codeplex.com
--	Created Date:		2012-08-15
--	Purpose:			Pre-deployment Utilities

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


PROCEDURE BUILD_SERVICE
(
	inService_ID	VARCHAR2,
	inComment		VARCHAR2
);


PROCEDURE PUBLISH_SERVICE
(
	inService_ID	VARCHAR2,
	inDrop_Old		VARCHAR2	:= 'N'
);


PROCEDURE BUILD_AND_PUBLISH_SERVICE
(
	inService_ID	VARCHAR2,
	inComment		VARCHAR2,
	inDrop_Old		VARCHAR2	:= 'N'
);


END PRE_DEPLOY;
/
CREATE OR REPLACE PACKAGE BODY VPI.PRE_DEPLOY IS


FUNCTION NEXT_DEPLOY_VERSION
(
	inService_ID	VARCHAR2
)	RETURN			PLS_INTEGER
IS
	tVersion		PLS_INTEGER;
BEGIN
	UPDATE	VPI.EXTRACT_SERVICE
	SET		LATEST_VERSION	= LATEST_VERSION + 1
	WHERE	SERVICE_ID		= inService_ID
	RETURNING LATEST_VERSION	INTO tVersion;

	RETURN	tVersion;
END NEXT_DEPLOY_VERSION;


FUNCTION NEXT_DEPLOY_ORDER
(
	inService_ID	VARCHAR2,
	inVersion		PLS_INTEGER
)	RETURN			PLS_INTEGER
IS
	tOrder			PLS_INTEGER;
BEGIN
	UPDATE	VPI.PRE_DEPLOY_VERSION
	SET		OBJECT_COUNT	= OBJECT_COUNT + 1
	WHERE	VERSION_		= inVersion
		AND	SERVICE_ID		= inService_ID
	RETURNING OBJECT_COUNT	INTO tOrder;

	RETURN	tOrder;
END NEXT_DEPLOY_ORDER;


PROCEDURE ADD_VIEW_SCRIPT
(
	inService_ID	VARCHAR2,
	inVersion		PLS_INTEGER,
	inView_Name		VARCHAR2,
	inView_Script	CLOB
)	AS
	tOrder			PLS_INTEGER;
BEGIN
	IF inView_Name IS NOT NULL AND inView_Script IS NOT NULL THEN
		tOrder	:= NEXT_DEPLOY_ORDER(inService_ID, inVersion);

		INSERT INTO	VPI.PRE_DEPLOY_SCRIPT (SERVICE_ID, VERSION_, OBJECT_NAME, OBJECT_TYPE, OBJECT_SCRIPT, DEPLOY_ORDER, DEPLOY_STATUS)
		VALUES (inService_ID, inVersion, inView_Name, 'VIEW', inView_Script, tOrder, 0);
	END IF;
END ADD_VIEW_SCRIPT;


PROCEDURE BUILD_SERVICE
(
	inService_ID	VARCHAR2,
	inComment		VARCHAR2
)	AS
	tVersion		PLS_INTEGER;
BEGIN
	tVersion	:= NEXT_DEPLOY_VERSION(inService_ID);
	INSERT INTO VPI.PRE_DEPLOY_VERSION (SERVICE_ID, VERSION_, COMMENT_, OBJECT_COUNT, DEPLOY_STATUS)
	VALUES (inService_ID, tVersion, inComment, 0, 0);

	FOR S IN (SELECT INTERFACE_ID, PLUGIN_UNION_VIEW, PLUGIN_UNION_VIEW_CODE, RULE_VIEW, RULE_VIEW_CODE FROM VPI.VIEW_CODE_GENERATION WHERE SERVICE_ID = inService_ID ORDER BY SERVICE_ID)
	LOOP
		ADD_VIEW_SCRIPT(inService_ID, tVersion, S.RULE_VIEW, S.RULE_VIEW_CODE);
		ADD_VIEW_SCRIPT(inService_ID, tVersion, S.PLUGIN_UNION_VIEW, S.PLUGIN_UNION_VIEW_CODE);
	END LOOP;

	COMMIT;
END BUILD_SERVICE;


FUNCTION EXECUTE_IMMEDIATE
(
	inSQL	CLOB
)	RETURN	VARCHAR2
IS
BEGIN
	EXECUTE IMMEDIATE inSQL;
	RETURN NULL;
EXCEPTION
	WHEN OTHERS THEN
		RETURN SQLERRM;
END EXECUTE_IMMEDIATE;


PROCEDURE DROP_DEPLOYED_OBJECT
(
	inObject_Name	VARCHAR2,
	inObject_Type	VARCHAR2
)	AS
	tDrop_SQL		VARCHAR2(128)	:= UTL_LMS.FORMAT_MESSAGE('DROP %s %s', inObject_Type, inObject_Name);
	tError_Msg		VARCHAR(512);
BEGIN
	tError_Msg	:= EXECUTE_IMMEDIATE(tDrop_SQL);

	DBMS_OUTPUT.PUT_LINE(tDrop_SQL);

	IF tError_Msg IS NOT NULL THEN
		DBMS_OUTPUT.PUT_LINE(tError_Msg);
	END IF;
END DROP_DEPLOYED_OBJECT;


PROCEDURE PUBLISH_SERVICE
(
	inService_ID		VARCHAR2,
	inDrop_Old			VARCHAR2	:= 'N'
)	AS
	tLatest_Version		PLS_INTEGER;
	tPrevious_Version	PLS_INTEGER;
	tDeploy_Status		PLS_INTEGER;
	tObject_Count		PLS_INTEGER;
	tSucceeded_Count	PLS_INTEGER	:= 0;
	tFailed_Count		PLS_INTEGER	:= 0;
	tError_Msg			VARCHAR2(512);
BEGIN
	SELECT LATEST_VERSION INTO tLatest_Version FROM VPI.EXTRACT_SERVICE WHERE SERVICE_ID = inService_ID;
	IF tLatest_Version <= 0 THEN
		DBMS_OUTPUT.PUT_LINE('The service has not been built yet!');
		RETURN;
	END IF;

	SELECT	OBJECT_COUNT, DEPLOY_STATUS INTO tObject_Count, tDeploy_Status
	FROM	VPI.PRE_DEPLOY_VERSION
	WHERE	VERSION_	= tLatest_Version
		AND	SERVICE_ID	= inService_ID;

	IF tDeploy_Status != 0 THEN
		DBMS_OUTPUT.PUT_LINE('The latest version of the service has already been deployed!');
		RETURN;
	END IF;

	IF tObject_Count = 0 THEN
		DBMS_OUTPUT.PUT_LINE('There is no object in the latest version of the service to deploy!');
		RETURN;
	END IF;

	SELECT	MAX(VERSION_) INTO tPrevious_Version
	FROM	VPI.PRE_DEPLOY_VERSION
	WHERE	DEPLOY_STATUS	!= 0
		AND	OBJECT_COUNT	> 0
		AND	VERSION_		< tLatest_Version
		AND	SERVICE_ID		= inService_ID;

	IF tPrevious_Version > 0 AND UPPER(inDrop_Old) = 'Y' THEN
		FOR P IN (SELECT OBJECT_NAME, OBJECT_TYPE FROM VPI.PRE_DEPLOY_SCRIPT WHERE DEPLOY_STATUS != 0 AND VERSION_ = tPrevious_Version AND SERVICE_ID = inService_ID ORDER BY DEPLOY_ORDER DESC)
		LOOP
			DROP_DEPLOYED_OBJECT(P.OBJECT_NAME, P.OBJECT_TYPE);
		END LOOP;

		DBMS_OUTPUT.PUT_LINE(UTL_LMS.FORMAT_MESSAGE('--- Objects of previous version(%d) have been dropped ---
', tPrevious_Version));
	END IF;

	FOR L IN (SELECT OBJECT_NAME, OBJECT_SCRIPT FROM VPI.PRE_DEPLOY_SCRIPT WHERE DEPLOY_STATUS = 0 AND VERSION_ = tLatest_Version AND SERVICE_ID = inService_ID ORDER BY DEPLOY_ORDER)
	LOOP
		tError_Msg	:= EXECUTE_IMMEDIATE(L.OBJECT_SCRIPT);

		UPDATE	VPI.PRE_DEPLOY_SCRIPT
		SET		DEPLOY_ERROR	= tError_Msg,
				DEPLOY_STATUS	= NVL2(tError_Msg, -1, 1)
		WHERE	OBJECT_NAME		= L.OBJECT_NAME
			AND	VERSION_		= tLatest_Version
			AND	SERVICE_ID		= inService_ID;

		DBMS_OUTPUT.PUT_LINE(L.OBJECT_NAME);

		IF tError_Msg IS NULL THEN
			tSucceeded_Count	:= tSucceeded_Count + 1;
			DBMS_OUTPUT.PUT_LINE('Created.');
		ELSE
			tFailed_Count		:= tFailed_Count + 1;
			DBMS_OUTPUT.PUT_LINE(tError_Msg);
		END IF;
	END LOOP;

	UPDATE	VPI.PRE_DEPLOY_VERSION
	SET		DEPLOY_DATE		= SYSDATE,
			DEPLOY_STATUS	= DECODE(tFailed_Count, 0, 1, -1)
	WHERE	VERSION_		= tLatest_Version
		AND	SERVICE_ID		= inService_ID;

	COMMIT;
	DBMS_OUTPUT.PUT_LINE(UTL_LMS.FORMAT_MESSAGE('========== Pre-deployed: %d succeeded, %d failed ==========', tSucceeded_Count, tFailed_Count));
END PUBLISH_SERVICE;


PROCEDURE BUILD_AND_PUBLISH_SERVICE
(
	inService_ID	VARCHAR2,
	inComment		VARCHAR2,
	inDrop_Old		VARCHAR2	:= 'N'
)	AS
BEGIN
	BUILD_SERVICE(inService_ID, inComment);
	PUBLISH_SERVICE(inService_ID, inDrop_Old);
END BUILD_AND_PUBLISH_SERVICE;


END PRE_DEPLOY;
/
