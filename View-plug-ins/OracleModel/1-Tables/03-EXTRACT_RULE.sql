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

	CONSTRAINT PK_EXTRACT_RULE PRIMARY KEY (RULE_ID),
	CONSTRAINT FK_EXTRACT_RULE FOREIGN KEY (PLUGIN_ID) REFERENCES VPI.EXTRACT_PLUGIN (PLUGIN_ID)
)
STORAGE (INITIAL 256K NEXT 1M);

CREATE INDEX VPI.IX_EXTRACT_RULE0 ON VPI.EXTRACT_RULE (PLUGIN_ID);
CREATE INDEX VPI.IX_EXTRACT_RULE1 ON VPI.EXTRACT_RULE (TAG$01);
CREATE INDEX VPI.IX_EXTRACT_RULE2 ON VPI.EXTRACT_RULE (TAG$02);
CREATE INDEX VPI.IX_EXTRACT_RULE3 ON VPI.EXTRACT_RULE (TAG$03);
CREATE INDEX VPI.IX_EXTRACT_RULE4 ON VPI.EXTRACT_RULE (TAG$04);
CREATE INDEX VPI.IX_EXTRACT_RULE5 ON VPI.EXTRACT_RULE (TAG$05);
CREATE INDEX VPI.IX_EXTRACT_RULE6 ON VPI.EXTRACT_RULE (TAG$06);
CREATE INDEX VPI.IX_EXTRACT_RULE7 ON VPI.EXTRACT_RULE (TAG$07);
CREATE INDEX VPI.IX_EXTRACT_RULE8 ON VPI.EXTRACT_RULE (TAG$08);
CREATE INDEX VPI.IX_EXTRACT_RULE9 ON VPI.EXTRACT_RULE (TAG$09);

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
