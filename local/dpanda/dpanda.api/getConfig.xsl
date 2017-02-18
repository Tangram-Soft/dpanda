<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.datapower.com/extensions"
  extension-element-prefixes="dp">

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

  <xsl:template match="/">
    <xsl:variable name="resource" select="substring-after(//base-url,'/dpanda/api/config/')"/>
    <xsl:variable name="class" select="concat(translate(substring($resource,1,1),$lowercase,$uppercase),substring($resource,2))"/>

    <xsl:variable name="domain">
      <xsl:choose>
        <xsl:when test="//arg[@name='domain']">
          <xsl:value-of select="//arg[@name='domain']/text()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'default'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="name">
      <xsl:if test="//arg[@name='name']">
        <xsl:value-of select="//arg[@name='name']/text()"/>
      </xsl:if>
    </xsl:variable>

    <xsl:copy>
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://www.datapower.com/schemas/management">
       <soapenv:Header/>
       <soapenv:Body>
          <man:request domain="{$domain}">
             <man:get-config class="{$class}" name="{$name}" recursive="true" persisted="true"/>
          </man:request>
       </soapenv:Body>
      </soapenv:Envelope>
    </xsl:copy>

  </xsl:template>
</xsl:stylesheet>
