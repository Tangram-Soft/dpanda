<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:func="http://exslt.org/functions"
	xmlns:list="http://www.example.com/list"
	xmlns:sd="Tangram-soft.co.il"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:str="http://exslt.org/strings"
	extension-element-prefixes="dp">

   	<xsl:output method="xml" encoding="utf-8" indent="yes"/>

	<xsl:template match="@schemaLocation">
		<xsl:variable name="fileName" select="dp:variable('var://context/getWsdlFiles/currentFileName')"/>
   		<xsl:variable name="localSchemaLocation" select="concat($fileName,'_xsd.',str:tokenize(.,'=')[last()])"/>

   		<xsl:attribute name="schemaLocation"><xsl:value-of select="$localSchemaLocation"/></xsl:attribute>
   	</xsl:template>

   	<!-- Identity transformation -->
    <xsl:template match="node()|@*">
		<xsl:copy>
		  <xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>