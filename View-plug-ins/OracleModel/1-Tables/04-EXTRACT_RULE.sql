CREATE TABLE VPI.EXTRACT_RULE
(
	RULE_ID		NUMBER(5)		NOT NULL,
	PLUGIN_ID	VARCHAR2(32)	NOT NULL,
	TAG$01		VARCHAR2(64),
	TAG$02		VARCHAR2(64),
	TAG$03		VARCHAR2(64),
	TAG$04		VARCHAR2(64),
	TAG$05		VARCHAR2(64),
	TAG$06		VARCHAR2(64),
	TAG$07		VARCHAR2(64),
	TAG$08		VARCHAR2(64),
	TAG$09		VARCHAR2(64),
	TAG$10		VARCHAR2(64),
	TAG$11		VARCHAR2(64),
	TAG$12		VARCHAR2(64),
	TAG$13		VARCHAR2(64),
	TAG$14		VARCHAR2(64),
	TAG$15		VARCHAR2(64),
	TAG$16		VARCHAR2(64),

	CONSTRAINT PK_EXTRACT_RULE PRIMARY KEY (RULE_ID),
	CONSTRAINT FK_EXTRACT_RULE FOREIGN KEY (PLUGIN_ID) REFERENCES VPI.EXTRACT_PLUGIN (PLUGIN_ID)
)
STORAGE (INITIAL 256K NEXT 1M);

CREATE INDEX VPI.IX_EXTRACT_RULE00 ON VPI.EXTRACT_RULE (PLUGIN_ID);
CREATE INDEX VPI.IX_EXTRACT_RULE01 ON VPI.EXTRACT_RULE (TAG$01);
CREATE INDEX VPI.IX_EXTRACT_RULE02 ON VPI.EXTRACT_RULE (TAG$02);
CREATE INDEX VPI.IX_EXTRACT_RULE03 ON VPI.EXTRACT_RULE (TAG$03);
CREATE INDEX VPI.IX_EXTRACT_RULE04 ON VPI.EXTRACT_RULE (TAG$04);
CREATE INDEX VPI.IX_EXTRACT_RULE05 ON VPI.EXTRACT_RULE (TAG$05);
CREATE INDEX VPI.IX_EXTRACT_RULE06 ON VPI.EXTRACT_RULE (TAG$06);
CREATE INDEX VPI.IX_EXTRACT_RULE07 ON VPI.EXTRACT_RULE (TAG$07);
CREATE INDEX VPI.IX_EXTRACT_RULE08 ON VPI.EXTRACT_RULE (TAG$08);
CREATE INDEX VPI.IX_EXTRACT_RULE09 ON VPI.EXTRACT_RULE (TAG$09);
CREATE INDEX VPI.IX_EXTRACT_RULE10 ON VPI.EXTRACT_RULE (TAG$10);
CREATE INDEX VPI.IX_EXTRACT_RULE11 ON VPI.EXTRACT_RULE (TAG$11);
CREATE INDEX VPI.IX_EXTRACT_RULE12 ON VPI.EXTRACT_RULE (TAG$12);
CREATE INDEX VPI.IX_EXTRACT_RULE13 ON VPI.EXTRACT_RULE (TAG$13);
CREATE INDEX VPI.IX_EXTRACT_RULE14 ON VPI.EXTRACT_RULE (TAG$14);
CREATE INDEX VPI.IX_EXTRACT_RULE15 ON VPI.EXTRACT_RULE (TAG$15);
CREATE INDEX VPI.IX_EXTRACT_RULE16 ON VPI.EXTRACT_RULE (TAG$16);

COMMENT ON TABLE EXTRACT_RULE
	IS 'This centralized table contains all constant parameters.';

COMMENT ON COLUMN VPI.EXTRACT_RULE.RULE_ID
	IS 'The primary key of this table is pointless, it just means one unique rule. The business key should be in one or some of TAG$... columns. The integrity of rules configuration must be checked manually.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.PLUGIN_ID
	IS 'This rule will be applied to which plug-in.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$01
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$02
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$03
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$04
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$05
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$06
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$07
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$08
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$09
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$10
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$11
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$12
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$13
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$14
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$15
	IS 'A constant parameter to be used by the extraction plug-in view.';
COMMENT ON COLUMN VPI.EXTRACT_RULE.TAG$16
	IS 'A constant parameter to be used by the extraction plug-in view.';
