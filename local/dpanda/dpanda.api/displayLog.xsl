<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:jsonx="http://www.ibm.com/xmlns/prod/2009/jsonx"
	exclude-result-prefixes="dp dpconfig "
	extension-element-prefixes="dp dpconfig">
	version="1.0">

	<xsl:output method="xml" />

	<xsl:param name="dpconfig:logFileService" />
	<dp:param name="dpconfig:logFileService" required="true">
		<display>Log File Service URL</display>
		<default>http://127.0.0.1:65012</default>
		<description>The name of the log file. For example. logfile.log</description>
	</dp:param>

	<xsl:param name="dpconfig:logFileName" />
	<dp:param name="dpconfig:logFileName" required="true">
		<display>Log File Name</display>
		<default></default>
		<description>The name of the log file. For example. logfile.log</description>
	</dp:param>

	<xsl:template match="/">
		<xsl:variable name="logFileUrl" select="concat($dpconfig:logFileService,'/',$dpconfig:logFileName)"/>

		<xsl:variable name="resp">
			<dp:url-open target="{$logFileUrl}"
				response="binaryNode"/>
		</xsl:variable>

		<xsl:variable name="logContent" select="dp:decode(dp:binary-encode($resp/result/binary),'base-64')"/>

		<xsl:variable name="logContentParsed" select="dp:parse(concat('&lt;wrap>',$logContent,'&lt;/wrap>'))/*/*"/>
		<jsonx:array>
			<xsl:for-each select="$logContentParsed">
				<jsonx:object>
					<jsonx:string name="timestamp">
						<xsl:value-of select="./date-time"/>
					</jsonx:string>
					<jsonx:string name="object">
						<xsl:value-of select="./object"/>
					</jsonx:string>
					<jsonx:string name="message">
						<xsl:value-of select="./message"/>
					</jsonx:string>
				</jsonx:object>
			</xsl:for-each>
		</jsonx:array>
	</xsl:template>
</xsl:stylesheet>
