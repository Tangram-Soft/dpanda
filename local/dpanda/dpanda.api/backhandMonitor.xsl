<!--Todo:
*.add MQ Server to list of targets - DONE!
*.add domain exclude list. - DONE!
*. filter the target list - remove identical elements - DONE!
*.Remove Xml Decleration - DONE!
*.adding object name to target element. - DONE!
*.add user config backhand list - DONE!
*.create invalid backhands (Loopback,local) -DONE!
*.handle Load BalancerGroup - DONE!
*handle FTP backhand

-->

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
  <xsl:param name="excludeDomainslist">
    <xsl:for-each select="document('local://dpanda/configuration.xml')//ExcludedDomains/Domain/@name">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:param>
  <dp:set-variable name="'var://context/mappedList/data'" value="''"/>
  <xsl:variable name="pwd64" select="dp:encode('dpanda:dpanda','base-64')"/>
  <xsl:variable name="basicAuth" select="concat('Basic ',$pwd64)"/>
  <xsl:variable name="somaRequestHeaders">
    <header name="Content-Type">application/soap+xml</header>
    <header name="Authorization"><xsl:value-of select="$basicAuth"/></header>
  </xsl:variable>

  <func:function name="dpa:getSomaConf">
    <xsl:param name="domainName" />
  	<xsl:param name="className" />
    <xsl:variable name="getConfigResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:get-config  class="{$className}"/>
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:copy-of select="$getConfigResult"/>
    </func:result>
  </func:function>

  <func:function name="dpa:getSomaStatus">
    <xsl:param name="domainName" />
    <xsl:param name="className" />
    <xsl:variable name="getStatusResult">
  		<dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
  			<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
  				<env:Body>
  					<dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
  						<dp:get-status class="{$className}"/>
  					</dp:request>
  				</env:Body>
  			</env:Envelope>
  		</dp:url-open>
	   </xsl:variable>
    <func:result>
      <xsl:copy-of select="$getStatusResult"/>
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



  <func:function name="dpa:illegalHosts">
    <xsl:variable name="localEthStatus" select="dpa:getSomaStatus('default', 'EthernetInterfaceStatus')"/>
    <!--xsl:variable name="hostAliasStatus" select="dpa:getSomaConf('default', 'HostAlias')"/-->
    <xsl:variable name="localHostIPs">
      <xsl:for-each select="$localEthStatus//EthernetInterfaceStatus">
        <host>
          <xsl:value-of select="substring-before(./IP/text(), '/')"/>
        </host>
      </xsl:for-each>
      <!--xsl:for-each select="$hostAliasStatus//HostAlias">
        <host>
          <xsl:value-of select="./@name"/>
        </host>
      </xsl:for-each-->
    </xsl:variable>
    <xsl:variable name="hostList">
      <xsl:for-each select="exslt:node-set($localHostIPs)/host">
        <xsl:value-of select="."/>
        <xsl:text>,</xsl:text>
      </xsl:for-each>
      <xsl:text>127.0.0.1</xsl:text>
    </xsl:variable>
    <dp:set-variable name="'var://context/mappedList/illegal'" value="$hostList"/>
    <func:result/>
  </func:function>

  <func:function name="dpa:handleLBG">
    <xsl:param name="currDomain"/>
    <xsl:variable name="currentList" select="dp:variable('var://context/mappedList/illegal')"/>
    <xsl:variable name="LBGconfig" select="dpa:getSomaConf($currDomain, 'LoadBalancerGroup')"/>
    <xsl:if test="not($LBGconfig//LoadBalancerGroup)">
      <func:rsult/>
    </xsl:if>
    <xsl:variable name="currentDomainLBG">
      <xsl:for-each select="$LBGconfig//LoadBalancerGroup">
        <host>
          <xsl:value-of select="./@name"/>
        </host>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="lbgList">
      <xsl:for-each select="exslt:node-set($currentDomainLBG)/host">
        <xsl:value-of select="."/>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:message dp:priority="debug">lbg list <xsl:value-of select="$lbgList"/></xsl:message>
    <xsl:variable name="targetList" select="concat($currentList, ',', $lbgList)"/>
    <dp:set-variable name="'var://context/mappedList/illegal'" value="$targetList"/>
    <func:result/>
  </func:function>

  <func:function name="dpa:mappedTargetsList">
    <xsl:param name="host"/>
    <xsl:param name="port"/>
    <xsl:variable name="currentList" select="dp:variable('var://context/mappedList/data')"/>
    <xsl:variable name="target" select="concat($host, ':', $port)"/>
    <xsl:if test="contains($currentList, $target) or contains(dp:variable('var://context/mappedList/illegal'), $host)">
      <func:result/>
    </xsl:if>
    <xsl:variable name="targetList" select="concat($currentList, ',', $target)"/>
    <dp:set-variable name="'var://context/mappedList/data'" value="$targetList"/>
    <func:result select="true()"/>
  </func:function>

  <func:function name="dpa:createTargetList">
     <xsl:message dp:priority="debug">getDomains</xsl:message>
     <xsl:variable name="getDomainList" select="dpa:getSomaStatus('default','DomainStatus')"/>
     <xsl:variable name="domainList">
       <domainList>
         <xsl:for-each select="$getDomainList//Domain">
           <xsl:if test="./text()!='dpanda' and not(contains($excludeDomainslist, ./text()))">
             <appDomain><xsl:value-of select="./text()"/></appDomain>
           </xsl:if>
         </xsl:for-each>
       </domainList>
     </xsl:variable>
     <xsl:variable name="backhandTargets">
      <BackhandTargets>
       <xsl:for-each select="exslt:node-set($domainList)/domainList/appDomain">
         <xsl:variable name="currentDomain" select="./text()"/>
         <xsl:variable name="handleLoadBalancerGroup" select="dpa:handleLBG($currentDomain)"/>
         <xsl:for-each select="document('local://dpanda/configuration.xml')//ServiceTypes/serviceType[@monitor='true']/@name">
          <xsl:variable name="result" select="dpa:retriveBackhandHost($currentDomain, .)"/>
            <xsl:copy-of select="$result"/>
        </xsl:for-each>
       </xsl:for-each>
       <xsl:for-each select="document('local://dpanda/configuration.xml')//StaticTargets/RemoteTarget">
         <xsl:copy-of select="."/>
       </xsl:for-each>
      </BackhandTargets>
     </xsl:variable>
     <xsl:variable name='setFile' select="dpa:setFile('local://dpanda/dpanda.api/backhandTargets.xml', $backhandTargets)"/>
  </func:function>

  <func:function name="dpa:retriveBackhandHost">
    <xsl:param name="domainName"/>
    <xsl:param name="className"/>
    <xsl:choose>
      <xsl:when test="$className = 'MultiProtocolGateway'">
        <xsl:variable name="getSomaResponse" select="dpa:getSomaConf($domainName, $className)"/>
          <xsl:variable name="targets">
              <xsl:for-each select="$getSomaResponse//MultiProtocolGateway">
                <xsl:if test="contains(./BackendUrl/text(), 'http')">
                <xsl:variable name="hostUrl" select="translate(regexp:match(./BackendUrl/text(), '\B\/[a-zA-Z\.\-0-9]{1,30}:?[0-9]{0,5}'), '/', '')"/>
                <xsl:variable name="host" select="substring-before( $hostUrl , ':' )"/>
                <xsl:variable name="port" select="substring-after( $hostUrl , ':' )"/>
                <xsl:variable name="name" select="./@name"/>
                <xsl:if test="dpa:mappedTargetsList($host,$port)">
                  <RemoteTarget domain="{$domainName}" name="{$name}" class="{$className}" host="{$host}" port="{$port}"/>
                </xsl:if>
              </xsl:if>
              </xsl:for-each>
          </xsl:variable>
          <func:result>
            <xsl:copy-of select="$targets"/>
          </func:result>
      </xsl:when>
      <xsl:when test="$className = 'WebServiceProxy'">
        <xsl:variable name="getSomaResponse" select="dpa:getSomaConf($domainName, 'WSEndpointRewritePolicy')"/>
        <xsl:if test="$getSomaResponse//WSEndpointRewritePolicy">
          <xsl:variable name="targets">
              <xsl:for-each select="$getSomaResponse//WSEndpointRewritePolicy/WSEndpointRemoteRewriteRule">
                <xsl:variable name="host" select="./RemoteEndpointHostname/text()"/>
                <xsl:variable name="port" select="./RemoteEndpointPort/text()"/>
                <xsl:variable name="name" select="./parent::WSEndpointRewritePolicy/@name"/>
                <xsl:if test="dpa:mappedTargetsList($host,$port)">
                  <RemoteTarget domain="{$domainName}" name="{$name}" class="{$className}" host="{$host}" port="{$port}"/>
                </xsl:if>
              </xsl:for-each>
          </xsl:variable>
          <func:result>
            <xsl:copy-of select="$targets"/>
          </func:result>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$className = 'XMLFirewallService'">
        <xsl:variable name="getSomaResponse" select="dpa:getSomaConf($domainName, $className)"/>
        <xsl:if test="$getSomaResponse//XMLFirewallService">
          <xsl:variable name="targets">
              <xsl:for-each select="$getSomaResponse//XMLFirewallService">
                <xsl:variable name="host" select="./RemoteAddress/text()"/>
                <xsl:variable name="port" select="./RemotePort/text()"/>
                <xsl:variable name="name" select="./@name"/>
                <xsl:if test="dpa:mappedTargetsList($host,$port)">
                  <RemoteTarget domain="{$domainName}" name="{$name}" class="{$className}" host="{$host}" port="{$port}"/>
                </xsl:if>
              </xsl:for-each>
          </xsl:variable>
          <func:result>
            <xsl:copy-of select="$targets"/>
          </func:result>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$className = 'MQQM'">
        <xsl:variable name="getSomaResponse" select="dpa:getSomaConf($domainName, $className)"/>
        <xsl:if test="$getSomaResponse//MQQM">
          <xsl:variable name="targets">
              <xsl:for-each select="$getSomaResponse//MQQM">
                <xsl:variable name="host">
                  <xsl:choose>
                    <xsl:when test="contains(./HostName/text(), ':')">
                      <xsl:value-of select="substring-before(./HostName/text(), ':')"/>
                    </xsl:when>
                    <xsl:when test="contains(./HostName/text(), '(')">
                      <xsl:value-of select="substring-before(./HostName/text(), '(')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="./HostName/text()"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="port">
                  <xsl:choose>
                    <xsl:when test="contains(./HostName/text(), ':')">
                      <xsl:value-of select="substring-after(./HostName/text(), ':')"/>
                    </xsl:when>
                    <xsl:when test="contains(./HostName/text(), '(')">
                      <xsl:value-of select="translate(substring-after(./HostName/text(), '('),')','')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="'1414'"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="name" select="./@name"/>
                <xsl:if test="dpa:mappedTargetsList($host,$port)">
                  <RemoteTarget domain="{$domainName}" name="{$name}" class="{$className}" host="{$host}" port="{$port}"/>
                </xsl:if>
              </xsl:for-each>
          </xsl:variable>
          <func:result>
            <xsl:copy-of select="$targets"/>
          </func:result>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </func:function>

  <func:function name="func:tcpConnectionTest">
   <xsl:param name="foo" />
   <xsl:param name="bar" select="false()" />
  </func:function>

  <xsl:template match="/">
    <xsl:variable name="createIllegalHost" select="dpa:illegalHosts()"/>
    <xsl:variable name="setBackhandTargets" select="dpa:createTargetList()"/>
  </xsl:template>
</xsl:stylesheet>
