<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:dp="http://www.datapower.com/extensions" xmlns:json="http://www.ibm.com/xmlns/prod/2009/jsonx" extension-element-prefixes="dp json" exclude-result-prefixes="dp json">
	<xsl:strip-space elements="url"/>
	<xsl:template match="/">
		<xsl:variable name="URI" select="dp:variable('var://service/URI')"/>
		<xsl:variable name="MultiResults">
			<results mode="attempt-all" multiple-outputs="true">
				<xsl:for-each select="document('local://dpanda/configuration.jsonx.xml')//*[local-name()='array'][@name='appliances']//*[local-name()='object']">
					<xsl:if test=".//*[local-name()='boolean'][@name='monitor']/text()= 'true'">
						<url>https://<xsl:value-of select=".//*[local-name()='string'][@name='hostIp']/text()"/>:<xsl:value-of select="'9080'"/>
							<xsl:value-of select="substring-before($URI,'?')"/>
						</url>
				</xsl:if>
				</xsl:for-each>
			</results>
		</xsl:variable>
		<dp:set-variable name="'var://context/RouteToApi/resultURLs'" value="$MultiResults"/>
	</xsl:template>
</xsl:stylesheet>
