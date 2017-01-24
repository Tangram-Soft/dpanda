<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx" >

  <xsl:template match="/">
    <xsl:copy>
      <jsonx:object>
        <jsonx:string name="freeEncrypted">
          <xsl:value-of select="//FreeEncrypted"/>
        </jsonx:string>
        <jsonx:string name="totalEncrypted">
          <xsl:value-of select="//TotalEncrypted"/>
        </jsonx:string>
        <jsonx:string name="freeTemporary">
          <xsl:value-of select="//FreeTemporary"/>
        </jsonx:string>
        <jsonx:string name="totalTemporary">
          <xsl:value-of select="//TotalTemporary"/>
        </jsonx:string>
        <jsonx:string name="freeInternal">
          <xsl:value-of select="//FreeInternal"/>
        </jsonx:string>
        <jsonx:string name="totalInternal">
          <xsl:value-of select="//TotalInternal"/>
        </jsonx:string>
      </jsonx:object>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
