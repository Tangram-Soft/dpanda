<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.datapower.com/extensions"
  xmlns:dpconfig="http://www.datapower.com/param/config"
  xmlns:func="http://exslt.org/functions"
  xmlns:exslt="http://exslt.org/common"
  xmlns:dpa="http://dpanda.com/functions"
  xmlns:regexp="http://exslt.org/regular-expressions"
  extension-element-prefixes="dp dpconfig func dpa exslt regexp">

  <xsl:param name="xmlMgmtInterface" select="'https://dpanda.xml.mgmt:5550/service/mgmt/3.0'"/>
  <xsl:variable name="pwd64" select="dp:encode('dpanda:dpanda','base-64')"/>
  <xsl:variable name="basicAuth" select="concat('Basic ',$pwd64)"/>
  <xsl:variable name="somaRequestHeaders">
    <header name="Content-Type">application/soap+xml</header>
    <header name="Authorization"><xsl:value-of select="$basicAuth"/></header>
  </xsl:variable>

  <func:function name="dpa:doActionRequest">
    <xsl:param name="domainName"/>
    <xsl:param name="doActionElement"/>
    <xsl:variable name="doActionResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders"
        timeout="1">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:do-action>
                <xsl:copy-of select="$doActionElement"/>
              </dp:do-action>
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:copy-of select="$doActionResult"/>
    </func:result>
  </func:function>

  <func:function name="dpa:setFile">
    <xsl:param name="fileName"/>
    <xsl:param name="data"/>
    <xsl:variable name="serializedData">
      <dp:serialize select="$data" omit-xml-decl="yes"/>
    </xsl:variable>
    <xsl:variable name="encodedData" select="dp:encode($serializedData,'base-64')"/>
    <xsl:variable name="getStatusResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="default" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:set-file  name="{$fileName}">
                <xsl:value-of select="$encodedData"/>
              </dp:set-file>
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
     </xsl:variable>
  </func:function>

  <func:function name="dpa:tcpConnctionTest">
    <xsl:param name="remoteTarget"/>
    <xsl:variable name="tcpConnTest">
      <TCPConnectionTest>
        <RemoteHost><xsl:value-of select="$remoteTarget/@host"/></RemoteHost>
        <RemotePort><xsl:value-of select="$remoteTarget/@port"/></RemotePort>
      </TCPConnectionTest>
    </xsl:variable>
    <xsl:variable name="healthCheckResult" select="dpa:doActionRequest($remoteTarget/@domain, $tcpConnTest)"/>
    <xsl:variable name="linkStatus">
      <xsl:choose>
        <xsl:when test="$healthCheckResult//*[name()='dp:result']/text()">
          <xsl:value-of select="'up'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'down'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="remoteTargetStatus">
      <xsl:text>{</xsl:text>
      <xsl:text>"domain":"</xsl:text><xsl:value-of select="$remoteTarget/@domain"/><xsl:text>",</xsl:text>
      <xsl:text>"objectName":"</xsl:text><xsl:value-of select="$remoteTarget/@name"/><xsl:text>",</xsl:text>
      <xsl:text>"objectType":"</xsl:text><xsl:value-of select="$remoteTarget/@class"/><xsl:text>",</xsl:text>
      <xsl:text>"remoteHost":"</xsl:text><xsl:value-of select="concat($remoteTarget/@host, ':', $remoteTarget/@port)"/><xsl:text>",</xsl:text>
      <xsl:text>"linkStatus":"</xsl:text><xsl:value-of select="$linkStatus"/><xsl:text>"</xsl:text>
      <xsl:text>}</xsl:text>
    </xsl:variable>
    <func:result select="$remoteTargetStatus"/>
  </func:function>

  <xsl:template match="/">
    <xsl:variable name="remoteBackhands">
      <xsl:copy-of select="document('local://dpanda.api/backhandTargets.xml')"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains(dp:variable('var://service/URI'), 'remotetarget')">
        <xsl:variable name="target" select="substring-after(dp:variable('var://service/URI'), '=')"/>
        <xsl:variable name="serviceName" select="substring-before($target, '%40')"/>
        <xsl:variable name="domainName" select="substring-after($target, '%40')"/>
        <xsl:variable name="invalidRemote">
          <xsl:text>{"error":"invalid remote target"}</xsl:text>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$remoteBackhands//RemoteTarget[@name=$serviceName][@domain=$domainName]">
            <xsl:value-of select="dpa:tcpConnctionTest($remoteBackhands//RemoteTarget[@name=$serviceName][@domain=$domainName])"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$invalidRemote"/>
          </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="healthCheckResult">
          <xsl:text>{</xsl:text>
          <xsl:text>"RemoteHostStatus": [</xsl:text>
          <xsl:for-each select="$remoteBackhands//RemoteTarget">
            <xsl:value-of select="dpa:tcpConnctionTest(.)"/>
            <xsl:if test="position() != last()">
              <xsl:text>,</xsl:text>
            </xsl:if>
          </xsl:for-each>
          <xsl:text>]}</xsl:text>
        </xsl:variable>
        <xsl:value-of select="dpa:setFile('local://dpanda/dpanda.api/remotesBackhandsStatus.txt', $healthCheckResult)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
