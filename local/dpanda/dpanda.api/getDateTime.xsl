<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx"
  xmlns:date="http://exslt.org/dates-and-times" >

  <xsl:template match="/">
    <xsl:variable name="currentDateTime" select="date:date-time()"/>
    <xsl:copy>
      <jsonx:object>
        <jsonx:string name="timestamp">
          <xsl:value-of select="$currentDateTime"/>
        </jsonx:string>
        <jsonx:string name="weekday">
          <xsl:value-of select="date:day-in-week($currentDateTime)"/>
        </jsonx:string>
        <jsonx:string name="dateMonth">
          <xsl:value-of select="date:month-in-year($currentDateTime)"/>
        </jsonx:string>
        <jsonx:string name="dateYear">
          <xsl:value-of select="date:year($currentDateTime)"/>
        </jsonx:string>
        <jsonx:string name="dateDay">
          <xsl:value-of select="date:day-in-month($currentDateTime)"/>
        </jsonx:string>
        <jsonx:string name="hour">
          <xsl:value-of select="date:hour-in-day($currentDateTime)"/>
        </jsonx:string>
        <jsonx:string name="minute">
          <xsl:value-of select="date:minute-in-hour($currentDateTime)"/>
        </jsonx:string>
        <jsonx:string name="second">
          <xsl:value-of select="date:second-in-minute($currentDateTime)"/>
        </jsonx:string>
      </jsonx:object>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
