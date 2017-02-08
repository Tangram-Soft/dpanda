<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx" >

  <xsl:template match="/">
    <xsl:copy>
      <jsonx:object>
        <jsonx:array name="domains">
          <xsl:for-each select="//Domain">
            <jsonx:string>
              <xsl:value-of select="./@name"/>
            </jsonx:string>
          </xsl:for-each>
        </jsonx:array>
      </jsonx:object>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
