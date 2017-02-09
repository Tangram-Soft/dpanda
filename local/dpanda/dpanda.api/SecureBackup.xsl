<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:mgmt="http://www.datapower.com/schemas/management"
	xmlns:date="http://exslt.org/dates-and-times"
	exclude-result-prefixes="dp dpconfig date mgmt"
	version="1.0">

	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="xmlMgmtInterface" select="'https://dpanda.xml.mgmt:5550/service/mgmt/3.0'"/>
	<xsl:variable name="pwd64" select="dp:encode('dpanda:dpanda','base-64')"/>
	<xsl:variable name="basicAuth" select="concat('Basic ',$pwd64)"/>
	<xsl:variable name="somaRequestHeaders">
		<header name="Content-Type">application/soap+xml</header>
		<header name="Authorization"><xsl:value-of select="$basicAuth"/></header>
	</xsl:variable>

	<xsl:param name="dpconfig:remoteUrl" />
	<dp:param name="dpconfig:remoteUrl" required="true">
		<display>Remote backup destination</display>
		<default></default>
		<description>Enter the full Remote URL of the backup file locaition. The URL pattern for FTP site is: ftp://[user]:[password]@[host]:[port]/[directory]/.
			if empty, saving the backup file on the local machine - temporary:///secureBackup
		</description>
	</dp:param>

	<xsl:variable name="backupCert" select="'dpanda-secure.backup'" />
	<!--dp:param name="dpconfig:backupCert" required="true">
		<display>The certificate used for the Secure backup</display>
		<default></default>
		<description>Enter Crypto Certificate Object name required for the Secure Backup.</description>
	</dp:param-->

	<xsl:template match="/">
		<xsl:variable name="backupLocation">
			<xsl:choose>
				<xsl:when test="$dpconfig:remoteUrl">
					<xsl:value-of select="$dpconfig:remoteUrl"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'temporary:///secureBackup'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Perform a domain secure backup request call through XML Management Service -->
		<xsl:variable name="Backup">
				<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
					<env:Body>
						<dp:request xmlns:dp="http://www.datapower.com/schemas/management"  domain="default">
							<dp:do-action>
								<SecureBackup>
									<cert><xsl:value-of select="$backupCert"/></cert>
									<destination><xsl:value-of select="$backupLocation"/></destination>
									<include-iscsi>off</include-iscsi>
									<include-raid>off</include-raid>
								</SecureBackup>
							</dp:do-action>
						</dp:request>
					</env:Body>
				</env:Envelope>
		</xsl:variable>

		<xsl:copy-of select="$Backup"/>

	</xsl:template>
</xsl:stylesheet>
