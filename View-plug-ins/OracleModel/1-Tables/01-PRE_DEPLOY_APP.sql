CREATE TABLE VPI.PRE_DEPLOY_APP
(
	APP_ID			VARCHAR2(32)		NOT NULL,
	APP_NAME		VARCHAR2(64)		NOT NULL,
	APP_OWNER		VARCHAR2(32),
	DESCRIPTION_	VARCHAR2(1024),
	LAST_VERSION	NUMBER(4) DEFAULT 0	NOT NULL,

	CONSTRAINT PK_PRE_DEPLOY_APP PRIMARY KEY (APP_ID),
	CONSTRAINT CK_PRE_DEPLOY_APP_ID CHECK (APP_ID = UPPER(APP_ID)),
	CONSTRAINT CK_PRE_DEPLOY_APP_VER CHECK (LAST_VERSION >= 0),
	CONSTRAINT UK_PRE_DEPLOY_APP_NAME UNIQUE (APP_NAME)
)
STORAGE (INITIAL 16K NEXT 16K);

COMMENT ON TABLE VPI.PRE_DEPLOY_APP
	IS 'The registry of applications';

COMMENT ON COLUMN VPI.PRE_DEPLOY_APP.APP_ID
	IS 'The unique identifier for an application, consider a naming convention within the enterprise.';
COMMENT ON COLUMN VPI.PRE_DEPLOY_APP.APP_NAME
	IS 'The application name.';
COMMENT ON COLUMN VPI.PRE_DEPLOY_APP.APP_OWNER
	IS 'The owner of the application.';
COMMENT ON COLUMN VPI.PRE_DEPLOY_APP.LAST_VERSION
	IS 'The last deployed version number.';