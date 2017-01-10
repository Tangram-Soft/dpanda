<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  xmlns:dp="http://www.datapower.com/extensions"
  extension-element-prefixes="dp">

  <xsl:variable name="creds" select="str:tokenize(substring-after(dp:variable('var://service/URI'),'?'),'&amp;')"/>

  <xsl:template match="node()|@*">
		 <xsl:copy>
			 <xsl:apply-templates select="node()|@*"/>
		 </xsl:copy>
	</xsl:template>

  <xsl:template match="@user">
    <xsl:attribute name="user">
		    <xsl:value-of select="substring-after($creds[1],'=')"/>
      </xsl:attribute>
      <xsl:message>@@SD user: <xsl:value-of select="substring-after($creds[1],'=')"/></xsl:message>
	</xsl:template>

  <xsl:template match="@password">
    <xsl:attribute name="password">
	    <xsl:value-of select="substring-after($creds[2],'=')"/>
    </xsl:attribute>
    <xsl:message>@@SD pass: <xsl:value-of select="substring-after($creds[2],'=')"/></xsl:message>
	</xsl:template>

</xsl:stylesheet>
