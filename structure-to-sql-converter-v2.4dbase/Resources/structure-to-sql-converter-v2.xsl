<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:sql="sql" exclude-result-prefixes="sql">

    <xsl:output method="text" />

    <!-- params -->
    <xsl:param name="debug_sql_name" select="''" />
    <xsl:param name="string_quote_mode" select="'4D'" />
    <xsl:param name="with_replicate" select="false()" />
    <xsl:param name="with_autosequence" select="true()" />
    <xsl:param name="with_autogenerate" select="false()" />
    <xsl:param name="with_picture" select="false()" />
    <xsl:param name="with_json" select="true()" />
    <xsl:param name="with_index" select="true()" />
    <xsl:param name="with_schema" select="true()" />

    <!-- variables -->
    <xsl:variable name="sql_keywords" select="document('')//sql:keywords/keyword" />
    <xsl:variable name="number" select="'0123456789'" />
    <xsl:variable name="alnum"  select="'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'" />

    <!-- keys -->
    <xsl:key name="table_by_uuid" match="/base/table" use="./@uuid" />
    <xsl:key name="field_by_uuid" match="/base/table/field" use="./@uuid" />

    <xsl:template match="/">
      <xsl:apply-templates select="/base/table" />
      <xsl:if test="$with_index">
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="/base/index" />
      </xsl:if>
    </xsl:template>

    <xsl:template match="/base/table">
      <xsl:call-template name="new-line" />
      <xsl:for-each select="./field">
        <!--NEW TABLE -->
        <xsl:if test="position() = 1">
          <xsl:text>CREATE TABLE IF NOT EXISTS </xsl:text>
          <xsl:if test="$with_index">
            <!--SCHEMA-->
            <xsl:if test="../@sql_schema_id">
              <xsl:variable name="p" select="number(../@sql_schema_id)"/>
              <xsl:if test="$p &gt; 1">
                <xsl:call-template name="escape-sql-name">
                  <xsl:with-param name="s" select="/base/schema[$p]/@name"/>
                  <xsl:with-param name="mode" select="$string_quote_mode" />
                </xsl:call-template>
                <xsl:text>.</xsl:text>
              </xsl:if>
            </xsl:if><!--SCHEMA-->
          </xsl:if>
          <xsl:call-template name="escape-sql-name">
            <xsl:with-param name="s" select="../@name"/>
            <xsl:with-param name="mode" select="$string_quote_mode" />
          </xsl:call-template>
          <xsl:text> (&#xA;</xsl:text>
        </xsl:if><!--NEW TABLE -->
        <!--NEW FIELD -->
        <xsl:text>&#x9;</xsl:text>
        <xsl:call-template name="escape-sql-name">
          <xsl:with-param name="s" select="@name"/>
          <xsl:with-param name="mode" select="$string_quote_mode" />
        </xsl:call-template>
        <xsl:text> </xsl:text><!--NEW FIELD -->
        <!--FIELD TYPES-->
        <xsl:choose>
          <xsl:when test="@type = 1">
            <xsl:value-of select="'BOOLEAN'" />
          </xsl:when>
          <xsl:when test="@type = 3">
            <xsl:value-of select="'SMALLINT'" />
          </xsl:when>
          <xsl:when test="@type = 4">
            <xsl:value-of select="'INT'" />
          </xsl:when>
          <xsl:when test="@type = 5">
            <xsl:value-of select="'NUMERIC'" /><!--INT64-->
          </xsl:when>
          <xsl:when test="@type = 6">
            <xsl:value-of select="'REAL'" />
          </xsl:when>
          <xsl:when test="@type = 7">
            <xsl:value-of select="'FLOAT'" />
          </xsl:when>
          <xsl:when test="@type = 8">
            <xsl:value-of select="'TIMESTAMP'" />
          </xsl:when>
          <xsl:when test="@type = 9">
            <xsl:value-of select="'DURATION'" />
          </xsl:when>
          <xsl:when test="@type = 12">
            <xsl:choose>
              <xsl:when test="$with_picture">
                <xsl:value-of select="'PICTURE'" />
              </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'BLOB'" />
            </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="@type = 14">
            <xsl:value-of select="'TEXT'" /><!--OUTSIDE RECORD OR OUTSIDE DATA-->
          </xsl:when>
          <xsl:when test="@type = 15">
            <xsl:value-of select="'INT'" />
          </xsl:when>
          <xsl:when test="@type = 16">
            <xsl:value-of select="'INT'" />
          </xsl:when>
          <xsl:when test="@type = 18">
            <xsl:value-of select="'BLOB'" />
          </xsl:when>
          <xsl:when test="@type = 21">
            <xsl:choose>
              <xsl:when test="$with_json">
                <xsl:value-of select="'TEXT'" />
              </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'BLOB'" />
            </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="@type = 10">
            <xsl:choose>
              <xsl:when test="@store_as_UUID">
                <xsl:value-of select="'UUID'" />
              </xsl:when>
              <xsl:when test="@limiting_length">
                <xsl:value-of select="concat('VARCHAR (', @limiting_length, ')')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'TEXT'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
        <!-- semi-standard properties -->
        <xsl:if test="$with_autosequence">
          <xsl:if test="@autosequence = 'true'">
            <xsl:value-of select="' AUTO_INCREMENT'" />
          </xsl:if>
        </xsl:if>
        <!-- non-standard properties -->
        <xsl:if test="$with_autogenerate">
          <xsl:if test="@autogenerate = 'true'">
            <xsl:value-of select="' AUTO_GENERATE'" />
          </xsl:if>
        </xsl:if>
        <!-- standard properties -->
        <xsl:if test="@not_null = 'true'">
          <xsl:value-of select="' NOT NULL'" />
          <xsl:if test="@unique = 'true'">
            <xsl:value-of select="' UNIQUE'" />
          </xsl:if>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="position() = last()">
            <!--PRIMARY KEY-->
            <xsl:if test="../primary_key">
              <xsl:text>,&#xA;&#x9;PRIMARY KEY (</xsl:text>
              <xsl:for-each select="../primary_key">
                <xsl:call-template name="escape-sql-name">
                  <xsl:with-param name="s" select="@field_name"/>
                  <xsl:with-param name="mode" select="$string_quote_mode" />
                </xsl:call-template>
                <xsl:choose>
                <xsl:when test="position() != last()">
                  <xsl:text>,</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>)</xsl:text>
                </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:if>
            <!--REPLICATE-->
            <xsl:if test="$with_replicate">
              <xsl:if test="../@keep_record_sync_info = 'true'">
              <xsl:text>,&#xA;&#x9;ENABLE REPLICATE</xsl:text>
              </xsl:if>
            </xsl:if>
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>);&#xA;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>,&#xA;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:template>

    <xsl:template match="/base/index">
      <xsl:call-template name="new-line"/>
      <xsl:for-each select="./field_ref">
        <!--NEW INDEX -->
        <xsl:if test="position() = 1">
          <xsl:text>CREATE </xsl:text>
          <xsl:if test="../@unique_keys = 'true'">
            <xsl:text>UNIQUE </xsl:text>
          </xsl:if>
          <xsl:text>INDEX </xsl:text>
          <xsl:choose>
            <xsl:when test="../@name">
              <xsl:call-template name="escape-sql-name">
                <xsl:with-param name="s" select="../@name"/>
                <xsl:with-param name="mode" select="$string_quote_mode" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <!--index has no name-->
              <xsl:call-template name="escape-sql-name">
                <xsl:with-param name="s" select="generate-id()"/>
                <xsl:with-param name="mode" select="$string_quote_mode" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> ON </xsl:text>
          <xsl:call-template name="escape-sql-name">
            <xsl:with-param name="s" select="key('table_by_uuid', ./table_ref/@uuid)/@name"/>
            <xsl:with-param name="mode" select="$string_quote_mode" />
          </xsl:call-template>
          <xsl:text> (&#xA;</xsl:text>
        </xsl:if>
        <xsl:text>&#x9;</xsl:text>
        <xsl:call-template name="escape-sql-name">
          <xsl:with-param name="s" select="@name"/>
          <xsl:with-param name="mode" select="$string_quote_mode" />
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:text>&#xA;</xsl:text>
            <xsl:text>);&#xA;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>,&#xA;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="new-line">
      <xsl:if test="position() != 1">
        <xsl:text>&#xA;</xsl:text>
      </xsl:if>
    </xsl:template>

    <xsl:template name="escape-sql-name-dq">
      <xsl:param name="s" />
      <xsl:value-of select="'&quot;'" />
      <xsl:choose>
        <xsl:when test="contains($s, '&quot;')">
          <xsl:value-of select="concat(substring-before($s,'&quot;'),'&#x5C;&quot;')" />
          <xsl:call-template name="escape-sql-name-dq">
            <xsl:with-param name="s" select="substring-after($s,'&quot;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$s"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="'&quot;'" />
    </xsl:template>

    <xsl:template name="escape-sql-name-sq">
      <xsl:param name="s" />
      <xsl:variable name="apos" select='"&apos;"'/>
      <xsl:variable name="apos_apos" select='"&apos;&apos;"'/>
      <xsl:value-of select="$apos" />
      <xsl:choose>
        <xsl:when test="contains($s, $apos)">
          <xsl:value-of select="concat(substring-before($s,$apos),$apos_apos)" />
          <xsl:call-template name="escape-sql-name-sq">
            <xsl:with-param name="s" select="substring-after($s,$apos)" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$s"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$apos" />
    </xsl:template>

    <xsl:template name="escape-sql-name-4d">
      <xsl:param name="s" />
      <xsl:variable name="keyword" select="$sql_keywords[@value = $s]" />
      <xsl:variable name="first" select="substring($s, 1, 1)" />
      <xsl:variable name="first_is_alpha" select="string-length(translate($first, $number, '')) = string-length($first)" />
      <xsl:choose>
        <!-- special characters -->
        <xsl:when test="
  				contains($s, ' ') or
  				contains($s, '!') or
  				contains($s, '&amp;') or
  				contains($s, '^') or
  				contains($s, '#') or
  				contains($s, '%') or
  				contains($s, ']') ">
          <xsl:call-template name="quote-brackets">
  					<xsl:with-param name="s" select="$s" />
  				</xsl:call-template>
        </xsl:when>
        <!-- sql keyword -->
        <xsl:when test="count($keyword) != 0">
          <xsl:call-template name="quote-brackets">
  					<xsl:with-param name="s" select="$s" />
  				</xsl:call-template>
        </xsl:when>
        <!-- [a-zA-Z][a-zA-Z0-9_] -->
        <xsl:when test="$first_is_alpha">
          <xsl:variable name="after_first" select="substring($s, 2)" />
          <xsl:variable name="rest_is_alnum" select="string-length(translate($after_first, $alnum, '')) = 0" />
          <xsl:choose>
            <xsl:when test="$rest_is_alnum">
              <xsl:value-of select="$s" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="quote-brackets">
      					<xsl:with-param name="s" select="$s" />
      				</xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="quote-brackets">
            <xsl:with-param name="s" select="$s" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="escape-sql-name">
      <xsl:param name="s" />
      <xsl:param name="mode" />
      <xsl:choose>
        <xsl:when test="$mode = '4D' ">
          <xsl:call-template name="escape-sql-name-4d">
            <xsl:with-param name="s" select="$s" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$mode = 'DQ' ">
          <xsl:call-template name="escape-sql-name-dq">
            <xsl:with-param name="s" select="$s" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$mode = 'SQ' ">
          <xsl:call-template name="escape-sql-name-sq">
            <xsl:with-param name="s" select="$s" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$s" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <!--escape [...]...] -->
    <xsl:template name="quote-brackets">
  		<xsl:param name="s" />
      <xsl:value-of select="'['" />
  		<xsl:choose>
  			<xsl:when test="contains($s, ']')">
  				<xsl:value-of select="concat(substring-before($s,']'),']]')" />
  				<xsl:call-template name="quote-brackets">
  					<xsl:with-param name="s" select="substring-after($s,']')" />
  				</xsl:call-template>
  			</xsl:when>
  			<xsl:otherwise>
  				<xsl:value-of select="$s"/>
  			</xsl:otherwise>
  		</xsl:choose>
      <xsl:value-of select="']'" />
  	</xsl:template>

    <!-- lookup tables -->
    <sql:keywords>
      <keyword value="__ROW_ACTION" />
      <keyword value="__ROW_ID" />
      <keyword value="__ROW_STAMP" />
      <keyword value="ABS" />
      <keyword value="ACOS" />
      <keyword value="ADD" />
      <keyword value="ALL" />
      <keyword value="ALPHA_NUMERIC" />
      <keyword value="ALTER" />
      <keyword value="AND" />
      <keyword value="ANY" />
      <keyword value="AS" />
      <keyword value="ASC" />
      <keyword value="ASCII" />
      <keyword value="ASIN" />
      <keyword value="ASYNC" />
      <keyword value="ATAN" />
      <keyword value="ATAN2" />
      <keyword value="AUTO_CLOSE" />
      <keyword value="AUTO_GENERATE" />
      <keyword value="AUTO_INCREMENT" />
      <keyword value="AVG" />
      <keyword value="BETWEEN" />
      <keyword value="BIT" />
      <keyword value="BIT_LENGTH" />
      <keyword value="BLOB" />
      <keyword value="BOOLEAN" />
      <keyword value="BOTH" />
      <keyword value="BY" />
      <keyword value="BYTE" />
      <keyword value="CASCADE" />
      <keyword value="CASE" />
      <keyword value="CAST" />
      <keyword value="CEILING" />
      <keyword value="CHAR" />
      <keyword value="CHAR_LENGTH" />
      <keyword value="CLOB" />
      <keyword value="COALESCE" />
      <keyword value="COMMIT" />
      <keyword value="CONCAT" />
      <keyword value="CONCATENATE" />
      <keyword value="CONSTRAINT" />
      <keyword value="CONSTRAINTS" />
      <keyword value="COS" />
      <keyword value="COT" />
      <keyword value="COUNT" />
      <keyword value="CREATE" />
      <keyword value="CROSS" />
      <keyword value="CURDATE" />
      <keyword value="CURRENT_DATE" />
      <keyword value="CURRENT_TIME" />
      <keyword value="CURRENT_TIMESTAMP" />
      <keyword value="CURTIME" />
      <keyword value="DATABASE" />
      <keyword value="DATABASE_PATH" />
      <keyword value="DATAFILE" />
      <keyword value="DATE" />
      <keyword value="DATE_TO_CHAR" />
      <keyword value="DAY" />
      <keyword value="DAYNAME" />
      <keyword value="DAYOFMONTH" />
      <keyword value="DAYOFWEEK" />
      <keyword value="DAYOFYEAR" />
      <keyword value="DEBUG" />
      <keyword value="DEFAULT" />
      <keyword value="DEGREES" />
      <keyword value="DELETE" />
      <keyword value="DESC" />
      <keyword value="DIRECT" />
      <keyword value="DISABLE" />
      <keyword value="DISTINCT" />
      <keyword value="DOUBLE" />
      <keyword value="DROP" />
      <keyword value="DURATION" />
      <keyword value="ELSE" />
      <keyword value="ENABLE" />
      <keyword value="END" />
      <keyword value="ESCAPE" />
      <keyword value="EXCLUSIVE" />
      <keyword value="EXECUTE" />
      <keyword value="EXISTS" />
      <keyword value="EXP" />
      <keyword value="EXTRACT" />
      <keyword value="FALSE" />
      <keyword value="FLOAT" />
      <keyword value="FLOOR" />
      <keyword value="FN" />
      <keyword value="FOR" />
      <keyword value="FOREIGN" />
      <keyword value="FROM" />
      <keyword value="FULL" />
      <keyword value="GRANT" />
      <keyword value="GROUP" />
      <keyword value="HAVING" />
      <keyword value="HOUR" />
      <keyword value="IF" />
      <keyword value="IMMEDIATE" />
      <keyword value="IN" />
      <keyword value="INDEX" />
      <keyword value="INDEXES" />
      <keyword value="INF" />
      <keyword value="INFILE" />
      <keyword value="INNER" />
      <keyword value="INSERT" />
      <keyword value="INT" />
      <keyword value="INT16" />
      <keyword value="INT32" />
      <keyword value="INT64" />
      <keyword value="INTERVAL" />
      <keyword value="INTO" />
      <keyword value="IS" />
      <keyword value="JOIN" />
      <keyword value="KEY" />
      <keyword value="LATEST" />
      <keyword value="LEADING" />
      <keyword value="LEFT" />
      <keyword value="LENGTH" />
      <keyword value="LIKE" />
      <keyword value="LIMIT" />
      <keyword value="LISTBOX" />
      <keyword value="LOCAL" />
      <keyword value="LOCATE" />
      <keyword value="LOCK" />
      <keyword value="LOG" />
      <keyword value="LOG10" />
      <keyword value="LOWER" />
      <keyword value="LTRIM" />
      <keyword value="MAX" />
      <keyword value="MILLISECOND" />
      <keyword value="MIN" />
      <keyword value="MINUTE" />
      <keyword value="MOD" />
      <keyword value="MODE" />
      <keyword value="MODIFY" />
      <keyword value="MONTH" />
      <keyword value="MONTHNAME" />
      <keyword value="NATURAL" />
      <keyword value="NOT" />
      <keyword value="NULL" />
      <keyword value="NULLIF" />
      <keyword value="NUMERIC" />
      <keyword value="OCTET_LENGTH" />
      <keyword value="OFFSET" />
      <keyword value="OJ" />
      <keyword value="ON" />
      <keyword value="OR" />
      <keyword value="ORDER" />
      <keyword value="OUTER" />
      <keyword value="OVER" />
      <keyword value="PI" />
      <keyword value="PICTURE" />
      <keyword value="POSITION" />
      <keyword value="POWER" />
      <keyword value="PRECISION" />
      <keyword value="PRIMARY" />
      <keyword value="QUARTER" />
      <keyword value="RADIANS" />
      <keyword value="RAND" />
      <keyword value="READ" />
      <keyword value="READ_WRITE" />
      <keyword value="REAL" />
      <keyword value="REFERENCES" />
      <keyword value="REMOTE" />
      <keyword value="RENAME" />
      <keyword value="REPEAT" />
      <keyword value="REPLACE" />
      <keyword value="REPLICATE" />
      <keyword value="RESTRICT" />
      <keyword value="REVOKE" />
      <keyword value="RIGHT" />
      <keyword value="ROLLBACK" />
      <keyword value="ROUND" />
      <keyword value="RTRIM" />
      <keyword value="SCHEMA" />
      <keyword value="SECOND" />
      <keyword value="SELECT" />
      <keyword value="SET" />
      <keyword value="SHARE" />
      <keyword value="SIGN" />
      <keyword value="SIN" />
      <keyword value="SMALLINT" />
      <keyword value="SOME" />
      <keyword value="SPACE" />
      <keyword value="SQL_INTERNAL" />
      <keyword value="SQRT" />
      <keyword value="STAMP" />
      <keyword value="START" />
      <keyword value="STRUCTURE_FILE" />
      <keyword value="SUBSTRING" />
      <keyword value="SUM" />
      <keyword value="SYNC" />
      <keyword value="SYNCHRONIZE" />
      <keyword value="TABLE" />
      <keyword value="TAN" />
      <keyword value="TEXT" />
      <keyword value="THEN" />
      <keyword value="THREADING" />
      <keyword value="TIME" />
      <keyword value="TIMESTAMP" />
      <keyword value="TO" />
      <keyword value="TRAILING" />
      <keyword value="TRANSACTION" />
      <keyword value="TRANSLATE" />
      <keyword value="TRIGGERS" />
      <keyword value="TRIM" />
      <keyword value="TRUE" />
      <keyword value="TRUNC" />
      <keyword value="TRUNCATE" />
      <keyword value="TS" />
      <keyword value="UNIQUE" />
      <keyword value="UNLOCK" />
      <keyword value="UPDATE" />
      <keyword value="UPPER" />
      <keyword value="USE" />
      <keyword value="UTF16" />
      <keyword value="UTF8" />
      <keyword value="UUID" />
      <keyword value="VALUES" />
      <keyword value="VARCHAR" />
      <keyword value="VARYING" />
      <keyword value="VIEW" />
      <keyword value="WEEK" />
      <keyword value="WHEN" />
      <keyword value="WHERE" />
      <keyword value="WITH" />
      <keyword value="YEAR" />
    </sql:keywords>

</xsl:stylesheet>
