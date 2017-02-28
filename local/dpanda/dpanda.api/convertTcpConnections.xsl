<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx" >

  <xsl:template match="/">
    <xsl:copy>
      <jsonx:object>
        <jsonx:string name="established">
          <xsl:value-of select="//established"/>
        </jsonx:string>
        <jsonx:string name="synSent">
          <xsl:value-of select="//syn_sent"/>
        </jsonx:string>
        <jsonx:string name="synReceived">
          <xsl:value-of select="//syn_received"/>
        </jsonx:string>
        <jsonx:string name="finWait1">
          <xsl:value-of select="//fin_wait_1"/>
        </jsonx:string>
        <jsonx:string name="finWait2">
          <xsl:value-of select="//fin_wait_2"/>
        </jsonx:string>
        <jsonx:string name="timeWait">
          <xsl:value-of select="//time_wait"/>
        </jsonx:string>
        <jsonx:string name="closed">
          <xsl:value-of select="//closed"/>
        </jsonx:string>
        <jsonx:string name="closeWait">
          <xsl:value-of select="//close_wait"/>
        </jsonx:string>
        <jsonx:string name="lastAck">
          <xsl:value-of select="//last_ack"/>
        </jsonx:string>
        <jsonx:string name="listen">
          <xsl:value-of select="//listen"/>
        </jsonx:string>
        <jsonx:string name="closing">
          <xsl:value-of select="//closing"/>
        </jsonx:string>
      </jsonx:object>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
