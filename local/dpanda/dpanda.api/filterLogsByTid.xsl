<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:mgmt="http://www.datapower.com/schemas/management"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:regexp="http://exslt.org/regular-expressions"
	exclude-result-prefixes="dp dpconfig regexp date mgmt"
	extension-element-prefixes="dp"
	version="2.0">

	<xsl:template match="/">
	    <xsl:variable name="tid" select="dp:variable('var://context/dpanda.api/tid')"/>
	    <logs>
	    <xsl:for-each select="/*[local-name()='log']/*[local-name()='log-entry'][transaction = $tid]">
	        <xsl:copy-of select="." />
	    </xsl:for-each>
	    </logs>
	</xsl:template>

</xsl:stylesheet>
