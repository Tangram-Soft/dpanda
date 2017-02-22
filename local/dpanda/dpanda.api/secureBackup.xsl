<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:mgmt="http://www.datapower.com/schemas/management"
	xmlns:dpa="http://dpanda.com/functions"
	xmlns:exslt="http://exslt.org/common"
	xmlns:regexp="http://exslt.org/regular-expressions"
	xmlns:func="http://exslt.org/functions"
	exclude-result-prefixes="dp dpconfig "
	extension-element-prefixes="regexp dp dpconfig func dpa exslt date">

	<xsl:variable name="xmlMgmtInterface" select="'https://dpanda.xml.mgmt:5550/service/mgmt/3.0'"/>

	<xsl:param name="configuration" select="document('local://dpanda/configuration.xml')"/>
	<xsl:param name="remoteUrl" select="$configuration//secureBackup/remoteUrl/text()" />
	<xsl:param name="secureBackupCert" select="'dpanda-secure.backup'" />

	<func:function name="dpa:doActionRequest">
		<!--do action soma Request-->

		<xsl:param name="doActionRequest_domainName"/>
		<xsl:param name="doActionRequest_doActionElement"/>

		<xsl:message dp:type="dpanda-secure-backup" dp:priority="debug">Do action begin</xsl:message>
		<xsl:message dp:type="dpanda-secure-backup" dp:priority="debug"><xsl:copy-of select="$doActionRequest_doActionElement"/></xsl:message>

		<xsl:variable name="doActionRequest_doActionResult">
			<dp:url-open target="{$xmlMgmtInterface}" response="xml" http-method="post">
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


		<dp:set-variable name="'var://context/panda/somaResult'" value="$doActionRequest_doActionResult//*[name()='dp:result']//text()"/>
		<xsl:message dp:type="dpanda-secure-backup" dp:priority="debug"><xsl:copy-of select="dp:variable('var://context/panda/somaResult')"/></xsl:message>
		<!--handle do action response-->
		<xsl:choose>
			<!--if do action succeeded-->
			<xsl:when test="contains($doActionRequest_doActionResult//*[name()='dp:result']/text(), 'OK')">
				<xsl:message dp:type="dpanda-secure-backup" dp:priority="debug">do-action succeeded</xsl:message>
				<func:result select="true()"/>
			</xsl:when>
			<!--if do action failed-->
			<xsl:otherwise>
				<xsl:message dp:type="dpanda-secure-backup" dp:priority="error">do-action failed</xsl:message>
				<func:reuslt select="false()"/>
			</xsl:otherwise>

		</xsl:choose>
	</func:function>

	<xsl:template match="/">
		<!--secure backup url-->
		<xsl:variable name="backupDestination">
			<xsl:choose>
				<xsl:when test="$remoteUrl">
					<xsl:value-of select="$remoteUrl"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'local:///dpanda/backups/dpanda-secure-backup'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:message dp:type="dpanda-secure-backup" dp:priority="debug">remote destination for secure backup: <xsl:value-of select="$backupDestination"/></xsl:message>

		<!-- Perform a domain secure backup request call through XML Management Service -->
		<xsl:variable name="secureBackupRequest">
    <SecureBackup>
       <cert><xsl:value-of select="$secureBackupCert"/></cert>
       <destination><xsl:value-of select="$backupDestination"/></destination>
       <include-iscsi>on</include-iscsi>
       <include-raid>on</include-raid>
		 </SecureBackup>
		</xsl:variable>

		<xsl:variable name="secureBackupResult" select="dpa:doActionRequest('default', $secureBackupRequest)"/>

		<!--build Response JSON-->
		<xsl:variable name="secureBackupResponse">
			<xsl:choose>
				<xsl:when test="$secureBackupResult">
					<xsl:message dp:type="dpanda-secure-backup" dp:priority="debug">secure Backup succeeded</xsl:message>
					<xsl:text>{"secureBackupStatus":"succeed", </xsl:text>
					<xsl:text>"location":"</xsl:text><xsl:value-of select="$backupDestination"/><xsl:text>"}</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message dp:type="dpanda-secure-backup" dp:priority="error">secure backup failed</xsl:message>
					<xsl:text>{"appBackupStatus":"failed",</xsl:text>
					<xsl:text>"reason":"</xsl:text><xsl:value-of select="dp:variable('var://context/panda/somaResult')"/><xsl:text>"}</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--output-->
		<xsl:value-of select="$secureBackupResponse"/>

	</xsl:template>
</xsl:stylesheet>
