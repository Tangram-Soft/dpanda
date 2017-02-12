<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dp="http://www.datapower.com/extensions"
    xmlns:dpconfig="http://www.datapower.com/param/config"
    extension-element-prefixes="dp"
    exclude-result-prefixes="dp dpconfig">

  <xsl:template match="/">
    <xsl:variable name="username" select="//username/text()"/>
    <xsl:variable name="password" select="//password/text()"/>
    <xsl:message>@@SD <xsl:value-of select="$username"/></xsl:message>
    <xsl:message>@@SD <xsl:value-of select="$password"/></xsl:message>
    <xsl:variable name="encodedCreds" select="dp:encode(concat($username,':',$password),'base-64')"/>
    <xsl:variable name="authHeaderValue" select="concat('Basic ',$encodedCreds)"/>

    <!-- Creating the Headers for the SOMA request -->
    <xsl:variable name="somaRequestHeaders">
        <header name="Content-Type">application/soap+xml</header>
        <header name="Authorization"><xsl:value-of select="$authHeaderValue"/></header>
    </xsl:variable>

    <xsl:variable name="result">
      <dp:url-open target="https://dpanda.xml.mgmt:5550/service/mgmt/current" response="xml" http-method="post" http-headers="$somaRequestHeaders" >
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://www.datapower.com/schemas/management">
           <soapenv:Header/>
           <soapenv:Body>
              <man:request domain="default">
               <man:get-samlart user="{$username}" password="{$password}"/>
             </man:request>
           </soapenv:Body>
         </soapenv:Envelope>
      </dp:url-open>
    </xsl:variable>
    <xsl:message>@@SD <xsl:value-of select="$result"/></xsl:message>
    <xsl:choose>
      <xsl:when test="$result//*[local-name()='result'] and not($result//*[local-name()='result']/text()='Authentication failure')">
        <OutputCredential>group</OutputCredential>
      </xsl:when>
      <xsl:otherwise>
        <!-- Leave empty for authentication failures -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
