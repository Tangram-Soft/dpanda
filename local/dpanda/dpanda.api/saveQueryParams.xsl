<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dp="http://www.datapower.com/extensions"
  extension-element-prefixes="dp">

  <xsl:template match="arg">
    <xsl:variable name="varName" select="concat('var://context/dpanda.api/',@name/text())"/>
    <dp:set-variable name="$varName" value="."/>
  </xsl:template>
</xsl:stylesheet>
