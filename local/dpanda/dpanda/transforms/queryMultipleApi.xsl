<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:dp="http://www.datapower.com/extensions" extension-element-prefixes="dp" exclude-result-prefixes="xalan dp" xmlns:xalan="http://xml.apache.org/xslt">
	<xsl:strip-space elements="url"/>
	<xsl:template match="/">
		<xsl:variable name="URI" select="dp:variable('var://service/URI')"/>
		<xsl:variable name="MultiResults">
			<results mode="attempt-all" multiple-outputs="true">
				<xsl:for-each select="document('local://dpanda/configuration.xml')//AppliancesToMonitor/Appliance">
					<url>http://<xsl:value-of select="./@Host-ip"/>:<xsl:value-of select="./@api-port"/>
						<xsl:value-of select="substring-before($URI,'?')"/>
					</url>
				</xsl:for-each>
			</results>
		</xsl:variable>
		<dp:set-variable name="'var://context/RouteToApi/resultURLs'" value="$MultiResults"/>
	</xsl:template>
</xsl:stylesheet>
