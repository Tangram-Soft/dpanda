<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx" >

  <xsl:template match="/">
    <xsl:copy>
      <jsonx:object>
        <jsonx:string name="Load">
          <xsl:value-of select="(//Load/text())[1]"/>
        </jsonx:string>
        <jsonx:string name="Memory">
          <xsl:value-of select="(//Memory/text())[1]"/>
        </jsonx:string>
        <jsonx:string name="CPU">
          <xsl:value-of select="(//CPU/text())[1]"/>
        </jsonx:string>
      </jsonx:object>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
