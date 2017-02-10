<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:mgmt="http://www.datapower.com/schemas/management"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:dpa="http://dpanda.com/functions"
	xmlns:exslt="http://exslt.org/common"
	xmlns:func="http://exslt.org/functions"
	exclude-result-prefixes="dp dpconfig "
	extension-element-prefixes="dp dpconfig func dpa exslt">
	version="1.0">

	<xsl:output method="xml" />

	<xsl:param name="dpconfig:remoteUrl" />
	<dp:param name="dpconfig:remoteUrl" required="true">
		<display>Remote backup destination</display>
		<default></default>
		<description>Enter the full Remote URL of the backup file locaition. The URL pattern for FTP site is: ftp://[user]:[password]@[host]:[port]/[directory]/.
			if empty, saving the backup file on the local machine - temporary:///secureBackup
		</description>
	</dp:param>

	<xsl:variable name="xmlMgmtInterface" select="'https://dpanda.xml.mgmt:5550/service/mgmt/3.0'"/>
	<xsl:variable name="pwd64" select="dp:encode('dpanda:dpanda','base-64')"/>
	<xsl:variable name="basicAuth" select="concat('Basic ',$pwd64)"/>
	<xsl:variable name="somaRequestHeaders">
		<header name="Content-Type">application/soap+xml</header>
		<header name="Authorization"><xsl:value-of select="$basicAuth"/></header>
	</xsl:variable>

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

	<xsl:template match="/">
		<xsl:call-template name="putFile">
			<xsl:with-param name="BackUpFile">
				<!-- Perform a domain backup request call through XML Management Interface -->
				<dp:url-open target="{$xmlMgmtInterface}" response="responsecode"  http-method="post" http-headers="$somaRequestHeaders">
					<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
						<env:Body>
							<dp:request domain="default" xmlns:dp="http://www.datapower.com/schemas/management">
								<dp:do-backup format="ZIP">
									<dp:user-comment>Entire System Backup</dp:user-comment>
									<dp:domain name="all-domains"/>
								</dp:do-backup>
							</dp:request>
						</env:Body>
					</env:Envelope>
				</dp:url-open>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- function putFile will decode the encoded binary64 backup of domains response and ftp it to a location -->
	<xsl:template name="putFile">
		<xsl:param name="BackUpFile" />

		<dp:set-variable name="'var://context/dpanda/backup'" value="$BackUpFile"/>

		<xsl:if test="$BackUpFile='' or string-length(string($BackUpFile//mgmt:file)) &lt; 10">
			<xsl:message dp:type="backup" dp:priority="alert">GB Backup request failed</xsl:message>
			<RESPONSE>
				<RC>8</RC>
				<Desc>Backup request failed</Desc>
			</RESPONSE>
			<dp:reject />
		</xsl:if>

		<!-- generate backup file name with current timestamp -->
		<xsl:variable name="gb_deviceModel" select="dp:variable('var://service/system/ident')//identification/display-product/text()" />
		<xsl:variable name="gb_deviceName" select="dp:variable('var://service/system/ident')//identification/device-name/text()" />
		<xsl:variable name="gb_deviceSerial" select="dp:variable('var://service/system/ident')//identification/serial-number/text()" />

		<xsl:variable name="gb_date" select="substring-before(date:date-time(),'T')"/>
		<xsl:variable name="gb_year" select="substring($gb_date,1,4)"/>
		<xsl:variable name="gb_month" select="substring($gb_date,6,2)"/>
		<xsl:variable name="gb_day" select="substring($gb_date,9,2)"/>
		<xsl:variable name="gb_time" select="substring-after(date:date-time(),'T')"/>
		<xsl:variable name="gb_hh" select="substring($gb_time,1,2)"/>
		<xsl:variable name="gb_mm" select="substring($gb_time,4,2)"/>
		<xsl:variable name="gb_ss" select="substring($gb_time,7,2)"/>

		<xsl:variable name="gb_filename" select="concat('DataPower_',$gb_deviceModel,'_',$gb_deviceSerial,'_',$gb_deviceName,'_',$gb_year,$gb_month,$gb_day,'T',$gb_hh,$gb_mm,$gb_ss,'_FullBackup.zip')" />

		<xsl:variable name="gb_uploadUrl">
			<xsl:choose>
				<xsl:when test="$dpconfig:remoteUrl">
					<xsl:value-of select="concat($dpconfig:remoteUrl,$gb_filename)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('local:///backup','/',$gb_filename) "/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Extract the export content string -->
		<xsl:variable name="gb_backupedData" select="string($BackUpFile//mgmt:file)" />

		<xsl:choose>
			<!-- Upload it to the external storage -->
			<xsl:when test="$dpconfig:remoteUrl">
				<xsl:variable name="BackupRC">
					<dp:url-open target="{$gb_uploadUrl}" response="ignore" data-type="base64">
						<xsl:value-of select="$gb_backupedData" />
					</dp:url-open>
				</xsl:variable>
			</xsl:when>
			<!-- Upload it to the local storage -->
			<xsl:otherwise>
				<xsl:value-of select="dpa:setFile($gb_uploadUrl, $gb_backupedData)"/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Generate response to client -->
		<RESPONSE>
			<RC>0</RC>
			<Desc>Full backup was created and uploaded to external storage</Desc>
			<BackupPath><xsl:value-of select="$gb_uploadUrl"/></BackupPath>
			<ResponseFromServer><xsl:value-of select="$BackupRC"/></ResponseFromServer>
		</RESPONSE>
	</xsl:template>
</xsl:stylesheet>
