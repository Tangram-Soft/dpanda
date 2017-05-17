<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.datapower.com/extensions"
  extension-element-prefixes="dp">

  <xsl:template match="arg">
    <xsl:variable name="nameVal"><xsl:value-of select="@name" /></xsl:variable>
    <xsl:variable name="varName" select="concat('var://context/dpanda.api/',$nameVal)"/>
    <dp:set-variable name="$varName" value="."/>
  </xsl:template>
</xsl:stylesheet>
