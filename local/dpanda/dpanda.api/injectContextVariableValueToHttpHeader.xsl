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
	<xsl:param name="dpconfig:HttpHeaderName"/>
	<dp:param name="dpconfig:HttpHeaderName" type="dmString" xmlns="">
		<display>HTTP Header Name</display>
		<default>TransactionID</default>
		<description>The HTTP Header Name for the injection.</description>
	</dp:param>

	<xsl:param name="dpconfig:ContextVariablePath"/>
	<dp:param name="dpconfig:ContextVariablePath" type="dmString" xmlns="">
		<display>ContextVariablePath</display>
		<default>var://service/transaction-id</default>
		<description>The context variable name which it's value should be taken.</description>
	</dp:param>

	<xsl:template match="/">
        <dp:set-http-request-header name="$dpconfig:HttpHeaderName" value="$dpconfig:ContextVariablePath"/>
	</xsl:template>

</xsl:stylesheet>
