CREATE TABLE VPI.EXTRACT_INTERFACE
(
	INTERFACE_ID	VARCHAR2(32)	NOT NULL,
	SERVICE_ID		VARCHAR2(32)	NOT NULL,
	UNION_VIEW		VARCHAR2(61),
	SELECT_LIST		NVARCHAR2(1024),
	DESCRIPTION_	VARCHAR2(1024),

	CONSTRAINT PK_EXTRACT_INTERFACE PRIMARY KEY (INTERFACE_ID),
	CONSTRAINT CK_EXTRACT_INTERFACE_ID CHECK (INTERFACE_ID = UPPER(INTERFACE_ID)),
	CONSTRAINT FK_EXTRACT_INTERFACE_SVC FOREIGN KEY (SERVICE_ID) REFERENCES VPI.EXTRACT_SERVICE (SERVICE_ID)
)
STORAGE (INITIAL 16K NEXT 16K);

COMMENT ON COLUMN VPI.EXTRACT_INTERFACE.INTERFACE_ID
	IS 'The unique identifier for the interface, consider a naming convention within the enterprise.';
COMMENT ON COLUMN VPI.EXTRACT_INTERFACE.UNION_VIEW
	IS 'The name of view which will union all plug-ins under the same interface.';
COMMENT ON COLUMN VPI.EXTRACT_INTERFACE.SELECT_LIST
	IS 'The select list in the select statement, every plug-in view of the same interface will follow this signature.';
COMMENT ON COLUMN VPI.EXTRACT_INTERFACE.SERVICE_ID
	IS 'The extract service (application) of this interface.';
