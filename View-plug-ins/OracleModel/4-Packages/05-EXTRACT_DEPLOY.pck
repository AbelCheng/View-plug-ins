CREATE OR REPLACE PACKAGE VPI.EXTRACT_DEPLOY
AUTHID CURRENT_USER IS

----------------------------------------------------------------------------------------------------
--
--	Original Author:	Abel Cheng <abelcys@gmail.com>
--	Primary Host:		http://view.codeplex.com
--	Created Date:		2012-10-06
--	Purpose:			View-plug-ins Metadata Deployment

--	Change Log:
--	Author				Date			Comment
--
--
--
--
----------------------------------------------------------------------------------------------------


FUNCTION EXPORT_METADATA
(
	inService_ID	VARCHAR2
)	RETURN			CLOB;


END EXTRACT_DEPLOY;
/
CREATE OR REPLACE PACKAGE BODY VPI.EXTRACT_DEPLOY IS


FUNCTION EXPORT_METADATA
(
	inService_ID	VARCHAR2
)	RETURN			CLOB
IS
	tManifest			CLOB			:= '-- The Metadata Manifest for Service_ID: ' || inService_ID;
	tFilter_Service		VARCHAR2(64)	:= UTL_LMS.FORMAT_MESSAGE('SERVICE_ID = ''%s''', inService_ID);
	tFilter_Interface	VARCHAR2(128)	:= UTL_LMS.FORMAT_MESSAGE('INTERFACE_ID IN (SELECT INTERFACE_ID FROM VPI.EXTRACT_INTERFACE WHERE SERVICE_ID = ''%s'')', inService_ID);
	tFilter_Plugin		VARCHAR2(256)	:= UTL_LMS.FORMAT_MESSAGE('PLUGIN_ID IN (SELECT P.PLUGIN_ID FROM VPI.EXTRACT_PLUGIN P, VPI.EXTRACT_INTERFACE I WHERE P.INTERFACE_ID = I.INTERFACE_ID AND I.SERVICE_ID = ''%s'')', inService_ID);
BEGIN
	DBMS_LOB.APPEND(tManifest, VPI.DEPLOY_UTILITY.EXPORT_INSERT_SQL('VPI.EXTRACT_SERVICE', tFilter_Service));
	DBMS_LOB.APPEND(tManifest, VPI.DEPLOY_UTILITY.EXPORT_INSERT_SQL('VPI.EXTRACT_INTERFACE', tFilter_Service));
	DBMS_LOB.APPEND(tManifest, VPI.DEPLOY_UTILITY.EXPORT_INSERT_SQL('VPI.EXTRACT_PLUGIN', tFilter_Interface));
	DBMS_LOB.APPEND(tManifest, VPI.DEPLOY_UTILITY.EXPORT_INSERT_SQL('VPI.EXTRACT_RULE', tFilter_Plugin));

	DBMS_LOB.APPEND(tManifest, VPI.DEPLOY_UTILITY.EXPORT_INSERT_SQL('VPI.EXTRACT_RULE_TAG_ALIAS', tFilter_Interface));
	RETURN tManifest;
END EXPORT_METADATA;


END EXTRACT_DEPLOY;
/
