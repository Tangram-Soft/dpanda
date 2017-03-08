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

    <xsl:output method="html"/>

	<xsl:template match="/">
	    <!--
	    <xsl:variable name="header">
		    <xsl:include href="http://dpanda.localhost:65010/dpanda/header.html"/>
		</xsl:variable>
		-->
		<xsl:variable name="test">
		    <dp:url-open target="http://dpanda.localhost:65010/dpanda/header.html"
                response="ignore"
                data-type="base64"
                content-type="text/html"
                http-method="get">
            </dp:url-open>
		</xsl:variable>

		<xsl:message dp:priority="warning">
		    elad test
		    <xsl:copy-of select="$test" />
		    <!--<xsl:include href="http://dpanda.localhost:65010/dpanda/header.html"/>-->
		</xsl:message>
		<xsl:message dp:priority="error">
		    <xsl:copy-of select="unparsed-text('http://dpanda.localhost:65010/dpanda/header.html', 'utf-8')"/>
		</xsl:message>
		
        <xsl:copy-of select="$test" />
        <xsl:copy-of select="unparsed-text('http://dpanda.localhost:65010/dpanda/header.html', 'utf-8')"/>
        <xsl:copy-of select="unparsed-text('http://dpanda.localhost:65010/dpanda/index.html', 'utf-8')"/>
        <xsl:copy-of select="unparsed-text('http://dpanda.localhost:65010/dpanda/footer.html', 'utf-8')"/>
		
		<!--
		<xsl:include href="http://dpanda.localhost:65010/dpanda/index.html"/>
		<xsl:include href="http://dpanda.localhost:65010/dpanda/footer.html"/>
		-->
	</xsl:template>

</xsl:stylesheet>
