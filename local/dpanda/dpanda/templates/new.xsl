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

	<!-- This is a new XSL transformation file. -->
	<xsl:param name="dpconfig:my_param"/>
	<dp:param name="dpconfig:my_param" type="dmString" xmlns="">
		<display>my_param display text</display>
		<default>my_param default value</default>
		<description>Description for my_param</description>
	</dp:param>

	<xsl:template match="/">
		<xsl:message>Place your code here...</xsl:message>
	</xsl:template>

</xsl:stylesheet>
