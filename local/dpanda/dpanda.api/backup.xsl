<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:mgmt="http://www.datapower.com/schemas/management"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:dpa="http://dpanda.com/functions"
	xmlns:exslt="http://exslt.org/common"
	xmlns:regexp="http://exslt.org/regular-expressions"
	xmlns:func="http://exslt.org/functions"
	exclude-result-prefixes="dp dpconfig "
	extension-element-prefixes="regexp dp dpconfig func dpa exslt">
	version="1.0">

	<xsl:output method="xml" />
	<xsl:param name="configuration" select="document('local://dpanda/configuration.xml')"/>
	<xsl:param name="remoteUrl" select="$configuration//applicationBackup/remoteUrl/text()" />

	<xsl:variable name="xmlMgmtInterface" select="'https://dpanda.xml.mgmt:5550/service/mgmt/3.0'"/>

	<func:function name="dpa:setFile">
	<!--this function upload file to local dp storage-->
    <xsl:param name="setFile_fileName"/>
    <xsl:param name="setFile_data"/>
		<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">set file data: <xsl:copy-of select="$setFile_data"/></xsl:message>
		<xsl:variable name="setFile_serializedData">
      <dp:serialize select="$setFile_data" omit-xml-decl="yes"/>
    </xsl:variable>


    <!--xsl:variable name="setFile_encodedData" select="dp:encode($setFile_serializedData,'base-64')"/-->
		<xsl:variable name="setFile_setFileResult">
      <dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post">
        <env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
          <env:Body>
            <dp:request domain="default" xmlns:dp="http://www.datapower.com/schemas/management">
              <dp:set-file  name="{$setFile_fileName}">
                <xsl:value-of select="$setFile_serializedData"/>
              </dp:set-file>
            </dp:request>
          </env:Body>
        </env:Envelope>
      </dp:url-open>
     </xsl:variable>

		 <!--handle set file response-->
		 <xsl:choose>
			 <!--if set file succeeded-->
			 <xsl:when test="contains($setFile_setFileResult//*[name()='dp:result']/text(), 'OK')">
				 <xsl:message dp:type="dpanda-application-backup" dp:priority="debug">set file succeeded</xsl:message>
				 <func:result select="true()"/>
			 </xsl:when>
			 <!--if set file failed-->
			 <xsl:otherwise>
				 <xsl:message dp:type="dpanda-application-backup" dp:priority="error">set file failed</xsl:message>
				 <func:reuslt select="false()"/>
			 </xsl:otherwise>

		 </xsl:choose>

  </func:function>

	<func:function name="dpa:doActionRequest">
		<!--do action soma Request-->

		<xsl:param name="doActionRequest_domainName"/>
		<xsl:param name="doActionRequest_doActionElement"/>

		<xsl:variable name="doActionRequest_doActionResult">
			<dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post"
				timeout="2">
				<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
					<env:Body>
						<dp:request domain="{$doActionRequest_domainName}" xmlns:dp="http://www.datapower.com/schemas/management">
							<dp:do-action>
								<xsl:copy-of select="$doActionRequest_doActionElement"/>
							</dp:do-action>
						</dp:request>
					</env:Body>
				</env:Envelope>
			</dp:url-open>
		</xsl:variable>

		<!--handle do action response-->
		<xsl:choose>
			<!--if do action succeeded-->
			<xsl:when test="contains($doActionRequest_doActionResult//*[name()='dp:result']/text(), 'OK')">
				<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">do-action succeeded</xsl:message>
				<func:result select="true()"/>
			</xsl:when>
			<!--if do action failed-->
			<xsl:otherwise>
				<xsl:message dp:type="dpanda-application-backup" dp:priority="error">do-action failed</xsl:message>
				<func:reuslt select="false()"/>
			</xsl:otherwise>

		</xsl:choose>
	</func:function>

	<func:function name="dpa:rotateBackupFiles">
		<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">backup rotation function has been started</xsl:message>
		<!--retreive backup file store snapshot-->
		<xsl:variable name="rotateBackupFiles_localSnapshot">
			<dp:url-open target="{$xmlMgmtInterface}" response="xml"  http-method="post">
				<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
					<env:Body>
						<dp:request domain="dpanda" xmlns:dp="http://www.datapower.com/schemas/management">
							<dp:get-filestore  location="local:" annotated="true" layout-only="false" no-subdirectories="false"/>
						</dp:request>
					</env:Body>
				</env:Envelope>
			</dp:url-open>
		</xsl:variable>

<!--checks amount of backups-->
		<xsl:variable name="rotateBackupFiles_backupCount" select="count($rotateBackupFiles_localSnapshot//directory[@name='local:/backups/application']/file)"/>
		<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">backup count: <xsl:value-of select="$rotateBackupFiles_backupCount"/></xsl:message>
		<xsl:if test="$rotateBackupFiles_backupCount 	&lt; 3">
			<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">backup count is less then 3, no rotation needed</xsl:message>
			<func:result select="true()"/>
		</xsl:if>

		<xsl:for-each select="$rotateBackupFiles_localSnapshot//directory[@name='local:/backups/application']/file">
			<xsl:choose>

				<xsl:when test="position()=1">
					<dp:set-variable name="'var://context/rotateFunc/oldestFileDate'" value="translate(./modified/text(), ' ', 'T')"/>
					<dp:set-variable name="'var://context/rotateFunc/oldestFileName'" value="./@name"/>
					<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">first file date <xsl:value-of select="dp:variable('var://context/rotateFunc/oldestFileDate')"/></xsl:message>
				</xsl:when>

				<xsl:otherwise>
					<xsl:variable name="rotateBackupFiles_currentBackupDate" select="translate(./modified/text(), ' ', 'T')"/>
					<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">current file date <xsl:value-of select="$rotateBackupFiles_currentBackupDate"/></xsl:message>
					<xsl:variable name="rotateBackupFiles_timeDiff" select="date:difference($rotateBackupFiles_currentBackupDate, dp:variable('var://context/rotateFunc/oldestFileDate'))"/>
					<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">time diff <xsl:value-of select="$rotateBackupFiles_timeDiff"/></xsl:message>
					<xsl:if test="not(contains($rotateBackupFiles_timeDiff, '-'))">
						<dp:set-variable name="'var://context/rotateFunc/oldestFileDate'" value="$rotateBackupFiles_currentBackupDate"/>
						<dp:set-variable name="'var://context/rotateFunc/oldestFileName'" value="./@name"/>
					</xsl:if>
				</xsl:otherwise>

			</xsl:choose>
		</xsl:for-each>

		<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">oldest file date <xsl:value-of select="dp:variable('var://context/rotateFunc/oldestFileDate')"/></xsl:message>
		<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">oldest file name <xsl:value-of select="dp:variable('var://context/rotateFunc/oldestFileName')"/></xsl:message>
		<xsl:variable name="rotateBackupFiles_deleteFile">
			<DeleteFile>
				<File>local:///backups/application/<xsl:value-of select="dp:variable('var://context/rotateFunc/oldestFileName')"/></File>
			</DeleteFile>
		</xsl:variable>

		<func:result select="dpa:doActionRequest('dpanda', $rotateBackupFiles_deleteFile)"/>
	</func:function>

	<func:function name="dpa:uploadBackup">
		<xsl:param name="uploadBackup_BackUpFile" />

		<!--if backup failed-->
		<xsl:if test="not($uploadBackup_BackUpFile//*[name()='dp:file'])">
			<xsl:message dp:type="dpanda-application-backup" dp:priority="alert">Application Backup request failed</xsl:message>
			<xsl:variable name="uploadBackup_responseToClient">
				<xsl:text>{"appBackupStatus":"failed",</xsl:text>
				<xsl:text>"reason":"Application Backup request failed"}</xsl:text>
			</xsl:variable>
		<func:result select="$uploadBackup_responseToClient"/>
		</xsl:if>

		<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">Backup request succeed</xsl:message>
		<!-- generate backup file name with current timestamp -->
		<xsl:variable name="uploadBackup_deviceName" select="$configuration//appliances/appliance[@id='1']/@host-name" />
		<xsl:variable name="uploadBackup_filename" select="translate(concat($uploadBackup_deviceName,'_',$uploadBackup_BackUpFile//*[name()='dp:timestamp']/text(),'_applicationBackup.zip'), ':', '')" />
		<!-- Rotate file-->
		<xsl:if test="not($remoteUrl)">
			<xsl:variable name="uploadBackup_rotateBackups" select="dpa:rotateBackupFiles()"/>
			<xsl:if test="not($uploadBackup_rotateBackups)">
				<xsl:message dp:type="dpanda-application-backup" dp:priority="error">Backup rotation Failed</xsl:message>
			</xsl:if>
		</xsl:if>
		<!--set backup dest url-->
		<xsl:variable name="uploadBackup_uploadUrl">
			<xsl:choose>
				<xsl:when test="$remoteUrl">
					<xsl:value-of select="concat($remoteUrl,$uploadBackup_filename)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('local://dpanda/backups/application','/',$uploadBackup_filename) "/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Extract the export content string -->
		<xsl:variable name="uploadBackup_backupedData" select="$uploadBackup_BackUpFile//*[name()='dp:file']/text()" />
		<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">Upload url is: <xsl:value-of select="$uploadBackup_uploadUrl"/></xsl:message>


		<xsl:variable name="uploadBackup_uploadResult">
			<xsl:choose>
				<!-- Upload it to the external storage -->
				<xsl:when test="$remoteUrl">
					<xsl:variable name="uploadBackup_doBackup">
						<dp:url-open target="{$uploadBackup_uploadUrl}" response="xml" data-type="base64">
							<xsl:value-of select="$uploadBackup_backupedData" />
						</dp:url-open>
					</xsl:variable>
					<xsl:if test="not($uploadBackup_doBackup//statuscode)">
						<xsl:value-of select="'succeed'"/>
					</xsl:if>
					<xsl:if test="$uploadBackup_doBackup//statuscode">
						<dp:set-variable name="'var://context/panda/error'" value="'upload file to local failed. error code:'+ $uploadBackup_doBackup//statuscode/text() "/>
					</xsl:if>
				</xsl:when>
				<!-- Upload it to the local storage -->
				<xsl:otherwise>
					<xsl:variable name="uploadBackup_doBackup">
						<xsl:value-of select="dpa:setFile($uploadBackup_uploadUrl, $uploadBackup_backupedData)"/>
					</xsl:variable>
					<xsl:if test="$uploadBackup_doBackup">
						<xsl:value-of select="'succeed'"/>
					</xsl:if>
					<xsl:if test="not($uploadBackup_doBackup)">
						<dp:set-variable name="'var://context/panda/error'" value="'upload file to local filestore failed'"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<!-- Generate response to client -->
		<xsl:variable name="uploadBackup_responseToClient">
			<xsl:choose>
				<xsl:when test="$uploadBackup_uploadResult='succeed'">
					<xsl:message dp:type="dpanda-application-backup" dp:priority="debug">upload backup succeed</xsl:message>
					<xsl:text>{"appBackupStatus":"succeed", </xsl:text>
					<xsl:text>"fileName":"</xsl:text><xsl:value-of select="$uploadBackup_filename"/><xsl:text>"}</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message dp:type="dpanda-application-backup" dp:priority="error">upload backup failed</xsl:message>
					<xsl:text>{"appBackupStatus":"failed",</xsl:text>
					<xsl:text>"reason":"</xsl:text><xsl:value-of select="dp:variable('var://context/panda/error')"/><xsl:text>"}</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<func:result select="$uploadBackup_responseToClient"/>
	</func:function>

	<xsl:template match="/">
		<!-- Perform a domain backup request call through XML Management Interface -->
			<xsl:variable name="backupFile">
				<dp:url-open target="{$xmlMgmtInterface}" response="xml"  http-method="post">
					<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
						<env:Body>
							<dp:request domain="default" xmlns:dp="http://www.datapower.com/schemas/management">
								<dp:do-backup format="ZIP">
									<xsl:for-each select="$configuration//applicationBackup/domainsToBackup/domain" >
										<xsl:variable name="domainName" select="./@name"/>
										<dp:domain name="{$domainName}"/>
									</xsl:for-each>
								</dp:do-backup>
							</dp:request>
						</env:Body>
					</env:Envelope>
				</dp:url-open>
			</xsl:variable>

			<!--output to client-->
			<xsl:copy-of select="dpa:uploadBackup($backupFile)"/>

	</xsl:template>
</xsl:stylesheet>
