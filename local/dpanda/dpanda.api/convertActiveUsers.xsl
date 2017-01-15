<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx" >

  <xsl:template match="/">
    <xsl:copy>
      <jsonx:object>
        <jsonx:string name="totalActiveUsers">
          <xsl:value-of select="count(//ActiveUsers)"/>
        </jsonx:string>
        <jsonx:array name="users">
          <xsl:for-each select="//ActiveUsers">
            <jsonx:object>
              <jsonx:string name="user">
                <xsl:value-of select="./name"/>
              </jsonx:string>
              <jsonx:string name="session">
                <xsl:value-of select="./session"/>
              </jsonx:string>
              <jsonx:string name="clientIp">
                <xsl:value-of select="./address"/>
              </jsonx:string>
              <jsonx:string name="loginDate">
                <xsl:value-of select="./login"/>
              </jsonx:string>
            </jsonx:object>
          </xsl:for-each>
        </jsonx:array>
      </jsonx:object>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
