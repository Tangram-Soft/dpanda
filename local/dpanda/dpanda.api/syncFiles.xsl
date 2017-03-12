
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.datapower.com/extensions"
  xmlns:dpconfig="http://www.datapower.com/param/config"
  xmlns:query="http://www.datapower.com/param/query"
  xmlns:func="http://exslt.org/functions"
  xmlns:exslt="http://exslt.org/common"
  xmlns:my="http://bla.com/bla"
  xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:json="json:json"
  exclude-result-prefixes="date"
  extension-element-prefixes="dp dpconfig func my exslt">


  <!--TO DO: add documentation-->

  <!--*******REQUEST EXAMPLE:******** 
  {
  "main":"https://dpanda.xml.mgmt:5550/service/mgmt/3.0",
  "backup":"https://172.17.0.3:5550/service/mgmt/3.0",
    "domain":"dpanda",
    "password":"dpanda",
    "username":"dpanda"
    }
  -->


  <xsl:variable name="pwd64" select="dp:encode('dpanda:dpanda','base-64')"/>
  <xsl:variable name="basicAuth" select="concat('Basic ',$pwd64)"/>
  <xsl:variable name="somaRequestHeaders">
    <header name="Content-Type">application/soap+xml</header>
    <header name="Authorization"><xsl:value-of select="$basicAuth"/></header>
  </xsl:variable>

  <!--Backup destination folder before sync-->
  <func:function name="my:sendToBackup">
    <xsl:param name="domainName" />
    <xsl:param name="folderToBackup" />
    <xsl:variable name="getCreateFolderResult">
      <dp:url-open target="{$secondXmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:do-action>
                <CreateDir>
                  <Dir><xsl:value-of select="$folderToBackup"/></Dir>
                </CreateDir>
              </dp:do-action>        
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <xsl:variable name="getBackupSomaResult">
      <dp:url-open target="{$secondXmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:do-action>
                <CreateDir>
                  <Dir><xsl:value-of select="$folderToBackup"/></Dir>
                </CreateDir>
              </dp:do-action>        
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:value-of select="$getBackupSomaResult"/>
    </func:result>
  </func:function>

    <!--itirate over all the files-->
  <func:function name="my:getFileStore">
    <xsl:param name="domainName" />
    <xsl:param name="parentDir" />
    <xsl:param name="xmlMgmtInterface" />
    <xsl:variable name="getFileStoreResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:get-filestore location="{$parentDir}"/>        
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:copy-of select="$getFileStoreResult"/>
    </func:result>
  </func:function>

  <!--get a file from a domain - SOMA upload file-->
  <func:function name="my:getFile">
    <xsl:param name="domainName" />
    <xsl:param name="directory"/>
    <xsl:param name="filename" />
    <xsl:param name="xmlMgmtInterface" />
    <xsl:variable name="getFileResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:get-file name="{concat(concat($directory,'/'),$filename)}"/>
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:copy-of select="$getFileResult"/>
    </func:result>
  </func:function>


  <!--Upload a file to a domain - soma upload file-->
  <func:function name="my:setFile">
    <xsl:param name="domainName" />
    <xsl:param name="encodedFile" />
    <xsl:param name="directory"/>
    <xsl:param name="filename" />
    <xsl:param name="xmlMgmtInterface" />
    <xsl:variable name="getUploadFileResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:set-file name="{concat(concat($directory,'/'),$filename)}"><xsl:value-of select="$encodedFile"/></dp:set-file>        
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:copy-of select="$getUploadFileResult"/>
    </func:result>
  </func:function>

  <!--Create a folder on a domain -soma create dir -->
  <func:function name="my:dirFunc">
    <xsl:param name="domainName" />
    <xsl:param name="dirToCreate" />
    <xsl:param name="dirAction"/>
    <xsl:param name="xmlMgmtInterface" />
    <xsl:variable name="getDirFuncResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:do-action>
                <xsl:element name="{$dirAction}">
                  <Dir>
                    <xsl:value-of select="$dirToCreate"/>
                  </Dir>
                </xsl:element>
              </dp:do-action>
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:value-of select="$getDirFuncResult//*[name()='file']"/>
    </func:result>
  </func:function>

  <!--Delete a file - soma delete file-->
  <func:function name="my:deleteFile">
    <xsl:param name="domainName" />
    <xsl:param name="fileToDelete" />
    <xsl:variable name="getCreateFolderResult">
      <dp:url-open target="{$secondXmlMgmtInterface}" response="xml" http-method="post" http-headers="$somaRequestHeaders">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="{$domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:do-action>
                <!--<xsl:for-each select="$getDomainList//Domain">
                  <appDomain><xsl:value-of select="./text()"/></appDomain>
                </xsl:for-each>-->
                <DeleteFile>
                  <File>
                    <xsl:value-of select="$fileToDelete"/>
                  </File>
                </DeleteFile>
              </dp:do-action>       
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
    </xsl:variable>
    <func:result>
      <xsl:copy-of select="$getCreateFolderResult"/>
    </func:result>
  </func:function>


  <xsl:template match="/">
    <xsl:param name="xmlMgmtInterface" select="//*[@name='main']/text()"/>
    <xsl:param name="secondXmlMgmtInterface" select="//*[@name='backup']/text()"/>
    <xsl:param name="domain" select="//*[@name='domain']/text()"/>
    <Results>
    <!--<xsl:message>AR@@ RESULTS- <xsl:value-of select="my:sendToBackup('dpanda','local:///backupBeforeSync')"/></xsl:message>-->
    <xsl:variable name="mainFileStore"><xsl:copy-of select="my:getFileStore($domain,'local:', $xmlMgmtInterface)"/></xsl:variable>
    <xsl:variable name="secondFileStore"><xsl:copy-of select="my:getFileStore($domain,'local:',$secondXmlMgmtInterface)"/></xsl:variable>

    <xsl:for-each select="$mainFileStore//*[local-name()='directory']">
      <xsl:variable name="location" select="./@name"/>
      <directory name="{./@name}">
        <xsl:choose>
          <xsl:when test="$secondFileStore//*[local-name()='directory' and @name=$location]">
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="my:dirFunc($domain,$location,'CreateDir',$secondXmlMgmtInterface)"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="./*[local-name()='file']">
          <file name="{./@name}">
            <xsl:variable name="filename" select="./@name"/>
            <xsl:variable name="mainModified" select="./*[local-name()='modified']"/>
            <xsl:variable name="secondModified" select="$secondFileStore//*[local-name()='directory' and @name=$location]/*[local-name()='file' and @name=$filename]/*[local-name()='modified']"/>
              <xsl:variable name="mainModifiedParsed" select="concat(concat(substring-before($mainModified,' '),'T'),substring-after($mainModified,' '))"/>
              <xsl:variable name="secondModifiedParsed" select="concat(concat(substring-before($secondModified,' '),'T'),substring-after($secondModified,' '))"/>
              <xsl:variable name="timeDiff" select="date:difference($mainModifiedParsed,$secondModifiedParsed)"/>
            <xsl:choose>
              <xsl:when test="substring-before($timeDiff,'P') = '-' or $timeDiff = ''">
                <file-sync-response>
                  <xsl:variable name="fileEncoded" select="my:getFile($domain,$location,./@name,$xmlMgmtInterface)/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='response']/*[local-name()='file']"/>
                  <xsl:value-of select="my:setFile($domain,$fileEncoded,$location,./@name,$secondXmlMgmtInterface)"/>
                </file-sync-response>
              </xsl:when>
            </xsl:choose>
          </file>
        </xsl:for-each>
      </directory>
    </xsl:for-each>
    <directory name="local:/">
      <xsl:for-each select="$mainFileStore/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='response']/*[local-name()='filestore']/*[local-name()='location']/*[local-name()='file']">
        <file name="{./@name}">
          <xsl:variable name="filename" select="./@name"/>
          <xsl:variable name="mainModified" select="./*[local-name()='modified']"/>
          <xsl:variable name="secondModified" select="$secondFileStore/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='response']/*[local-name()='filestore']/*[local-name()='location']/*[local-name()='file' and @name=$filename]/*[local-name()='modified']"/>
            <xsl:variable name="mainModifiedParsed" select="concat(concat(substring-before($mainModified,' '),'T'),substring-after($mainModified,' '))"/>
            <xsl:variable name="secondModifiedParsed" select="concat(concat(substring-before($secondModified,' '),'T'),substring-after($secondModified,' '))"/>
            <xsl:variable name="timeDiff" select="date:difference($mainModifiedParsed,$secondModifiedParsed)"/>
          <xsl:choose>
            <xsl:when test="substring-before($timeDiff,'P') = '-' or $timeDiff = ''">
              <alon><xsl:value-of select="$secondModified"/></alon>
              <file-sync-response>
                <xsl:variable name="fileEncoded" select="my:getFile($domain,'local:///',$filename,$xmlMgmtInterface)/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='response']/*[local-name()='file']"/>
                <xsl:value-of select="my:setFile($domain,$fileEncoded,'local:///', $filename ,$secondXmlMgmtInterface)"/>
              </file-sync-response>
            </xsl:when>
          </xsl:choose>
        </file>
      </xsl:for-each>
    </directory>
  </Results>
  </xsl:template>
</xsl:stylesheet>
